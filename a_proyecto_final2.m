%% Documentacion
% Variables
% C: Matriz cuadrada de adyacencia y capacidades. Es una matriz de 1 y 0
%   
% dest: Vector con los destinos del grafo multicast
% 
% nn: Longitud de la matriz cuadrada C. Es el n�mero de nodos del grafo
% 1
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
tic
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
for nd = 1:ndest
    rutas = a_obtener_rutas(matpredsus(:,dest(nd)), max_d);
    fprintf('%s%2.0f\n','Todas las rutas que llegan a ', dest(nd));
    for jl = 1:length(rutas)
        fprintf('%2.0f %2.0f ',jl,rutas(jl).camino);
        fprintf('\n');
    end
    disjoints = Disjoints_routesv3(dest(nd),rutas);
    segnod(nd).lista = [];
    for ii=1:length(disjoints)
        rutasdest(nd).rutamax(ii).camino = rutas(disjoints(ii)).camino;
        rutasdest(nd).rutamax(ii).numruta = disjoints(ii);
        segnod(nd).lista = [segnod(nd).lista rutasdest(nd).rutamax(ii).camino(2)];
    end
    flumaxrut = [flumaxrut length(disjoints)];
end

for i=1:length(rutasdest)
    g = zeros(1,length(rutasdest(1).rutamax));
    for j=1:length(rutasdest(i).rutamax)
        g(j) = rutasdest(i).rutamax(j).numruta;
    end
    g = sort(g);
    disp(['#' mat2str(g)])
end

% for x = 1:length(rutasdest)
%     CC = zeros(nn);
%     for y = 1:length(rutasdest(x).rutamax)
%         for z = 1:length(rutasdest(x).rutamax(y).camino) - 1
%             CC(rutasdest(x).rutamax(y).camino(z), rutasdest(x).rutamax(y).camino(z+1)) = 1;
%         end
%     end
%     ff_grafo(CC,rutasdest(x).rutamax(y).camino(end),[]);
% end

       

minflujo=min(flumaxrut); % El mínimo flujo máximo de todos los flujos
dirflmin=find(flumaxrut==minflujo); % Rutas con mínimos flujos
% Se guarda la longitud de cada camino de nodo sumidero cuyo flujo sea
% mayor que el  flujo mínimo. 
% dirflrut: Guarda las posiciones de flumaxrut que tienen un valor mayor
%           que el flujo mínimo. Son los flujos a corregir. Si es vacío,
%  1         significa que todos los sumideros tienen sus rutas
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
% en las variables ii (posición de rutgem y a su vez de rutasdest) y jj 
% (posición de nsg dentro de rutgem). Luego se busca dentro de las segundas
% posiciones de los caminos de las rutamax del correspondiente rutasdest(ii)
% si se coincide con rutgem(ii).nsg(jj) y, cuando coincida, se cambia por
% el camino guardado en rutgem(ii).seg(jj).camino.
dirflrut=find(flumaxrut~=minflujo);  
if ~isempty(dirflrut)
% longitud: Es un arreglo de arreglos que guarda las longitudes de cada 
%         camino que corresponda con los nodos sumideros que tienen un
%         flujo máximo mayor que el mínimo.
    for ii=1:length(dirflrut)
        longitud=[];
        for jj=1:length(rutasdest(dirflrut(ii)).rutamax)
            longitud=[longitud length(rutasdest(dirflrut(ii)).rutamax(jj).camino)];
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
                    sumlong=sumlong + longitud(im);
                end
                if minlong > sumlong
                    minlong=sumlong;    
                    mincomun=comunsel;  %Cambiada de comun a comunsel
                end
            end
        end
