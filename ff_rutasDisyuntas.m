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
maxflujo=zeros(ndest,nn,nn);
for nd=1:ndest   
    tdr=ff_todas_las_rutas4(1,dest(nd),C);
    posi=zeros(length(tdr),nn);  
    long=[];
    marca(1,length(tdr))=0;
    % Cálculo de la longitud de cada ruta en tdr y cálculo de la matriz
    % posi.
    for ii=1:length(tdr)
%    rutas(ii).caminos=[];
        long = [long length(tdr(ii).camino)];
        for jj=1:length(tdr(ii).camino)
            posi(ii,tdr(ii).camino(jj))=1;
        end
    end
    % Cálculo de caminos que pasan por cada nodo desde un fuente a un
    % destino
    for ii=2:dest(nd) - 1
        rutas(ii).camino=find(posi(:,ii)==1);
    end
    % Cálculo de colisiones por nodo
    colisiones=[];
    for ii=1:dest(nd)-1
        colisiones=[colisiones length(rutas(ii).camino)];
    end
    % Cálculo de suma de colisiones por ruta
    for ii=1:length(tdr)
        tdr(ii).sumcol=0;
        for jj=1:length(tdr(ii).camino) - 1
            tdr(ii).sumcol=tdr(ii).sumcol + colisiones(tdr(ii).camino(jj));
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
        % de  rut está la ruta con menos colisiones.
        if length(rut)>=1 
            mncol=tdr(rut(1)).sumcol;
            prut=1;
            for ii=2:length(rut)
                if mncol > tdr(rut(ii)).sumcol
                    mncol=tdr(rut(ii)).sumcol;
                    prut=ii;
                end
            end
        end
        % Actualización de valores de colisiones y sumcol
%          for ii=1:length(tdr(rut(prut).camino))
%              colisiones(tdr(rut(prut)).camino(ii))=colisiones(tdr(rut(prut)).camino(ii))-1;
%          end
%         
%   
%         % Cálculo de suma de colisiones por ruta
%     for ii=1:length(tdr)
%         tdr(ii).sumcol=0;
%         for jj=1:length(tdr(ii).camino) - 1
%             tdr(ii).sumcol=tdr(ii).sumcol + colisiones(tdr(ii).camino(jj));
%         end
%     end
        
        % Escogida la ruta, se busca en cada camino del arreglo rutas,de 
        % cada nodo del grafo, si rut(prut) está en ese camino. Si es así, 
        % se procede a crear un arreglo (lista) ind de las rutas que están
        % en ese camino y que no coinciden con rut(prut). Luego estas rutas
        % en ind se marcan con 1 en marca, porque no será utilizada
        % posteriormente. La ruta de rut(prut) se marca con 2, porque es
        % válidad.
        pilaelim=[];
        for ii=1:length(rutas)
            if ~isempty(find(rutas(ii).camino==rut(prut)))
                ind=find(rutas(ii).camino~=rut(prut));
                for jj=1:length(ind)
                    rutelim=rutas(ii).camino(ind(jj));
                    pilaelim=[pilaelim rutelim];
                    marca(rutelim)=1;
                    tdr(rutelim).camino=[]; % Agregada
                    %for kk=1:length(rutas)
                    %    posrut=find(rutas(kk).camino==rutelim);
                    %    if ~isempty(posrut)
                    %        rutas(kk).camino(posrut)=[]; % Agregada
                    %    end
                    %end

                    %posrut=find(rutas(ii).camino==ind(jj)); % Agregada 2
                    %rutas(ii).camino(posrut)=[]; % Agregada 2
                end 
            end
            for jj=1:length(pilaelim)
                for kk=1:length(rutas)
                    posrut=find(rutas(kk).camino==rutelim);
                    if ~isempty(posrut)
                        rutas(kk).camino(posrut)=[]; % Agregada
                    end                    
                end
            end
        end
         %%%%%%%%%%%%%%%%%%%%%%
            % Cálculo de colisiones por nodo
     colisiones=[];
     for ii=1:dest(nd)-1
         colisiones=[colisiones length(rutas(ii).camino)];
     end
