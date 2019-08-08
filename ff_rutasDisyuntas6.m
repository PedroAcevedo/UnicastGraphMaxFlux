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
% tdr: Matriz de todas las rutas desde el fuente hasta un sumidero en dest
%      tdr(i).camino: Es el camino i, constituido por k nodos desde el
%                     fuente hasta el sumidero en dest.
%      tdr(i).sumcol: Suma de colisiones en cada nodo del camino para la 
%                     ruta i
% posi: Matriz que indica que ruta pasa por cada nodo del grafo.
%       Tamaño de posi: Num de rutas x número de nodos
%       Valores: posi(k,l)=0: La ruta k, no pasa por el nodo l
%                posi(k,l)=1: la ruta k, pasa por el nodo l
% long: Vector de longitud de cada ruta o camino de tdr
% marca: Vector que indica si una ruta está seleccionada.
%        Tamaño de marca: Número de rutas en tdr.
%        Valores: marca(i)=0: No ha sido revisada la ruta i
%                 marca(i)=1: La ruta i no puede ser utilizada, coincide 
%                             con una seleccionada válida.
%                 marca(i)=2: Ruta seleccionada, y conlleva que se marquen 
%                             las rutas coicidentes con esta en los nodos, 
%                             con el valor 1 en todas las posiciones de
%                             posi donde aparezca.
%rutas: Guarda la secuencia rutas que pasan por cada nodo del grafo hasta 
%       ese destino(sumidero),sin incluirlo a él ni al fuente.
%       Cada posición del arreglo contiene un campo camino. Así
%       rutas(i).camino contiene todas las rutas(caminos) en tdr que pasan 
%       por el nodo i.
%       Tamaño: destino - 1
%colisiones: Arreglo que guarda el número de rutas que pasa por cada nodo.
%            Así colisiones(i) = k significa que k rutas de tdr pasan por
%            el  nodo i.
%            Tamaño: destino -1
                  
[C, dest]=ff_leerGrafo();
h=view(biograph(C,[],'ShowWeights','on'));
set(h.Nodes(dest),'Color',[1 0 1]);
nn=length(C);
ndest=length(dest);
flumaxrut=[];
segnodtot=find(C(1,:)==1);
contsegnod(1:(length(segnodtot)))=0;
maxflujo=zeros(ndest,nn,nn);
%%% DISYUNTAS 5: AGREGADO BÚSQUEDA DE TODOS LOS tdr y ordenamiento según
%%% longitud
for nd=1:ndest
    tdrtotal(nd).tdr=ff_todas_las_rutas4(1,dest(nd),C);
end
lon=[];
for nd=1:ndest
    lon=[lon length(tdrtotal(nd).tdr)];
