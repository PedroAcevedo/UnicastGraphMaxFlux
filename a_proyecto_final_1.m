%% Documentacion
% Variables
% C: Matriz cuadrada de adyacencia y capacidades. Es una matriz de 1 y 0
% 
% dest: Vector con los destinos del grafo multicast
% 
% nn: Longitud de la matriz cuadrada C. Es el n�mero de nodos del grafo
% 
% ndest: N�mero de sumideros
% 
% flumaxrut: Arreglo que cuenta el n�mero de rutas v�lidas por cada destino
%            y corresponde con el n�mero de rutas o caminos que llega a
%            cada destino.
% 
% rutas: Matriz de todas las rutas desde el fuente hasta un sumidero en dest
%        rutas(i).camino: Es el camino i, constituido por k nodos desde el
%                     fuente hasta el sumidero en dest.
%      rutas(i).sumcol: Suma de colisiones en cada nodo del camino para la 
%                     ruta i
% 
% posi: Matriz que indica que ruta pasa por cada nodo del grafo.
%       Tama�o de posi: Num de rutas x n�mero de nodos
%       Valores: posi(k,l)=0: La ruta k, no pasa por el nodo l
%                posi(k,l)=1: la ruta k, pasa por el nodo l
% 
% long: Vector de longitud de cada ruta 
% 
% marca: Vector que indica si una ruta est� seleccionada.
%        Tama�o de marca: N�mero de rutas.
%        Valores: marca(i)=0: No ha sido revisada la ruta i
%                 marca(i)=1: La ruta i no puede ser utilizada, coincide 
%                             con una seleccionada v�lida.
%                 marca(i)=2: Ruta seleccionada, y conlleva que se marquen 
%                             las rutas coicidentes con esta en los nodos, 
%                             con el valor 1 en todas las posiciones de
%                             posi donde aparezca.
% 
% nodosenruta: Guarda la secuencia de identificadores de rutas que pasan 
%               por cada nodo del grafo hasta ese destino(sumidero),sin
%               incluirlo a �l ni al fuente. Cada posici�n del arreglo 
%               contiene un campo lista. As� nodosenruta(i).lista contiene 
%               todas las rutas que pasan por el nodo i.
%               Tama�o: destino - 1
% 
% colisiones: Arreglo que guarda el n�mero de rutas que pasa por cada nodo.
%             As� colisiones(i) = k significa que k rutas pasan por el nodo
%             i.
%             Tama�o: destino -1
%
% matpredsus: Estructura que guarda los nodos predecesores y sucesores para
%             un nodo en una distancia espec�fica, as� como los caminos 
%             generados hasta ese momento.
%
% max_d: Disrancia + 1 del camino m�s largo entre el nodo fuente y los
%        nodos sumideros.

%% Main
clc;
clear all;
close all;
[C, dest] = ff_leerGrafo();
ff_grafo(C,dest,[3 5]);
nn = length(C);
ndest = length(dest);
flumaxrut = [];
segnodtot = find(C(1,:) == 1);
contsegnod(1:(length(segnodtot))) = 0;
maxflujo = zeros(ndest,nn,nn);
for n = 1:nn
    matpredsus(1,n).pred = [];
    matpredsus(1,n).sus = [];
    matpredsus(1,n).taken = 0;
    matpredsus(1,n).paths = [];
end
matpredsus = a_calcular_predecesor_sucesor(C, matpredsus, 1, 1, 0);
[max_d, nn] = size(matpredsus);
matpredsus = a_expansion_rutas(matpredsus, nn, max_d);
%Conjuntos = struct('dest',[]);
rutaseg = struct('nodo',[]);
for nd = 1:ndest
    rutas = a_obtener_rutas(matpredsus(:,dest(nd)), max_d);
    fprintf('%s%2.0f\n','Todas las rutas que llegan a ', dest(nd));
    for jl = 1:length(rutas)
        fprintf('%2.0f %2.0f ',jl,rutas(jl).camino);
        fprintf('\n');
    end
    tic
%   Rutasseg
    minlrut = [];
    rutaseg(nd).nodo = [];
    for is=1:length(rutas)
       segnodact = rutas(is).camino(2)-1;
       if length(rutaseg(nd).nodo) < (segnodact)
            rutaseg(nd).nodo(segnodact).lista(1) = is;
       else 
            rutaseg(nd).nodo(segnodact).lista(end + 1) = is;
       end
       lrut = length(rutas(is).camino);
       if length(minlrut) >= segnodact
          if minlrut ~= 0 
              if lrut < minlrut(segnodact)
                minlrut(segnodact) = lrut;
              end
          else
                minlrut(segnodact) = lrut;
          end
       else
           minlrut(segnodact) = lrut;
       end
    end
    for ir=1:length(rutaseg(nd).nodo)
        for jr=1:length(rutaseg(nd).nodo(ir).lista)
            ind = rutaseg(nd).nodo(ir).lista(jr);
            rutaseg(nd).nodo(ir).inter(jr) = intersects(rutas(ind).camino(2),rutas(ind).camino(2:end-1),rutas) + 2*length(rutas(ind).camino(2:end-1));
        end        
    end
    minlrut(minlrut == 0) = 100;
    [len inds] = min(minlrut);
    display(Disjoints(nd,inds,rutaseg,rutas,[],inds,minlrut))
    toc