% %     SEGMENTO A ELIMINAR
        % Disyuntas 4: Se genera en este segmento de código
        if length(mincomun)==minflujo % Agregado para disminuir el número de entradas a este segmento
            longcom=[];
            for jj=1:length(comtotal)
                indcom=find(segnod(dirflrut(ii)).lista==comtotal(jj)); %Cambié el índice segnod(dirflrut(ii)).lista
                longcom=[longcom longitud(indcom)];
            end
            if length(longcom)>=minflujo
                [longcom,poscom]=sort(longcom);
                nuelong=sum(longcom(1:minflujo));
                if nuelong<minlong
                    minlong=nuelong; % innecesario hacerlo ;)
                    mincomun=comtotal(poscom(1:minflujo));
                end
            end
        end
        numflujo=length(mincomun); %% Agregada después de desaparecer lo anterior
        usados=mincomun;
        segnodfaltantes=setdiff(segnod(dirflrut(ii)).lista,comtotal);
        longnodfaltantes=[];
        for jj=1:length(segnodfaltantes)
            rr=find(segnod(dirflrut(ii)).lista==segnodfaltantes(jj));
            longnodfaltantes=[longnodfaltantes longitud(rr)];
        end
        for jj=1:minflujo - numflujo
            menor=min(longnodfaltantes);
            rr=find(longnodfaltantes==menor);
            seg=segnodfaltantes(rr(1)); %% OJO CON ESTE CAMBIO DE ASIGNAR INDICE A rr
            usados=[usados seg];
            segnodfaltantes(rr(1))=[];  %% OJO Con este cambio pasé de  rr a rr(1). 24-02-18
            longnodfaltantes(rr(1))=[];  %% OJO Con este cambio pasé de  rr a rr(1). 
        end
        nousados=setdiff(segnod(dirflrut(ii)).lista,usados);
        for jj=1:length(nousados)
            rr=find(segnod(dirflrut(ii)).lista==nousados(jj));
            segnod(dirflrut(ii)).lista(rr)=[];
            rutasdest(dirflrut(ii)).rutamax(rr)=[];
        end
        dirflmin=[dirflmin dirflrut(ii)];  %%% OJO: SALIÓ DEL  FOR ANTERIOR
        %dirflrut(ii)=[];
        clear nuelong;
    end
end
%%%%% fin de lo agregado
%%%% OJOOOO MOVIDO
% for ii=1:length(segnodtot)
%     seglist(ii).segnod=segnodtot(ii);
%     seglist(ii).longitud=[];
%     seglist(ii).camino=[];
% end
% for nd=1:ndest
%     for ii=1:length(rutasdest(nd).rutamax)
%         posseg=find(segnodtot==rutasdest(nd).rutamax(ii).camino(2));
%         ncam=length(seglist(posseg).camino)+1;
%         seglist(posseg).longitud=[seglist(posseg).longitud ...
%             length(rutasdest(nd).rutamax(ii).camino)];
%         seglist(posseg).camino(ncam).posdest=nd;
%         seglist(posseg).camino(ncam).posmax=ii;
%         seglist(posseg).camino(ncam).ruta=rutasdest(nd).rutamax(ii).camino;
%     end
% end
% for ii=1:length(seglist)
%     ulong=unique(seglist(ii).longitud);
%     ocurre=zeros(numel(ulong),1);
%     for jj=1:length(ulong)
%         mascara = seglist(ii).longitud == ulong(jj);
%         ocurre(jj)=nnz(mascara);
%     end
%     if length(ocurre)~=ndest
%         for jj=1:length(ocurre)
%             if ocurre(jj)>1
%                 posrut=find(seglist(ii).longitud==ulong(jj));
%                 %nodosrec(1:ndest)=0;
%                 rutcom=seglist(ii).camino(posrut(1)).ruta(2:seglist(ii).longitud(posrut(1))-1);
%                 for kk=2:length(posrut)
%                     rutcom=intersect(rutcom,...
%                         seglist(ii).camino(posrut(kk)).ruta(2:seglist(ii).longitud(posrut(kk))-1));
%                 end
%                 poscambio=[];
%                 posini=[];
%                 %posfin=[];
%                 for kk=1:length(rutcom)-1
%                     for ll=1:length(posrut)
%                         rutap=seglist(ii).camino(posrut(ll)).ruta;
%                         posi=find(rutap==rutcom(kk));
%                         posf=find(rutap==rutcom(kk+1));
%                         dist=posf - posi;                       
%                         if ll==1 
%                             nodocambio=rutap(find(rutap==rutcom(kk))+1);
%                         end
%                         if dist==2
%                             poscambio=[poscambio posrut(ll)]; 
%                             posini=[posini posi];
%                             %posfin=[posfin posf];
%                         end
%                     end
%                     if ~isempty(poscambio)
%                         for ll=2:length(poscambio)
%                             inddest=seglist(ii).camino(poscambio(ll)).posdest;
%                             indmax=seglist(ii).camino(poscambio(ll)).posmax;
%                             rutasdest(inddest).rutamax(indmax).camino(posini(ll)+1)=nodocambio;
%                             %seglist(ii).camino(poscambio(ll)).ruta(posini(ll)+1)=nodocambio;
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
%%% OJO PARA VOLVER A BORRAR
minmaxflujo=zeros(nn,nn); % Iniciación de Matriz de flujos mínimos
for ii=1:length(dirflmin)
    for jj=1:minflujo  %% minflujo = length(rutasdest(dirflmin(ii)).rutamax)
        for kk=1:length(rutasdest(dirflmin(ii)).rutamax(jj).camino)-1
            minmaxflujo(rutasdest(dirflmin(ii)).rutamax(jj).camino(kk),...
                rutasdest(dirflmin(ii)).rutamax(jj).camino(kk+1))=1;
        end
    end
