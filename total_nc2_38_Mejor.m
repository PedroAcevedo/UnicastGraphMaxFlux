%ELIMINACI�N DE LAS PRIMERAS RUTAS ENCONTRADAS Y NO CON M�S SALTOS
clc
clear all
ngrafo = input('Archivo de grafo = ', 's');
%ngrafo = strcat(ngrafo,'.txt'); 
nd = input('N�mero de destinos = ');
ngrafo = strcat(ngrafo,int2str(nd),'des.txt');
des.nodo = dlmread(ngrafo,' ', [1 0 1 nd-1]);
C = dlmread(ngrafo,' ',2,0);
nn = length(C);
fprintf('Nodos destinos\n');
disp(des.nodo);

%Presentaci�n del grafo formado por enrutadores, con capacidades m�ximas
fprintf('Capacidades m�ximas de cada nodo hacia sus destinos\n');
ff_escribirGrafo(C);
ff_grafo(C,des.nodo,[]);
% cm=sparse(C);
% h = view(biograph(cm,[],'ShowWeights','on'));
% set(h.Nodes(des.nodo(1,:)),'Color',[1 0 1]); 
%C�lculo del flujo m�ximo para cada nodo destino dentro del grafo, basado
%en la  aplicaci�n del algoritmo de Ford-Fulkerson. Se muestra el grafo de
%flujo m�ximo para cada nodo destino. El flujo m�ximo de cada nodo destino
%y su correspondiente grafo no ha sido comparado con el resto de grafos de
%flujos m�ximo para lograr obtener el m�nimo de los flujos que permitir�
%satisfacer la transmisi�n multicast con la aplicaci�n de network coding
%seg�n el  teorema de  Network Coding y Multicast.
%El grafo de flujo m�ximo de cada nodo destino se guarda en una matriz,
%formando una estructura tridimensional, donde el �ndice de cada p�gina
%corresponde con la de un nodo destino.
for i=1:nd
   [des.flumax(i),flujo_arcot,residual,corte]=ff_flujo_max_jm4(1,des.nodo(i),C,nn);
   fprintf('\n');
   fprintf('Flujo Maximo hacia el destino %.f es %.f\n\n',des.nodo(i),des.flumax(i));
   flujo_arco(i,:,:)=flujo_arcot;
   fprintf('Flujo de  arco hacia el destino %.f es \n',des.nodo(i));
   ff_escribirGrafo(flujo_arcot);
     ff_grafo(flujo_arcot,des.nodo(i),[]);
   %view(biograph(flujo_arcot,[],'ShowWeights','on'))
end
%B�squeda del menor de los flujos m�ximo y b�squda de los nodos con flujos
%m�ximo que superan al  menor de los flujos m�ximos con el fin de empezar 
%el proceso para igualar todos los flujos m�ximos de todos los
%nodos destinos.
fm_min=min(des.flumax); 
fm_mayp=find(des.flumax~=fm_min);
fm_mayv=des.flumax(des.flumax~=fm_min);
%Impresiones(a quitar) para mostrar el m�nimo flujo m�ximo, los nodos con flujo
%m�ximo por encima del m�nimo flujo m�ximo y los  valores de los flujos
%m�ximos por encima del m�nimo flujo m�ximo.
fprintf('Flujo minimo: %.f \n',fm_min);
fprintf('Flujos por fuera del m�nimo-posici�n \n\n');
disp(fm_mayp);
fprintf('Flujos por fuera del m�nimo-valor \n\n');
disp(fm_mayv);
%Fin de Impresiones a quitar
%Eliminaci�n de caminos en cada grafo de flujo m�ximo correspodiente a los
%nodos con flujo m�ximo por encima del m�nimo flujo m�ximo. 
for i=1:length(fm_mayp)
%    %L�neas a eliminar - solo para  mostrar proceso
%    fl_nod_com=reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]);
%    fprintf('fl\n\n');
%    ff_escribirGrafo(fl_nod_com);
%    fprintf('Valor destino %.f\n\n',des.nodo(fm_mayp(i)));
%    %Fin l�nea a eliminar
    %Llamado a funci�n nodos_com para calcular los nodos comunes que
    %comparten las distintas rutas desde el origen hasta un destino 
    %espec�fico en un grafo de flujo m�ximo. Es decir, si existe una ruta: 
    %s->a->b->f->h->j->t y otra ruta: s->c->d->e->f->g->h->k->t, luego los 
    %nodos f y h son nodos comunes a las dos rutas. Estos son nodos finales 
    %en alg�n arco de la ruta y ser�n importantes para poder determinar las 
    %rutas a eliminar. Despu�s que se calculan, se ordenan topol�gicamente. 
    n_com=ff_nodos_com(reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]),des.nodo(fm_mayp(i)),nn);
    n_com=sort(n_com);
 %   %Impresi�n a eliminar
 %   fprintf('N�mero de nodos comunes en %.f es: \n\n',des.nodo(fm_mayp(i)));
 %   disp(n_com);
 %   %Fin impresi�n a eliminar.
    %Si no existen nodos comunes en las rutas de un grafo de flujo m�ximo
    %para un destino espec�fico, se eliminan las rutas en el orden
    %secuencial en que se vayan encontrando hasta que el flujo m�ximo del
    %grafo sea igual al del m�nimo flujo m�ximo. Como una manera de
    %optimizarlo, se pueden eliminar las rutas con m�s saltos.
    for j=1:fm_mayv(i)-fm_min