end
[lonor indlon]=sort(lon);
for nd=1:ndest   
    %tdr=ff_todas_las_rutas4(1,dest(nd),C);
    %%% Agregadas para prueba
    fprintf('%s%2.0f\n','Rutas que pasan por cada nodo del grafo rumbo a ',dest(nd));
    fprintf('%s','   ');
    for jl=1:nn
        fprintf('%2.0f',jl);
    end
    fprintf('\n');
    id=indlon(nd);
    for jl=1:length(tdrtotal(id).tdr)
        fprintf('%2.0f ',jl)
        for ll=1:nn
            if ~isempty(find(tdrtotal(id).tdr(jl).camino==ll))
                fprintf('%s','x,');
            else
                fprintf('%s',' ,');
            end
        end
        fprintf('\n');
    end
    fprintf('%s%2.0f\n','Todas las rutas que llegan a ', dest(id));
    for jl=1:length(tdrtotal(id).tdr)
        fprintf('%2.0f %2.0f ',jl,tdrtotal(id).tdr(jl).camino);
        fprintf('\n');
    end
    %%% Fin agregadas para prueba
    
    posi=zeros(length(tdrtotal(id).tdr),nn);  
    long=[];
    marca(1,length(tdrtotal(id).tdr))=0;
    % Cálculo de la longitud de cada ruta en tdr y cálculo de la matriz
    % posi.
    for ii=1:length(tdrtotal(id).tdr)
        long = [long length(tdrtotal(id).tdr(ii).camino)];
        for jj=1:length(tdrtotal(id).tdr(ii).camino)
            posi(ii,tdrtotal(id).tdr(ii).camino(jj))=1;
        end
    end
    % Cálculo de caminos que pasan por cada nodo desde un fuente a un
    % destino
    for ii=2:dest(id) - 1
        rutas(ii).camino=find(posi(:,ii)==1);
    end
    % Cálculo de colisiones por nodo
    colisiones=[];
    for ii=1:dest(id)-1
        colisiones=[colisiones length(rutas(ii).camino)];
    end
    % Cálculo de suma de colisiones por ruta
    for ii=1:length(tdrtotal(id).tdr)
        tdrtotal(id).tdr(ii).sumcol=0;
        for jj=1:length(tdrtotal(id).tdr(ii).camino) - 1
            tdrtotal(id).tdr(ii).sumcol=tdrtotal(id).tdr(ii).sumcol + ...
                colisiones(tdrtotal(id).tdr(ii).camino(jj));
        end
    end
    rutgem(nd).pri=[];
    rutgem(nd).seg=[];
    posp=1; % posición de la ruta primaria en rutgem
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
        mncol=tdrtotal(id).tdr(rut(1)).sumcol;
        sgcol=mncol;
        prut=1;
        srut=1;
        for ii=2:length(rut)
            if mncol > tdrtotal(id).tdr(rut(ii)).sumcol
               sgcol=mncol;
               mncol=tdrtotal(id).tdr(rut(ii)).sumcol;
               srut=prut;
               prut=ii;
            else
               if mncol<=tdrtotal(id).tdr(rut(ii)).sumcol
                  if sgcol>tdrtotal(id).tdr(rut(ii)).sumcol || sgcol==mncol %la segunda puede ser solo cuando el menor es el primero de la lista
                     sgcol=tdrtotal(id).tdr(rut(ii)).sumcol;
                     srut=ii;
                  end
               end
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
        pos2=find(segnodtot==tdrtotal(id).tdr(rut(prut)).camino(2));
        contsegnod(pos2)=contsegnod(pos2)+1;
        gemelo=intersect(tdrtotal(id).tdr(rut(prut)).camino, ...
            tdrtotal(id).tdr(rut(srut)).camino);
        % Se comprueba que el número de elementos no comunes es 1 para
        % escogerlo como gemelo y guardar la información del segundo nodo
        % de la ruta principal (nsg), la ruta principal (pri) y la ruta
        % secundaria (seg).
        % La variable posp se incrementa en uno para continuar con la
        % siguiente ruta, siempre y cuando ya se haya guardado los  datos
        % anteriores en el posp actual.
        if mn-length(gemelo)==1
            rutgem(nd).nsg(posp)=tdrtotal(id).tdr(rut(prut)).camino(2);
            %%%% TAL VEZ QUITAR
            %rutgem(nd).rpri=rut(prut);
            %rutgem(nd).rseg=rut(srut);
            %%%% TAL VEZ QUITAR
            rutgem(nd).pri(posp).camino=tdrtotal(id).tdr(rut(prut)).camino;
            rutgem(nd).seg(posp).camino=tdrtotal(id).tdr(rut(srut)).camino;
            posp=posp+1;
        end      
        % Escogida la ruta principal, se busca en cada camino del arreglo 
        % rutas,de cada nodo del grafo, si rut(prut) está en ese camino. Si
        % es así, se procede a crear un arreglo (lista) ind de las rutas 
        % que están en ese camino y que no coinciden con rut(prut). Luego 
        % estas rutas en ind se marcan con 1 en marca, porque no será 
        % utilizada posteriormente. La ruta de rut(prut) se marca con 2, 
        % porque es válida.
        pilaelim=[];
        for ii=1:length(rutas)
            if ~isempty(find(rutas(ii).camino==rut(prut)))
                ind=find(rutas(ii).camino~=rut(prut));
                pilaelim=[pilaelim; rutas(ii).camino(ind)];
            end
        end
        pilaelim=unique(pilaelim);
        marca(pilaelim)=1;
        for ii=1:length(pilaelim)
            tdrtotal(id).tdr(pilaelim(ii)).camino=[];
        end
        for ii=1:length(rutas)
            rutcomun=intersect(rutas(ii).camino,pilaelim);
            for jj=1:length(rutcomun)
                poscom=find(rutas(ii).camino==rutcomun(jj));
                rutas(ii).camino(poscom)=[];
            end
        end  
        % Actualización de valores de colisiones y sumcol
        % Cálculo de colisiones por nodo
        colisiones=[];
        for ii=1:dest(nd)-1
            colisiones=[colisiones length(rutas(ii).camino)];
        end
        % Cálculo de suma de colisiones por ruta
        for ii=1:length(tdrtotal(id).tdr)
            tdrtotal(id).tdr(ii).sumcol=0;
            for jj=1:length(tdrtotal(id).tdr(ii).camino) - 1
                tdrtotal(id).tdr(ii).sumcol=tdrtotal(id).tdr(ii).sumcol + ...
                    colisiones(tdrtotal(id).tdr(ii).camino(jj));
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
        tdrdest(nd).tdrmax(ii).camino=tdrtotal(id).tdr(rutasval(ii)).camino;
        tdrdest(nd).tdrmax(ii).numruta=rutasval(ii);
        segnod(nd).lista=[segnod(nd).lista tdrdest(nd).tdrmax(ii).camino(2)];
        %%% TAL VEZ  QUITAR
        %if rutgem(nd).rseg==rutasval(ii)
        %    rutgem(nd).pri=[];
        %    rutgem(nd).seg=[];
        %end
        %%% FIN TAL VEZ QUITAR
    end
    flumaxrut=[flumaxrut length(rutasval)];
    %segnodsinuso=setdiff(segnodtot,segnod(nd).lista);  
    % Se borra la variable marca para iniciarla en el nuevo destino.
    clear marca;
