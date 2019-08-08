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

%C�lculo del flujo m�ximo para cada nodo destino dentro del grafo, basado
%en la  aplicaci�n del algoritmo del Ford-Fulkerson. Se muestra el grafo de
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
  end
%B�squeda del menor de los flujos m�ximo y b�squda de los nodos con flujos
%m�ximo que superan al  menor de los flujos m�ximos con el fin de empezar 
%el proceso para igualar todos los flujos m�ximos de todos los nodos
%destinos al m�nimo. Se busca la posici�n y el valor dentro del vector de
%destinos de los que tienen flujo m�ximo por encima del m�nimo.
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
    %L�neas a eliminar - solo para  mostrar proceso
%    fl_nod_com=reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]);
%    fprintf('fl\n\n');
%    disp(fl_nod_com);
%    fprintf('Valor destino %.f\n\n',des.nodo(fm_mayp(i)));
    %Fin l�nea a eliminar
    %Llamado a funci�n nodos_com para calcular los nodos comunes que
    %comparten las distintas rutas desde el origen hasta un destino 
    %espec�fico en un grafo de flujo m�ximo. Es decir, si existe una ruta: 
    %s->a->b->f->h->j->t y otra ruta: s->c->d->e->f->g->h->k->t, luego los 
    %nodos f y h son nodos comunes a las dos rutas. Estos son nodos finales 
    %en alg�n arco de la ruta y ser�n importantes para poder determinar las 
    %rutas a eliminar. Despu�s que se calculan, se ordenan topol�gicamente. 
    n_com=ff_nodos_com(reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]),des.nodo(fm_mayp(i)),nn);
    n_com=sort(n_com);
    %Impresi�n a eliminar
 %   fprintf('N�mero de nodos comunes en %.f es: \n\n',des.nodo(fm_mayp(i)));
 %   disp(n_com);
    %Fin impresi�n a eliminar.
    for j=1:fm_mayv(i)-fm_min
        rutas=ff_todas_las_rutas4(1,des.nodo(fm_mayp(i)),reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]));
         % 
        %Si no existen nodos comunes en las rutas de un grafo de flujo m�ximo
        %para un destino espec�fico, se eliminan las rutas con m�s saltos.
        %
        if isempty(n_com)
           vrut_max=0;
           for k=1:length(rutas)
               if length(rutas(k).camino)>vrut_max
                   vrut_max=length(rutas(k).camino);
                   pos_max=k;
               end
           end
           x=1; %Aqu� se puede  cambiar  por el nodo de  inicio, si es  diferente de  1
           for l_camino=2:length(rutas(pos_max).camino)
               y=rutas(pos_max).camino(l_camino);
               flujo_arco(fm_mayp(i),x,y)=0; %0 por inf
               x=y;                
           end
%Merece revisi�n           rutas(pos_max)=[];
%           while (x~=des.nodo(fm_mayp(i)))
%               a=find(flujo_arco(fm_mayp(i),x,:)~=0); %0 por inf
%               y=a(1);
%               flujo_arco(fm_mayp(i),x,y)=0; %0 por inf
%               x=y;
%           end        
        else
    %Si existen nodos comunes, con la funci�n ff_todas_las_rutas se
    %calculan todas las rutas en un grafo de flujo m�ximo desde el origen
    %hasta el destino. Este algoritmo se basa en una b�squeda en
    %profundidad en el grafo. 
    %Se establece un ciclo en el que se eliminan el n�mero de caminos
    %extras en cada uno de los grafos de flujo m�ximo que est�n por encima
    %del m�nimo flujo m�ximo. Se eliminan las rutas que contengan m�s nodos
    %comunes dentro del grafo de flujo m�ximo. Si una ruta contiene a todos
    %los nodos comunes, esta se escoge, sin buscar otra adicional. Si no se
    %encuentra una ruta con todos los nodos comunes se busca la que
    %contenga la mayor cantidad.
    %Despu�s que se ha eliminado una ruta por cumplir el requsito anterior,
    %se vuelven a calcular todas las rutas dentro del grafo de flujo m�ximo
    %para el nodo destino analizado y se vuelven a calcular los nodos
    %comunes. Por �ltimo se  ejecuta una nueva iteraci�n del ciclo.
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
%          rutas(pos_max_ncom)=[];
          %VOLVER A LLAMAR EL ALGORITMO DE TODAS LAS RUTAS
%llamado a rutas eliminado          rutas=ff_todas_las_rutas(1,des.nodo(fm_mayp(i)),reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]));
          %VOLVER A CALCULAR LOS NODOS COMUNES-Revisar mejoras para
          %optimizarlo
%eliminado          n_com=nodos_com(reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]),des.nodo(fm_mayp(i)),nn);
%eliminado          n_com=sort(n_com);
        end    
    end
    %Reimpresi�n de grafo mejorado en flujo m�ximo
    fl_arc_redim=reshape(flujo_arco(fm_mayp(i),:,:),[nn,nn]);
%     ff_grafo(fl_arc_redim, des.nodo(fm_mayp(i)),[]);
end
%B�squeda del grafo general resultante m�nimo con base en los grafos de 
%flujo m�ximo de cada nodo ya igualados todos al m�nimo flujo m�ximo. Se
%busca el menor valor de flujo de cada uno de los enlaces dentro de los 
%grafos de flujos m�ximo. 
%Todos los enlaces no existentes en la matriz que representa al grafo,
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

%Graficaci�n de grafo general de flujo m�ximo sin correcciones.
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

%Depuraci�n de nodos de enlaces que involucran nodos de codificaci�n:
%1. B�squeda de nodos de codificaci�n que formen un ciclo (cuadrado en el
%grafo). En estos ciclos(cuadrados), se elimina el primer enlace para
%romperlo. 
%2. Despu�s de eliminar los ciclos, algunos nodos de codificaci�n, quedan
%con un  solo enlace de entrada. Estos nodos deben deben ser eliminados de
%la lista de  nodos de codificaci�n. 
%if isempty(nodos_cod)
%    fprintf('No hay nodos de codificaci�n en este Grafo\n')
%else
    %Buscar coicidencias de nodos de codificaci�n de tal manera que formen
    %un cuadrado l�gico de  1's
%    for in=1:length(nodos_cod)-1
%        for jn=in+1:length(nodos_cod)
%            ncod_com=intersect(find(fa_min(:,nodos_cod(in))==1),...
%                find(fa_min(:,nodos_cod(jn))==1));
%            if ~isempty(ncod_com)
%                fa_min(ncod_com(1),nodos_cod(jn))=0;
%            end
%        end
%    end
    %Reestructurar los  nodos de codificaci�n, eliminando los que se
    %queden con una entrada.
%   i=1;
%   pos_nod_elim=[];
%   while i<=length(nodos_cod)
%       if length(find(fa_min(:,nodos_cod(i))==1))<=1
%           pos_nod_elim=[i pos_nod_elim];
%            nodos_cod(i)=[];
%      end 
%       i=i+1;
%   end
%   for i=1:length(pos_nod_elim)
%       nodos_cod(pos_nod_elim(i))=[];
%   end
%end

%Impresi�n de la matriz de  flujo m�ximo total (grafo de  flujo m�ximo
%general)
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