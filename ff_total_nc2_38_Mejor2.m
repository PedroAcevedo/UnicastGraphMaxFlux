function [t_primer_camino,nenl] = ff_total_nc2_38_Mejor2(ngrafo)
%ELIMINACIÓN DE LAS PRIMERAS RUTAS ENCONTRADAS Y NO CON MÁS SALTOS
% clc
% clear all
% ngrafo = input('Archivo de grafo = ', 's');
% nd = input('Número de destinos = ');
% ngrafo = strcat(ngrafo,int2str(nd),'des.txt');
nd=ngrafo(strfind(ngrafo,'v')+1:strfind(ngrafo,'des')-1);
nd=str2num(nd);
des.nodo = dlmread(ngrafo,' ', [1 0 1 nd-1]);
C = dlmread(ngrafo,' ',2,0);
nn = length(C);
fprintf('Nodos destinos\n');
disp(des.nodo);
nenl=sum(sum(C));
dnenl=['Número de enlaces ' int2str(nenl)];
display(dnenl);

%Presentación del grafo formado por enrutadores, con capacidades máximas
fprintf('Capacidades máximas de cada nodo hacia sus destinos\n');
ff_escribirGrafo(C);
% ff_grafo(C,des.nodo,[]);
%Cálculo del flujo máximo para cada nodo destino dentro del grafo, basado
%en la  aplicación del algoritmo de Ford-Fulkerson. Se muestra el grafo de
%flujo máximo para cada nodo destino. El flujo máximo de cada nodo destino
%y su correspondiente grafo no ha sido comparado con el resto de grafos de
%flujos máximo para lograr obtener el mínimo de los flujos que permitirá
%satisfacer la transmisión multicast con la aplicación de network coding
%según el  teorema de  Network Coding y Multicast.
%El grafo de flujo máximo de cada nodo destino se guarda en una matriz,
%formando una estructura tridimensional, donde el índice de cada página
%corresponde con la de un nodo destino.
tic;
for i=1:nd
   [des.flumax(i),flujo_arcot,residual,corte]=ff_flujo_max_jm4(1,des.nodo(i),C,nn);
   fprintf('\n');
   fprintf('Flujo Maximo hacia el destino %.f es %.f\n\n',des.nodo(i),des.flumax(i));
   flujo_arco(i,:,:)=flujo_arcot;
   fprintf('Flujo de  arco hacia el destino %.f es \n',des.nodo(i));
   ff_escribirGrafo(flujo_arcot);
%    ff_grafo(flujo_arcot,des.nodo(i),[]);
   %view(biograph(flujo_arcot,[],'ShowWeights','on'))
end
%Búsqueda del menor de los flujos máximo y búsquda de los nodos con flujos
%máximo que superan al  menor de los flujos máximos con el fin de empezar 
%el proceso para igualar todos los flujos máximos de todos los
%nodos destinos.
fm_min=min(des.flumax); 
fm_mayp=find(des.flumax~=fm_min);
fm_mayv=des.flumax(des.flumax~=fm_min);
fprintf('Flujo minimo: %.f \n',fm_min);
fprintf('Flujos por fuera del mínimo-posición \n\n');
disp(fm_mayp);
fprintf('Flujos por fuera del mínimo-valor \n\n');
disp(fm_mayv);
%Eliminación de caminos en cada grafo de flujo máximo correspodiente a los
%nodos con flujo máximo por encima del mínimo flujo máximo. 
for i=1:length(fm_mayp)
    %se eliminan las rutas en el orden
    %secuencial en que se vayan encontrando hasta que el flujo máximo del
    %grafo sea igual al del mínimo flujo máximo. Como una manera de
    %optimizarlo, se pueden eliminar las rutas con más saltos.
    for j=1:fm_mayv(i)-fm_min
        x=1; %Aquí se puede  cambiar  por el nodo de  inicio, si es  diferente de  1
        while (x~=des.nodo(fm_mayp(i)))
            a=find(flujo_arco(fm_mayp(i),x,:)~=0); %0 por inf
            y=a(1);
            flujo_arco(fm_mayp(i),x,y)=0; %0 por inf
            x=y;
        end
    end
    %Reimpresión de grafo mejorado en flujo máximo
    fl_arc_redim=reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]);
%     ff_grafo(fl_arc_redim, des.nodo(fm_mayp(i)),[]);
end
%Búsqueda del grafo general resultante mínimo con base en los grafos de 
%flujo máximo de cada nodo ya igualados todos al mínimo flujo máximo. Se
%busca el menor valor de flujo de cada uno de los enlaces dentro de los 
%grafos de flujos máximo. 
%Todos los enlaces no existentes en la matriz que repreenta al grafo,
%tienen asignado un cero (0) como valor del flujo. Estos valores son
%reemplazados por un 'inf' para evitar este valor como el mínimo de los
%flujos de estos enlaces, luego se restituyen a cero nuevamente. 
flujo_arco(flujo_arco==0)=inf;
fl_arco_min=min(flujo_arco(:,:,:));
fa_min=reshape(fl_arco_min,[nn nn]); %redimensiona la matriz de tres dimensiones a dos
fa_min(fa_min==inf)=0;

%Cálculo de los nodos de codificación en el grafo general de flujo máximo. 
nodos_cod=[];
kk=0;
for i=1:nn
    pred=find(fa_min(:,i)~=0);
    if length(pred)>1 && isempty(des.nodo(des.nodo==i))      
        nodos_cod=[nodos_cod i];
        kk=kk+1;
    end
end

% ff_grafo(fa_min,des.nodo,nodos_cod);

swseguir=true;
segnodtot=find(fa_min(1,:)==1);
[fa_min, nodos_cod,swseguir,swp] = ff_opt_minflujo4(fm_min,nodos_cod,fa_min,des.nodo,segnodtot,swseguir);
while swseguir
%     ff_grafo(fa_min,des.nodo,nodos_cod);
    [fa_min, nodos_cod,swseguir,swp] = ff_opt_minflujo4(fm_min,nodos_cod,fa_min,des.nodo,segnodtot,swseguir);
    if swp
%         ff_grafo(fa_min,des.nodo,nodos_cod);
    end
end
t_primer_camino = toc;
%Generación de archivo con nodos destinos, codificadores y grafo de flujo máximo
fprintf('Flujo Maximo por Arco:\n');
ff_escribirGrafo(fa_min);
ruta='C:\Users\usuario\Downloads\z3-4.5.0-x86-win\bin\';
file=strcat(ruta,int2str(nn),'_nodes_graph_mf_',int2str(fm_min),'_ff4.ffm');
file_fa_min=fopen(file,'w');
for i=1:nd
  fprintf(file_fa_min,'%d ',des.nodo(i) - 1);
end
fprintf(file_fa_min,'\n');
for i=1:length(nodos_cod)
  fprintf(file_fa_min,'%d ',nodos_cod(i) - 1);
end
fprintf(file_fa_min,'\n');
for i=1:nn
    for j=1:nn
        fprintf(file_fa_min,'%d ',fa_min(i,j));
    end
    fprintf(file_fa_min,'\n');
end
fclose(file_fa_min);
end