end
minflujo=min(flumaxrut); % El mínimo flujo máximo de todos los flujos
dirflmin=find(flumaxrut==minflujo); % Rutas con mínimos flujos
minmaxflujo=zeros(nn,nn); % Iniciación de Matriz de flujos mínimos
% Se guarda la longitud de cada camino de nodo sumidero cuyo flujo sea
% mayor que el  flujo mínimo. 
% dirflrut: Guarda las posiciones de flumaxrut que tienen un valor mayor
%           que el flujo mínimo. Son los flujos a corregir. Si es vacío,
%           significa que todos los sumideros tienen sus rutas
%           correspondientes al minflujo completas. Ahora se debe buscar si
%           estas rutas están bien repartidas; es decir, se deben
%           reacomodar las rutas que contengan en sus conteo de nodos
%           segundos (contsegnod) un número menor que el número de destinos
%           (ndest). 
% rutincom: Guarda las posiciones en contsegnod que son menores que el
%           número de sumideros. Es decir, las que no cumplen con el número
%           máximo de sumideros. Estas posiciones coinciden con las
%           posiciones de segnodtot. 
% segnodinc: Guarda los segundos nodos que no cumplen en el conteo
%            explicado para ruticom.
% Se busca la posición del segundo nodo (nsg) que cumpla con algún nodo en
% segnodinc calculado previamente. Esta posición encontrada queda guardada
% en las variables ii (posición de rutgem y a su vez de tdrdest) y jj 
% (posición de nsg dentro de rutgem). Luego se busca dentro de las segundas
% posiciones de los caminos de los tdrmax del correspondiente tdrdest(ii)
% si se coincide con rutgem(ii).nsg(jj) y, cuando coincida, se cambia por
% el camino guardado en rutgem(ii).seg(jj).camino.
dirflrut=find(flumaxrut~=minflujo); 
%%% DISYUNTAS 5: DESDE AQUI ELIMINNO Y MUEVO
%if isempty(dirflrut)
%     rutincom=find(contsegnod<minflujo);
%     if ~isempty(rutincom)
%         segnodinc=segnodtot(rutincom);    
%         swenc=false;
%         ii=1;
%         while ~swenc && ii<=length(rutgem)
%             jj=1;
%             while ~swenc && jj<=length(rutgem(ii).nsg)
%                 kk=1;
%                 while ~swenc && kk<=length(segnodinc)
%                     if rutgem(ii).nsg(jj)==segnodinc(kk)
%                         swenc=true;
%                     else
%                         kk=kk+1;
%                     end
%                 end
%                 if ~swenc
%                     jj=jj+1;
%                 end
%             end
%             if ~swenc
%                 ii=ii+1;
%             end                
%         end
%         if swenc
%             swenc=false;
%             pp=1;
%             while ~swenc && pp<=length(tdrdest(ii).tdrmax)
%                 if tdrdest(ii).tdrmax(pp).camino(2)==rutgem(ii).nsg(jj)
%                     swenc=true;
%                     tdrdest(ii).tdrmax(pp).camino=rutgem(ii).seg(jj).camino;
%                 else
%                     pp=pp+1;
%                 end
%             end
%             % rn: Posición en segnodtot donde está la ruta gemela que se va a
%             % cambiar
%             rn=find(rutgem(ii).seg(jj).camino(2)==segnodtot);
%             % Actualización de contsegnod para la ruta gemela sumando 1
%             contsegnod(rn)=contsegnod(rn)+1;
%             % rv: Posición en segnodtot donde está la ruta caduca que se va a
%             % cambiar
%             rv=find(rutgem(ii).nsg(jj)==segnodtot);
%             % Actualización de contsegnod para la ruta eliminada restanto 1
%             contsegnod(rv)=contsegnod(rv)-1;       
%         end
% 
%     end  
%else
% FIN CAMBIO PARA DISYUNTAS 5
%   
% flumay: Es un arreglo de arreglos que guarda las longitudes de cada 
%         camino que corresponda con los nodos sumideros que tienen un
%         flujo máximo mayor que el mínimo.
    for ii=1:length(dirflrut)
        flumay(ii).long=[];
        for jj=1:length(tdrdest(dirflrut(ii)).tdrmax)
            flumay(ii).long=[flumay(ii).long length(tdrdest(dirflrut(ii)).tdrmax(jj).camino)];
        end
        minlong=inf;
        comtotal=[];
        difcomun=length(segnod(dirflrut(ii)).lista);  % Agregada
        mejorcomun=false;  %Agregada
        mincomun=[]; %AGREGADO PARA PROBAR
        for jj=1:length(dirflmin)
            comun=intersect(segnod(dirflrut(ii)).lista,segnod(dirflmin(jj)).lista);     
            comtotal=union(comtotal,comun);
            %Agregada para seleccionar el mejor comun
            nuevocomun=false;  %Determinar si calculará un nuevo común o se  mantiene el del ciclo anterior
            if length(comun)==minflujo
                comunsel=comun;
                nuevocomun=true;
                if ~mejorcomun
                    minlong=inf;
                    mejorcomun=true;
                end
            else
                if ~mejorcomun
                    if length(segnod(dirflrut(ii)).lista)-length(comun)<difcomun
                        difcomun=length(segnod(dirflrut(ii)).lista)-length(comun);
                        comunsel=comun;
                        nuevocomun=true;
                    %else
                    %if _________= difcomun
                    %   saca a probar los gemelos del grupo que está en
                    %   análisis. Si el primer gemelo resulta con dif
                    end
                end
            end
            if nuevocomun %evita que se repita el ciclo con el común del ciclo  anterior   
                sumlong=0;
                for kk=1:length(comunsel) %Cambiada de comun a comunsel
                    im=find(segnod(dirflrut(ii)).lista==comunsel(kk)); % comun a comunsel
                    sumlong=sumlong + flumay(ii).long(im);
                end
                if minlong > sumlong
                    minlong=sumlong;
                    mincomun=comunsel;  %Cambiada de comun a comunsel
                end
            end
        end
        numflujo=0;
        %% Disyuntas 4: Se genera en este segmento de código
        %if length(comtotal)>=minflujo
            longcom=[];
            for  jj=1:length(comtotal)
                indcom=find(segnod(ii).lista==comtotal(jj));
                longcom=[longcom flumay(ii).long(indcom)];
            end
            [longcom,poscom]=sort(longcom);
        if length(longcom)>=minflujo 
            nuelong=sum(longcom(1:minflujo));
            if nuelong<minlong
                minlong=nuelong; % innecesario hacerlo ;)
                mincomun=comtotal(poscom(1:minflujo));
            end
        end
        %% Fin de Agregado Disyuntas 4
        if ~isempty(mincomun) %% AGREGADO PARA  PROBAR
            for jj=1:length(tdrdest(dirflrut(ii)).tdrmax)
                if ~isempty(find(tdrdest(dirflrut(ii)).tdrmax(jj).camino(2)==mincomun))
                    for kk=1:length(tdrdest(dirflrut(ii)).tdrmax(jj).camino)-1
                        minmaxflujo(tdrdest(dirflrut(ii)).tdrmax(jj).camino(kk),...
                            tdrdest(dirflrut(ii)).tdrmax(jj).camino(kk+1))=1;
                    end
                    numflujo=numflujo+1;
                end
            end
        end  %FIN DE AGREGADO PARA PROBAR
        usados=mincomun;
        %comtotal=unique(comtotal);
        segnodfaltantes=setdiff(segnod(dirflrut(ii)).lista,comtotal);
        longnodfaltantes=[];
        for jj=1:length(segnodfaltantes)
            rr=find(segnod(dirflrut(ii)).lista==segnodfaltantes(jj));
            longnodfaltantes=[longnodfaltantes flumay(ii).long(rr)];
        end
        for jj=1:minflujo - numflujo
            menor=min(longnodfaltantes);
            rr=find(longnodfaltantes==menor);
            seg=segnodfaltantes(rr(1)); %% OJO CON ESTE CAMBIO DE ASIGNAR INDICE A rr
            usados=[usados seg];
          %  for kk=1:length(seg)
          %      lpos=find(segnod(dirflrut(ii)).lista==seg(kk));
                lpos=find(segnod(dirflrut(ii)).lista==seg);
                for ll=1:length(tdrdest(dirflrut(ii)).tdrmax(lpos).camino)-1
                    minmaxflujo(tdrdest(dirflrut(ii)).tdrmax(lpos).camino(ll),...
                        tdrdest(dirflrut(ii)).tdrmax(lpos).camino(ll+1))=1;
                end
            %end
            segnodfaltantes(rr)=[];
            longnodfaltantes(rr)=[];
        end
        nousados=setdiff(segnod(dirflrut(ii)).lista,usados);
    %%% FALTA ELIMINAR LAS RUTAS DEL VECTOR nousados, teniendo en cuenta
    %%% que estos son los segundos  nodos también y hay que buscar su ruta
    %%% verdadera con un find. También hay que eliminar el segnodo de esta
    %%% ruta. Por ejemplo, si  en segnodo hay tres entradas y en nousados
    %%% hay una entrada, se elimina de segnodo.
        for jj=1:length(nousados)
            rr=find(segnod(dirflrut(ii)).lista==nousados(jj));
            segnod(dirflrut(ii)).lista(rr)=[];
            tdrdest(dirflrut(ii)).tdrmax(rr)=[];
        end
        dirflmin=[dirflmin dirflrut(ii)];  %%% OJO: SALIÓ DEL  FOR ANTERIOR
        %dirflrut(ii)=[];
    end
    
    rutincom=find(contsegnod<minflujo);
    if ~isempty(rutincom)
        segnodinc=segnodtot(rutincom);    
        swenc=false;
        ii=1;
        while ~swenc && ii<=length(rutgem)
            jj=1;
            while ~swenc && jj<=length(rutgem(ii).nsg)
                kk=1;
                while ~swenc && kk<=length(segnodinc)
                    if rutgem(ii).nsg(jj)==segnodinc(kk)
                        swenc=true;
                    else
                        kk=kk+1;
                    end
                end
                if ~swenc
                    jj=jj+1;
                end
            end
            if ~swenc
                ii=ii+1;
            end                
        end
        if swenc
            swenc=false;
            pp=1;
            while ~swenc && pp<=length(tdrdest(ii).tdrmax)
                if tdrdest(ii).tdrmax(pp).camino(2)==rutgem(ii).nsg(jj)
                    swenc=true;
                    tdrdest(ii).tdrmax(pp).camino=rutgem(ii).seg(jj).camino;
                else
                    pp=pp+1;
                end
            end
            % rn: Posición en segnodtot donde está la ruta gemela que se va a
            % cambiar
            rn=find(rutgem(ii).seg(jj).camino(2)==segnodtot);
            % Actualización de contsegnod para la ruta gemela sumando 1
            contsegnod(rn)=contsegnod(rn)+1;
            % rv: Posición en segnodtot donde está la ruta caduca que se va a
            % cambiar
            rv=find(rutgem(ii).nsg(jj)==segnodtot);
            % Actualización de contsegnod para la ruta eliminada restanto 1
            contsegnod(rv)=contsegnod(rv)-1;       
        end
    end  