%     % Cálculo de suma de colisiones por ruta
     for ii=1:length(tdr)
         tdr(ii).sumcol=0;
         for jj=1:length(tdr(ii).camino) - 1
             tdr(ii).sumcol=tdr(ii).sumcol + colisiones(tdr(ii).camino(jj));
         end
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%5
        marca(rut(prut))=2;
    end
    % Despliegue de los caminos válidos a partir de las rutas marcadas con
    % 2 en marca. En rutasval se guarda el índice de las rutas válidas y
    % luego estas se despliegan.
    % Cálculo del arreglo de contador de rutas flumaxrut. Esto corresponde 
    % al flujo máximo por cada destino.
    % Creación del grafo de flujo (maxflujo) máximo para cada nodo
    display(strcat('Rutas válidas para ', int2str(dest(nd))));
    
    rutasval=find(marca==2);
    for ii=1:length(rutasval)
        tdrdest(nd).tdrmax(ii).camino=tdr(rutasval(ii)).camino;
        tdrdest(nd).tdrmax(ii).valido=true;
    end
    flumaxrut=[flumaxrut length(rutasval)];

    
    for ii=1:length(rutasval)
        display(tdrdest(nd).tdrmax(ii).camino);
        display(long(rutasval(ii)));
        for jj=1:length(tdrdest(nd).tdrmax(ii).camino) - 1
            maxflujo(nd,tdrdest(nd).tdrmax(ii).camino(jj),tdrdest(nd).tdrmax(ii).camino(jj+1))=1;
        end
    end
    
    mflujo=reshape(maxflujo(nd,:,:),[nn,nn]);
    display(mflujo);
    %view(biograph(mflujo,[],'ShowWeights','on'))
    % Se borra la variable marca para iniciarla en el nuevo destino.
    clear marca;
end
minflujo=min(flumaxrut);
dirflrut=find(flumaxrut~=minflujo);
for ii=1:length(dirflrut)
    for jj=1:flumaxrut(dirflrut(ii)) - minflujo
%         swrut=false;
%         while ~swrut
            vrut_max=0;
            for k=1:length(tdrdest(dirflrut(ii)).tdrmax)
                if tdrdest(dirflrut(ii)).tdrmax(k).valido && ...
                    length(tdrdest(dirflrut(ii)).tdrmax(k).camino) > vrut_max
                    vrut_max=length(tdrdest(dirflrut(ii)).tdrmax(k).camino);
                    pos_max=k;
                end
            end
%             swenc=false;
%             ij=1;
%             while ~swenc && ij<=length(tdrdest)
%                 while ik<=length(tdrdest(ij).tdrmax)
%                     if tdrdest(ij).tdrmax(ik).camino(2)==tdrdest(dir
%             
%             end
%         end
        tdrdest(dirflrut(ii)).tdrmax(pos_max).valido=false;
        x=1; %Aquí se puede  cambiar  por el nodo de  inicio, si es  diferente de  1
        for l_camino=2:length(tdrdest(dirflrut(ii)).tdrmax(pos_max).camino)
            y=tdrdest(dirflrut(ii)).tdrmax(pos_max).camino(l_camino);
            maxflujo(dirflrut(ii),x,y)=0; %0 por inf
            x=y;                
        end
   
    end
    mflujo=reshape(maxflujo(dirflrut(ii),:,:),[nn,nn]);
    %view(biograph(mflujo,[],'ShowWeights','on'))
end
minmaxflujo=zeros(nn,nn);
for ii=1:nd
    for jj=1:nn
        for kk=1:nn
            if maxflujo(ii,jj,kk) == 1
                minmaxflujo(jj,kk)= maxflujo(ii,jj,kk);
            end
        end
    end
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
fprintf('Flujo Maximo por Arco:\n');
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
