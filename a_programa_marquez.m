clc
clear all
% Variables
% C: Matriz cuadrada de adyacencia y capacidades. Es una matriz de 1 y 0
% dest: Vector con los destinos del grafo multicast
% nn: Longitud de la matriz cuadrada C. Es el número de nodos del grafo
% ndest: Número de sumideros
% flumaxrut: Arreglo que cuenta el número de rutas válidas por cada destino
%            y corresponde con el número de rutas o caminos que llega a
%            cada destino.
% rutas: Matriz de todas las rutas desde el fuente hasta un sumidero en dest
%        rutas(i).camino: Es el camino i, constituido por k nodos desde el
%                     fuente hasta el sumidero en dest.
%      rutas(i).sumcol: Suma de colisiones en cada nodo del camino para la 
%                     ruta i
% posi: Matriz que indica que ruta pasa por cada nodo del grafo.
%       Tamaño de posi: Num de rutas x número de nodos
%       Valores: posi(k,l)=0: La ruta k, no pasa por el nodo l
%                posi(k,l)=1: la ruta k, pasa por el nodo l
% long: Vector de longitud de cada ruta 
% marca: Vector que indica si una ruta está seleccionada.
%        Tamaño de marca: Número de rutas.
%        Valores: marca(i)=0: No ha sido revisada la ruta i
%                 marca(i)=1: La ruta i no puede ser utilizada, coincide 
%                             con una seleccionada válida.
%                 marca(i)=2: Ruta seleccionada, y conlleva que se marquen 
%                             las rutas coicidentes con esta en los nodos, 
%                             con el valor 1 en todas las posiciones de
%                             posi donde aparezca.
%nodosenruta: Guarda la secuencia de identificadores de rutas que pasan 
%              por cada nodo del grafo hasta ese destino(sumidero),sin
%              incluirlo a él ni al fuente. Cada posición del arreglo 
%              contiene un campo lista. Así nodosenruta(i).lista contiene 
%              todas las rutas que pasan por el nodo i.
%              Tamaño: destino - 1
%colisiones: Arreglo que guarda el número de rutas que pasa por cada nodo.
%            Así colisiones(i) = k significa que k rutas pasan por el nodo
%            i.
%            Tamaño: destino -1
                  
[C, dest]=ff_leerGrafo();
ff_grafo(C,dest,[]);
nn=length(C);
ndest=length(dest);
flumaxrut=[];
segnodtot=find(C(1,:)==1);
contsegnod(1:(length(segnodtot)))=0;
maxflujo=zeros(ndest,nn,nn);
for nd=1:ndest   
    rutas=ff_todas_las_rutas4(1,dest(nd),C);
    % Agregadas para prueba
%     fprintf('%s%2.0f\n','Rutas que pasan por cada nodo del grafo rumbo a ',dest(nd));
%     fprintf('%s','   ');
%     for jl=1:nn
%         fprintf('%2.0f',jl);
%     end
%     fprintf('\n');
%     for jl=1:length(rutas)
%         fprintf('%2.0f ',jl)
%         for ll=1:nn
%             if ~isempty(find(rutas(jl).camino==ll))
%                 fprintf('%s','x,');
%             else
%                 fprintf('%s',' ,');
%             end
%         end
%         fprintf('\n');
%     end
    fprintf('%s%2.0f\n','Todas las rutas que llegan a ', dest(nd));
    for jl=1:length(rutas)
        fprintf('%2.0f %2.0f ',jl,rutas(jl).camino);
        fprintf('\n');
    end
    % Fin agregadas para prueba
    
    posi=zeros(length(rutas),nn);  
    long=[];
    marca(1,length(rutas))=0;
    % Cálculo de la longitud de cada ruta y cálculo de la matriz posi.
    for ii=1:length(rutas)
        long = [long length(rutas(ii).camino)];
        for jj=1:length(rutas(ii).camino)
            posi(ii,rutas(ii).camino(jj))=1;
        end
    end
    % Cálculo de caminos que pasan por cada nodo desde un fuente a un
    % destino
    for ii=2:dest(nd) - 1
        nodosenruta(ii).lista=find(posi(:,ii)==1);
    end
    % Cálculo de colisiones por nodo
    colisiones=[];
    for ii=1:dest(nd)-1
        colisiones=[colisiones length(nodosenruta(ii).lista)];
    end
    % Cálculo de suma de colisiones por ruta
    for ii=1:length(rutas)
        rutas(ii).sumcol=0;
        for jj=1:length(rutas(ii).camino) - 1
            rutas(ii).sumcol=rutas(ii).sumcol + colisiones(rutas(ii).camino(jj));
        end
    end
    while ~isempty(find(marca==0))
        % Selección de la ruta de entre todas las posibles. Se escoge la
        % ruta con menor longitud de entre todas las que están sin marcar.
        mn=min(long(find(marca==0)));
        % Creación de arreglo pos con las posiciones de rutas sin marcar.
        pos=find(marca==0);
        % Creación de arreglo ln de longitudes de rutas sin marcar. 
        ln=long(find(marca==0));
        % Creación de arreglo rut con direcciones de rutas cuyas posiciones
        % coinciden con la  menor longitud.
        rut=pos(find(ln==mn));
        % De entre todas las rutas en rut, se escoge la que tenga menos
        % colisiones. Se crea la variable prut que guarda en que posicion
        % de  rut está la ruta con menos colisiones. La variable mncol
        % guarda la cantidad de colisiones de la ruta con menor número de
        % colisiones.
        % Se busca la segunda ruta (ruta gemela a la primaria). La
        % dirección dentro de rut de la ruta gemela se guarda en la
        % variable srut. La variable sgcol guarda la cantidad de colisiones
        % de la ruta con menos colisiones después de la ruta guardada en
        % mncol. 
        mncol=rutas(rut(1)).sumcol;
        prut=1;
        for ii=2:length(rut)
            if mncol > rutas(rut(ii)).sumcol
               mncol=rutas(rut(ii)).sumcol;
               prut=ii;
            end
        end
        % pos2: Guarda la posición de cada segundo en la variable segnodtot 
        %       por cada iteración de ruta principal obtenida con dirección 
        %       en prut.
        % contsegnod: Se incrementa en cada posición del arreglo de
        %             segundos nodos en cada enlace con el fin de tener en
        %             el total de veces que pasa cada ruta por el segundo
        %             nodo al final de las iteraciones.
        % gemelo: Guarda el número de nodos comunes entre el camino 
        %         principal y el camino obtenido como gemelo.
        pos2=find(segnodtot==rutas(rut(prut)).camino(2));
        contsegnod(pos2)=contsegnod(pos2)+1;