end
% Creación del grafo de flujo (maxflujo) máximo para cada nodo, despliegue
% de todas las rutas y del grafo de cada nodo sumidero.
for nd=1:ndest
   fprintf('%s %2.0f\n','Rutas válidas para ', dest(nd));
   for ii=1:length(rutasdest(nd).rutamax)
       fprintf('%2.0f ',rutasdest(nd).rutamax(ii).numruta);
       fprintf('%2.0f ',rutasdest(nd).rutamax(ii).camino);
       fprintf('\n');
       for jj=1:length(rutasdest(nd).rutamax(ii).camino) - 1
           maxflujo(nd,rutasdest(nd).rutamax(ii).camino(jj),rutasdest(nd).rutamax(ii).camino(jj+1))=1;
       end
   end   
   mflujo=reshape(maxflujo(nd,:,:),[nn,nn]);
   fprintf('%s %2.0f\n','Flujo Maximo por Arco para : ',dest(nd));
   ff_escribirGrafo(mflujo);
   %ff_grafo(mflujo,dest(nd),[]);
end
%Cálculo de los nodos de codificación en el grafo general de flujo máximo. 
nodos_cod=[];
for i=1:nn
    pred=find(minmaxflujo(:,i)~=0);
    if length(pred)>1 && isempty(dest(dest==i))      
        nodos_cod=[nodos_cod i];
    end
end

%ff_grafo(minmaxflujo,dest,nodos_cod);
% Reducción del grafo minmaxflujo para eliminar enlaces inútiles que
% deterioran la resolución con Network Coding
swseguir=true;

[minmaxflujo, nodos_cod,swseguir,swp] = ff_opt_minflujo4(minflujo,nodos_cod,minmaxflujo,dest,segnodtot,swseguir);
while swseguir
%     ff_grafo(minmaxflujo,dest,nodos_cod);
    [minmaxflujo, nodos_cod,swseguir,swp] = ff_opt_minflujo4(minflujo,nodos_cod,minmaxflujo,dest,segnodtot,swseguir);
    if swp
%         ff_grafo(minmaxflujo,dest,nodos_cod);
    end
end
toc
%Escritura de la matriz de  flujo máximo total (grafo de  flujo máximo
%general)
fprintf('Grafo General de Flujo Maximo por Arco:\n');
ff_escribirGrafo(minmaxflujo);

%Ruta en el PC de escritorio de la oficina
ruta='/home/pedross/Documents/PFiles/';
%Ruta en el portátil de la tesis:
%ruta='C:\Users\usuario\Downloads\z3-4.5.0z-x86-win\bin\';
%Ruta para que los archivos queden en Google Drive del portátil
%ruta='C:\Users\jmarquez\Google Drive\Jmarquez\Doctorado Ing. Sistemas\Tesis\SalidasGrafoUnicast';

file=strcat(ruta,int2str(nn),'_nodes_graph_mf_',int2str(minflujo),'_ff5p.ffm');
fprintf([int2str(nn) '_nodes_graph_mf_' int2str(minflujo) '_ff5p.ffm']);
file_fa_min=fopen(file,'w');
fprintf(file_fa_min,'%d ',nn);
fprintf(file_fa_min,'%d ',minflujo);
fprintf(file_fa_min,'%d ',ndest);
fprintf(file_fa_min,'\n');
for i=1:nd
  fprintf(file_fa_min,'%d ',dest(i) - 1);
end
fprintf(file_fa_min,'\n');
for i=1:nn
    for j=1:nn
        fprintf(file_fa_min,'%d ',minmaxflujo(i,j));
        %fprintf(file_fa_min,'%d ',minmaxflujo(i,j+1));
        %fprintf(file_fa_min,'	');
    end
    fprintf(file_fa_min,'\n');
end
fclose(file_fa_min);