%end %fin 273
%%%%% fin de lo agregado
%%%% OJOOOO MOVIDO
for ii=1:length(segnodtot)
    seglist(ii).segnod=segnodtot(ii);
    seglist(ii).longitud=[];
    seglist(ii).camino=[];
end
for nd=1:ndest
    for ii=1:length(tdrdest(nd).tdrmax)
        posseg=find(segnodtot==tdrdest(nd).tdrmax(ii).camino(2));
        ncam=length(seglist(posseg).camino)+1;
        seglist(posseg).longitud=[seglist(posseg).longitud ...
            length(tdrdest(nd).tdrmax(ii).camino)];
        seglist(posseg).camino(ncam).posdest=nd;
        seglist(posseg).camino(ncam).posmax=ii;
        seglist(posseg).camino(ncam).ruta=tdrdest(nd).tdrmax(ii).camino;
    end
end
for ii=1:length(seglist)
    ulong=unique(seglist(ii).longitud);
    ocurre=zeros(numel(ulong),1);
    for jj=1:length(ulong)
        mascara = seglist(ii).longitud == ulong(jj);
        ocurre(jj)=nnz(mascara);
    end
    if length(ocurre)~=ndest
        for jj=1:length(ocurre)
            if ocurre(jj)>1
                posrut=find(seglist(ii).longitud==ulong(jj));
                %nodosrec(1:ndest)=0;
                rutcom=seglist(ii).camino(posrut(1)).ruta(2:seglist(ii).longitud(posrut(1))-1);
                for kk=2:length(posrut)
                    rutcom=intersect(rutcom,...
                        seglist(ii).camino(posrut(kk)).ruta(2:seglist(ii).longitud(posrut(kk))-1));
                end
                poscambio=[];
                posini=[];
                %posfin=[];
                for kk=1:length(rutcom)-1
                    for ll=1:length(posrut)
                        rutap=seglist(ii).camino(posrut(ll)).ruta;
                        posi=find(rutap==rutcom(kk));
                        posf=find(rutap==rutcom(kk+1));
                        dist=posf - posi;                       
                        if ll==1 
                            nodocambio=rutap(find(rutap==rutcom(kk))+1);
                        end
                        if dist==2
                            poscambio=[poscambio posrut(ll)]; 
                            posini=[posini posi];
                            %posfin=[posfin posf];
                        end
                    end
                    if ~isempty(poscambio)
                        for ll=2:length(poscambio)
                            inddest=seglist(ii).camino(poscambio(ll)).posdest;
                            indmax=seglist(ii).camino(poscambio(ll)).posmax;
                            tdrdest(inddest).tdrmax(indmax).camino(posini(ll)+1)=nodocambio;
                            %seglist(ii).camino(poscambio(ll)).ruta(posini(ll)+1)=nodocambio;
                        end
                    end
                end
            end
        end
    end