%     for in=1:length(rutas)
%        Conj untos(nd).dest(in).long(1).lista = in;
%        mov = 0;
%        for kn=2:length(segnodtot)
%            Conjuntos(nd).dest(in).long(kn+mov).lista = in;
%            kl=2;
%            for jn=in+1:length(rutas)      
%                 if isempty(intersect(rutas(in).camino(2:length(rutas(in).camino)-1),rutas(jn).camino(2:length(rutas(jn).camino)-1)))
%                     if(length(Conjuntos(nd).dest(in).long(kn+mov).lista)>1)
%                         for iin=2:length(Conjuntos(nd).dest(in).long(kn+mov).lista)
%                             if isempty(intersect(rutas(Conjuntos(nd).dest(in).long(kn+mov).lista(iin)).camino(2:length(rutas(Conjuntos(nd).dest(in).long(kn+mov).lista(iin)).camino)-1),rutas(jn).camino(2:length(rutas(jn).camino)-1)))
%                                 if iin==length(Conjuntos(nd).dest(in).long(kn+mov).lista)
%                                     Conjuntos(nd).dest(in).long(kn+mov).lista(kl) = jn;
%                                     kl=kl+1;
%                                 else
%                                     break
%                                 end
%                             end
%                         end
%                     else
%                       Conjuntos(nd).dest(in).long(kn+mov).lista(kl) = jn;
%                       kl=kl+1;
%                     end
%                     if(kl > kn) 
%                         mov=mov+1;
%                         Conjuntos(nd).dest(in).long(kn+mov).lista = in;
%                         kl=2;
%                     end
%                 end
%            end
%         end
%     end
    tic
    posi = zeros(length(rutas),nn);  
    long = [];
    marca(1,length(rutas)) = 0;
    
    % C�lculo de la longitud de cada ruta y c�lculo de la matriz posi.
    for ii = 1:length(rutas)
        long = [long length(rutas(ii).camino)];
        for jj = 1:length(rutas(ii).camino)
            posi(ii,rutas(ii).camino(jj)) = 1;
        end
    end
    
    % C�lculo de caminos que pasan por cada nodo desde un fuente a un 
    % destino.
    for ii = 2:dest(nd) - 1
        nodosenruta(ii).lista = find(posi(:,ii) == 1);
    end
    
    % C�lculo de colisiones por nodo.
    colisiones = [];
    for ii = 1:dest(nd)-1
        colisiones = [colisiones length(nodosenruta(ii).lista)];
    end
    
    % C�lculo de suma de colisiones por ruta.
    for ii = 1:length(rutas)
        rutas(ii).sumcol = 0;
       for jj = 1:length(rutas(ii).camino) - 1
            rutas(ii).sumcol = rutas(ii).sumcol + colisiones(rutas(ii).camino(jj));
        end
    end
    
    while ~isempty(find(marca == 0))
        % Selecci�n de la ruta de entre todas las posibles. Se escoge la
        % ruta con menor longitud de entre todas las que est�n sin marcar.
        mn = min(long(find(marca == 0)));
        
        % Creaci�n de arreglo pos con las posiciones de rutas sin marcar.
        pos = find(marca == 0);
        
        % Creaci�n de arreglo ln de longitudes de rutas sin marcar. 
        ln = long(find(marca == 0));
        
        % Creaci�n de arreglo rut con direcciones de rutas cuyas posiciones
        % coinciden con la  menor longitud.
        rut = pos(find(ln == mn));
        
        % De entre todas las rutas en rut, se escoge la que tenga menos
        % colisiones. Se crea la variable prut que guarda en que posicion
        % de  rut est� la ruta con menos colisiones. La variable mncol
        % guarda la cantidad de colisiones de la ruta con menor n�mero de
        % colisiones.
        % Se busca la segunda ruta (ruta gemela a la primaria). La
        % direcci�n dentro de rut de la ruta gemela se guarda en la
        % variable srut. La variable sgcol guarda la cantidad de colisiones
        % de la ruta con menos colisiones despu�s de la ruta guardada en
        % mncol. 
        mncol = rutas(rut(1)).sumcol;
        prut = 1;
        for ii = 2:length(rut)
            if mncol > rutas(rut(ii)).sumcol
               mncol = rutas(rut(ii)).sumcol;
               prut = ii;
            end
        end
        
        % pos2: Guarda la posici�n de cada segundo en la variable segnodtot 
        %       por cada iteraci�n de ruta principal obtenida con direcci�n 
        %       en prut.
        %
        % contsegnod: Se incrementa en cada posici�n del arreglo de
        %             segundos nodos en cada enlace con el fin de tener en
        %             el total de veces que pasa cada ruta por el segundo
        %             nodo al final de las iteraciones.
        %
        % gemelo: Guarda el n�mero de nodos comunes entre el camino 
        %         principal y el camino obtenido como gemelo.
        
        pos2 = find(segnodtot == rutas(rut(prut)).camino(2));
        contsegnod(pos2) = contsegnod(pos2) + 1;
        
        % Se comprueba que el n�mero de elementos no comunes es 1 para
        % escogerlo como gemelo y guardar la informaci�n del segundo nodo
        % de la ruta principal (nsg), la ruta principal (pri) y la ruta
        % secundaria (seg).
        % La variable posp se incrementa en uno para continuar con la
        % siguiente ruta, siempre y cuando ya se haya guardado los  datos
        % anteriores en el posp actual.
        % Escogida la ruta principal, se busca en cada lista del arreglo 
        % rutas,de cada nodo del grafo, si rut(prut) est� en esa lista. Si
        % es as�, se procede a crear un arreglo (pilaelim) de las rutas 
        % que est�n en esa lista y que no coinciden con rut(prut). Luego 
        % estas rutas en pilaelim se marcan con 1 en marca, porque no ser� 
        % utilizada posteriormente. La ruta de rut(prut) se marca con 2, 
        % porque es v�lida.
        pilaelim = [];
        for ii = 1:length(nodosenruta)
            if ~isempty(find(nodosenruta(ii).lista == rut(prut)))
                ind = find(nodosenruta(ii).lista ~= rut(prut));
                pilaelim = [pilaelim; nodosenruta(ii).lista(ind)];
            end
        end
        pilaelim = unique(pilaelim);
        marca(pilaelim) = 1;
        for ii = 1:length(pilaelim)
            rutas(pilaelim(ii)).camino = [];
        end
        for ii = 1:length(nodosenruta)
            rutcomun = intersect(nodosenruta(ii).lista, pilaelim);
            for jj = 1:length(rutcomun)
                poscom = find(nodosenruta(ii).lista == rutcomun(jj));
                nodosenruta(ii).lista(poscom) = [];
            end
        end
        
        % Actualizaci�n de valores de colisiones y sumcol
        % C�lculo de colisiones por nodo
        colisiones = [];
        for ii = 1:dest(nd)-1
            colisiones = [colisiones length(nodosenruta(ii).lista)];
        end
        
        % C�lculo de suma de colisiones por ruta
        for ii = 1:length(rutas)
            rutas(ii).sumcol = 0;
            for jj = 1:length(rutas(ii).camino) - 1
                rutas(ii).sumcol = rutas(ii).sumcol + colisiones(rutas(ii).camino(jj));
            end
        end
        marca(rut(prut)) = 2;
    end
    
    % Despliegue de los caminos v�lidos a partir de las rutas marcadas con
    % 2 en marca. En rutasval se guarda el �ndice de las rutas v�lidas y
    % luego estas se despliegan.
    % C�lculo del arreglo de contador de rutas flumaxrut. Esto corresponde 
    % al flujo m�ximo por cada destino.
    %
    % segnod: Guarda la lista de los segundos nodos de cada ruta hacia
    %         nodos sumideros.
    %
    % segnodsinuso: Guarda la lista de los segundos nodos de todas las 
    %               rutas que no han sido usados. Es lo mismo que
    %               segnodtot-segnod(nd).lista.
    toc
    rutasval = find(marca == 2);
    segnod(nd).lista = [];
    for ii = 1:length(rutasval)
        rutasdest(nd).rutamax(ii).camino = rutas(rutasval(ii)).camino;
        rutasdest(nd).rutamax(ii).numruta = rutasval(ii);
        segnod(nd).lista = [segnod(nd).lista rutasdest(nd).rutamax(ii).camino(2)];
    end
    rutasval(:)
    flumaxrut = [flumaxrut length(rutasval)];
      
    % Se borra la variable marca para iniciarla en el nuevo destino.
    clear marca;
end
for x = 1:length(rutasdest)
    CC = zeros(nn);
    for y = 1:length(rutasdest(x).rutamax)
        for z = 1:length(rutasdest(x).rutamax(y).camino) - 1
            CC(rutasdest(x).rutamax(y).camino(z), rutasdest(x).rutamax(y).camino(z+1)) = 1;
        end
    end
    ff_grafo(CC,rutasdest(x).rutamax(y).camino(end),[]);
end