%        rutas=ff_todas_las_rutas4(1,des.nodo(fm_mayp(i)),reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]));%,des.nodo);
        if isempty(n_com)
           x=1; %Aqu� se puede  cambiar  por el nodo de  inicio, si es  diferente de  1
           while (x~=des.nodo(fm_mayp(i)))
              a=find(flujo_arco(fm_mayp(i),x,:)~=0); %0 por inf
              y=a(1);
              flujo_arco(fm_mayp(i),x,y)=0; %0 por inf
              x=y;
           end        
        else
    %Si existen nodos comunes, con la funci�n ff_todas_las_rutas se
    %calculan todas las rutas en un grafo de flujo m�ximo desde el origen
    %hasta el destino. Este algoritmo se basa en una b�squeda en
    %profundidad en el grafo. 
    %Se establece un clico en el que se eliminan el n�mero de caminos
    %extras en cada uno de los grafos de flujo m�ximo que est�n por encima
    %del m�nimo flujo m�ximo. Se eliminan las rutas que contengan m�s nodos
    %comunes dentro del grafo de flujo m�ximo. Si una ruta contiene a todos
    %los nodos comunes, esta se escoge, sin buscar otra adicional. Si no se
    %encuentra una ruta con todos los nodos comunes se busca la que
    %contenga la mayor cantidad.
    %Despu�s que se ha eliminado una ruta por cumplir el requsito anterior,
    %se vuelven a calcular todas las rutas dentro del grafo de flujo m�ximo
    %para el nodo destino analizado y se vuelve a calcular los nodos
    %comunes. Por �ltimo se  ejecuta una nueva iteraci�n del ciclo.
           rutas=ff_todas_las_rutas4(1,des.nodo(fm_mayp(i)),reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]));%,des.nodo);
           fprintf('Hay %.f nodo(s) comun(es) para el destino %.f\n\n',length(n_com), des.nodo(fm_mayp(i)));
           fprintf('Colecci�n de todas las rutas \n\n');
           l_ncom=length(n_com);
           kk=1;
           sw_ncom=false;
           max_ncom=0;
           while kk<=length(rutas) && (~sw_ncom)
              fprintf('Ruta No. %.f :\n',kk);
              disp(rutas(kk).camino);
              l_inter=length(intersect(rutas(kk).camino,n_com));
              if l_inter==l_ncom;
                 sw_ncom=true;
                 pos_max_ncom=kk;
              else
                 if l_inter > max_ncom
                    max_ncom=l_inter;
                    pos_max_ncom=kk;
                 end
                 kk=kk+1;
              end
           end
           x=rutas(pos_max_ncom).camino(1);
           for l_camino=2:length(rutas(pos_max_ncom).camino)
               y=rutas(pos_max_ncom).camino(l_camino);
               flujo_arco(fm_mayp(i),x,y)=0; %0 por inf
               x=y;                
           end
           %VOLVER A CALCULAR LOS NODOS COMUNES-Revisar mejoras para
           %optimizarlo
           n_com=ff_nodos_com(reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]),des.nodo(fm_mayp(i)),nn);
           n_com=sort(n_com);
        end    
    end
    %Reimpresi�n de grafo mejorado en flujo m�ximo
    fl_arc_redim=reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]);
    %view(biograph(fl_arc_redim,[],'ShowWeights','on'));
end
%B�squeda del grafo general resultante m�nimo con base en los grafos de 
%flujo m�ximo de cada nodo ya igualados todos al m�nimo flujo m�ximo. Se
%busca el menor valor de flujo de cada uno de los enlaces dentro de los 
%grafos de flujos m�ximo. 
%Todos los enlaces no existentes en la matriz que repreenta al grafo,
%tienen asignado un cero (0) como valor del flujo. Estos valores son
%reemplazados por un 'inf' para evitar este valor como el m�nimo de los
%flujos de estos enlaces, luego se restituyen a cero nuevamente. 
flujo_arco(flujo_arco==0)=inf;
fl_arco_min=min(flujo_arco(:,:,:));
fa_min=reshape(fl_arco_min,[nn nn]); %redimensiona la matriz de tres dimensiones a dos
fa_min(fa_min==inf)=0;

%C�lculo de los nodos de codificaci�n en el grafo general de flujo m�ximo. 
nodos_cod=[];
kk=0;
for i=1:nn
    pred=find(fa_min(:,i)~=0);
    if length(pred)>1 && isempty(des.nodo(des.nodo==i))      
        nodos_cod=[nodos_cod i];
        kk=kk+1;
    end
end

ff_grafo(fa_min,des.nodo,nodos_cod);

swseguir=true;
segnodtot=find(fa_min(1,:)==1);
[fa_min, nodos_cod,swseguir,swp] = ff_opt_minflujo4(fm_min,nodos_cod,fa_min,des.nodo,segnodtot,swseguir);
while swseguir
    ff_grafo(fa_min,des.nodo,nodos_cod);
    [fa_min, nodos_cod,swseguir,swp] = ff_opt_minflujo4(fm_min,nodos_cod,fa_min,des.nodo,segnodtot,swseguir);
    if swp
        ff_grafo(fa_min,des.nodo,nodos_cod);
    end
end

%Generaci�n de archivo con nodos destinos, codificadores y grafo de flujo m�ximo
fprintf('Flujo Maximo por Arco:\n');
ff_escribirGrafo(fa_min);
ruta='C:\Users\Uninorte\Downloads\z3-4.5.0-x86-win\bin\';
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

% %Impresi�n del grafo de flujo m�ximo general.
% nc=view(biograph(fa_min,[],'ShowWeights','on'));
% set(nc.Nodes(des.nodo(1,:)),'Color',[1 0 1]);
% 
% %Impresi�n de los nodos de codificaci�n y se�alizaci�n en el grafo de flujo
% %m�ximo general.
% fprintf('Nodos de codificaci�n:\n');
% disp(nodos_cod);
% if ~isempty(nodos_cod)
%    set(nc.Nodes(nodos_cod(1,:)),'Color',[0 1 0]);
% end