end

for ii=1:length(dirflmin)
    for jj=1:length(tdrdest(dirflmin(ii)).tdrmax)
        for kk=1:length(tdrdest(dirflmin(ii)).tdrmax(jj).camino)-1
            minmaxflujo(tdrdest(dirflmin(ii)).tdrmax(jj).camino(kk),...
                tdrdest(dirflmin(ii)).tdrmax(jj).camino(kk+1))=1;
        end
    end
end
% Creación del grafo de flujo (maxflujo) máximo para cada nodo, despliegue
% de todas las rutas y del grafo de cada nodo sumidero.
for nd=1:ndest
   fprintf('%s %2.0f\n','Rutas válidas para ', dest(nd));
   for ii=1:length(tdrdest(nd).tdrmax)
       fprintf('%2.0f ',tdrdest(nd).tdrmax(ii).numruta);
       fprintf('%2.0f ',tdrdest(nd).tdrmax(ii).camino);
       fprintf('\n');
       for jj=1:length(tdrdest(nd).tdrmax(ii).camino) - 1
           maxflujo(nd,tdrdest(nd).tdrmax(ii).camino(jj),tdrdest(nd).tdrmax(ii).camino(jj+1))=1;
       end
   end   
   mflujo=reshape(maxflujo(nd,:,:),[nn,nn]);
   fprintf('%s %2.0f\n','Flujo Maximo por Arco para : ',dest(nd));
   ff_escribirGrafo(mflujo);
   view(biograph(mflujo,[],'ShowWeights','on'))