% %         % Se comprueba que el número de elementos no comunes es 1 para
% %         % escogerlo como gemelo y guardar la información del segundo nodo
% %         % de la ruta principal (nsg), la ruta principal (pri) y la ruta
% %         % secundaria (seg).
% %         % La variable posp se incrementa en uno para continuar con la
% %         % siguiente ruta, siempre y cuando ya se haya guardado los  datos
% %         % anteriores en el posp actual.
% %         % Escogida la ruta principal, se busca en cada lista del arreglo 
% %         % rutas,de cada nodo del grafo, si rut(prut) está en esa lista. Si
% %         % es así, se procede a crear un arreglo (pilaelim) de las rutas 
% %         % que están en esa lista y que no coinciden con rut(prut). Luego 
% %         % estas rutas en pilaelim se marcan con 1 en marca, porque no será 
% %         % utilizada posteriormente. La ruta de rut(prut) se marca con 2, 
% %         % porque es válida.
        pilaelim=[];
        for ii=1:length(nodosenruta)
            if ~isempty(find(nodosenruta(ii).lista==rut(prut)))
                ind=find(nodosenruta(ii).lista~=rut(prut));
                pilaelim=[pilaelim; nodosenruta(ii).lista(ind)];
            end
        end
        pilaelim=unique(pilaelim);
        marca(pilaelim)=1;
        for ii=1:length(pilaelim)
            rutas(pilaelim(ii)).camino=[];
        end
        for ii=1:length(nodosenruta)
            rutcomun=intersect(nodosenruta(ii).lista,pilaelim);
            for jj=1:length(rutcomun)
                poscom=find(nodosenruta(ii).lista==rutcomun(jj));
                nodosenruta(ii).lista(poscom)=[];
            end
        end  
        % Actualización de valores de colisiones y sumcol
        % Cálculo de colisiones por nodo
        colisiones=[];
        for ii=1:dest(nd)-1
            colisiones=[colisiones length(nodosenruta(ii).lista)];
        end
        % Cálculo de suma de colisiones por ruta
        for ii=1:length(rutas)
            rutas(ii).sumcol=0;
            for jj=1:length(rutas(ii).camino) - 1
                rutas(ii).sumcol=rutas(ii).sumcol + colisiones(rutas(ii).camino(jj));
            end
        end
        marca(rut(prut))=2;
    end 
    % Despliegue de los caminos válidos a partir de las rutas marcadas con
    % 2 en marca. En rutasval se guarda el índice de las rutas válidas y
    % luego estas se despliegan.
    % Cálculo del arreglo de contador de rutas flumaxrut. Esto corresponde 
    % al flujo máximo por cada destino.
    % segnod: Guarda la lista de los segundos nodos de cada ruta hacia
    %         nodos sumideros.
    % segnodsinuso: Guarda la lista de los segundos nodos de todas las 
    %               rutas que no han sido usados. Es lo mismo que
    %               segnodtot-segnod(nd).lista.
    rutasval=find(marca==2);
    segnod(nd).lista=[];
    for ii=1:length(rutasval)
        rutasdest(nd).rutamax(ii).camino=rutas(rutasval(ii)).camino;
        rutasdest(nd).rutamax(ii).numruta=rutasval(ii);
        segnod(nd).lista=[segnod(nd).lista rutasdest(nd).rutamax(ii).camino(2)];
        % TAL VEZ  QUITAR
        %if rutgem(nd).rseg==rutasval(ii)
        %    rutgem(nd).pri=[];
        %    rutgem(nd).seg=[];
        %end
        % FIN TAL VEZ QUITAR
    end
    flumaxrut=[flumaxrut length(rutasval)];
    %segnodsinuso=setdiff(segnodtot,segnod(nd).lista);  
    % Se borra la variable marca para iniciarla en el nuevo destino.
    clear marca;
end
% Agregado para verificar si de verdad está tomando los caminos más cortos
%
 for x=1:length(rutasdest)
     CC=zeros(nn);
     for y=1:length(rutasdest(x).rutamax)
         for z=1:length(rutasdest(x).rutamax(y).camino)-1
             CC(rutasdest(x).rutamax(y).camino(z),rutasdest(x).rutamax(y).camino(z+1))=1;
         end
     end
     ff_grafo(CC,rutasdest(x).rutamax(y).camino(end),[])
 end
 %Fin agregado