end
%Cálculo de los nodos de codificación en el grafo general de flujo máximo. 
nodos_cod=[];
for i=1:nn
    pred=find(minmaxflujo(:,i)~=0);
    if length(pred)>1 && isempty(dest(dest==i))      
        nodos_cod=[nodos_cod i];
    end
end
% Impresión de  Grafo de flujo máximo
nc=view(biograph(minmaxflujo,[],'ShowWeights','on'));
set(nc.Nodes(dest(1,:)),'Color',[1 0 1]);
if ~isempty(nodos_cod)
    set(nc.Nodes(nodos_cod(1,:)),'Color',[0 1 0]);
end
%Impresión de la matriz de  flujo máximo total (grafo de  flujo máximo
%general)
fprintf('Grafo General de Flujo Maximo por Arco:\n');
ff_escribirGrafo(minmaxflujo);
ruta='C:\Users\usuario\Downloads\z3-4.5.0-x86-win\bin\';
file=strcat(ruta,int2str(nn),'_nodes_graph_mf_',int2str(minflujo),'_ff5.ffm');
file_fa_min=fopen(file,'w');
for i=1:nd
  fprintf(file_fa_min,'%d ',dest(i) - 1);
end
fprintf(file_fa_min,'\n');
for i=1:length(nodos_cod)
  fprintf(file_fa_min,'%d ',nodos_cod(i) - 1);
end
fprintf(file_fa_min,'\n');
for i=1:nn
    for j=1:nn
        fprintf(file_fa_min,'%d ',minmaxflujo(i,j));
    end
    fprintf(file_fa_min,'\n');
end
fclose(file_fa_min);
