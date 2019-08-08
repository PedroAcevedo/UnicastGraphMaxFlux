function [sw_orden_paq, listpaq] = ff_orden_paq(flujo,nc,dests)
%Se obtienen los nodos siguientes al nodo fuente 1. Estos nodos
%determinarán las diferentes rutas a seguir.
%También se adicionan los nodos de codificación para que sean puntos de
%salida de rutas a probar.
segnodo=find(flujo(1,:)~=0);
nodsalt=[segnodo sort(nc)];
bandera=1;
%Se inicializa la lista de nodos sumideros como vacía. Esta lista contendrá
%los nodos sumideros que se  pueden alcanzar desde el nodo fuente pasando
%por cada una de las rutas determinadas en el punto anterior.
for jsn=1:length(nodsalt)
    listas(jsn).nodos=[];
end
%Se llena la lista de nodos sumideros por cada una de las rutas
%establecidas en el ítem anterior. 
destinos=sort([dests nc]);
origenes=[1 nc];
for jn=1:length(destinos)
   %if ~isempty(nc==destinos(jn)))
       
   %else
   %end
   for jo=1:length(origenes)  
      rutas=ff_todas_las_rutas4(origenes(jo),destinos(jn),flujo);%, destinos);
      lr=length(rutas);
      jr=1;
      while jr<=lr
          nco=intersect(rutas(jr).camino(2:end-1),nc);
          if ~isempty(nco) 
             rutas(jr)=[];
             lr=lr-1;
          else 
             jr=jr+1;
          end
      end
      if ~isempty(find(nc==origenes(jo)))
         sgtesal=1;
      else
         sgtesal=2;
      end
      for jr=1:length(rutas)
          il=find(nodsalt==intersect(rutas(jr).camino(sgtesal),nodsalt));
          listas(il).nodos=[listas(il).nodos rutas(jr).camino(end)];
      end
   end
end
matconf=zeros(numel(destinos),numel(listas));
%lmatc=[];
listpaq=[];
for jl=1:length(listas)
    for jd=1:length(listas(jl).nodos)
        matconf(destinos==listas(jl).nodos(jd),jl)=1;
    end
    listpaq=[listpaq ' '];
%    lmatc=[lmatc length(find(matconf(:,jl)==1))];
end
for jn=1:length(destinos)
    sum=0; %Esto no se usó. SE PUEDE QUITAR
    pos=[];
    for js=1:length(nodsalt)
        if matconf(jn,js)==1
            sum=xor(sum, matconf(jn,js)); %Esto no se usó. SE PUEDE QUITAR
            pos=[pos js];
        end
    end
    if numel(pos)==2
        if listpaq(pos(1))==' ' && listpaq(pos(2))==' '
           listpaq(pos(1))='a';
           listpaq(pos(2))='b';
        elseif listpaq(pos(1))=='a' && listpaq(pos(2))==' '
           listpaq(pos(2))='b';
        elseif listpaq(pos(1))=='b' && listpaq(pos(2))==' '
           listpaq(pos(2))='a';
        elseif listpaq(pos(1))==' ' && listpaq(pos(2))=='a'
           listpaq(pos(1))='b';
        elseif listpaq(pos(1))==' ' && listpaq(pos(2))=='b'
           listpaq(pos(1))='a';
        %Se puede resolver y hay que dejar un nodo de codificación para
        %que resuelva interiormente:
        elseif ((listpaq(pos(1))=='a' && listpaq(pos(2))=='a') || (listpaq(pos(1))=='b' && listpaq(pos(2))=='b')) && pos(1)>length(segnodo) && ...
                pos(2)>length(segnodo)
           listpaq(pos(1))='c';
%           bandera=2; 
        elseif ((listpaq(pos(1))=='a' && listpaq(pos(2))=='a') || (listpaq(pos(1))=='b' && listpaq(pos(2))=='b')) && pos(2)>length(segnodo)
           listpaq(pos(2))='c';
%           bandera=2; 
        elseif (listpaq(pos(1))=='a' && listpaq(pos(2))=='a') || (listpaq(pos(1))=='b' && listpaq(pos(2))=='b')
           listpaq(pos(1))='c';
%           bandera=2;            


%        elseif listpaq(pos(1))=='b' && listpaq(pos(2))=='b'
%           listpaq(pos(1))='c';
%           bandera=2; 
        %I)Se presentó previamente un caso de una resolución con 'c=a|b'. Es
        %decir, puede estar cualquiera de las dos opciones, pero dado que
        %hay un sumidero con dos caminos únicos, el camino marcado con 'c'
        %se debe marcar con el paquete complemento.
%        elseif listpaq(pos(1))=='a' && listpaq(pos(2))=='c'
%           listpaq(pos(2))='b';  
%        elseif listpaq(pos(1))=='b' && listpaq(pos(2))=='c'
%           listpaq(pos(2))='a';  
%        elseif listpaq(pos(1))=='c' && listpaq(pos(2))=='a'
%           listpaq(pos(1))='b';  
%        elseif listpaq(pos(1))=='c' && listpaq(pos(2))=='b'
%           listpaq(pos(1))='a';            
        end
    elseif numel(pos)>=3
        bandera=3; 
        %A PARTIR DE AQUÍ SE PODRÍA RETIRAR EL CÓDIDOG, YA QUE NO SE USARÍA
        %PORQUE SOLO PUEDEN TENERSE DOS ENTRADAS EN CADA NODO, SEA
        %CODIFICADOR O SEA DESTINO.
        %Se tienen tres caminos hacia un sumidero, dos caminos se tienen
        %marcados con 'a' y 'b', el camino restante se  debe marcar con
        %'c=a|b'.
        %if (listpaq(pos(1))=='a' && listpaq(pos(2))=='b' || listpaq(pos(1))=='b' && listpaq(pos(2))=='a') && listpaq(pos(3))==' '
        %    listpaq(pos(3))='c';
        %elseif (listpaq(pos(1))=='a' && listpaq(pos(3))=='b' || listpaq(pos(1))=='b' && listpaq(pos(3))=='a') && listpaq(pos(2))==' '
        %    listpaq(pos(2))='c';
        %elseif (listpaq(pos(2))=='a' && listpaq(pos(3))=='b' || listpaq(pos(2))=='b' && listpaq(pos(3))=='a') && listpaq(pos(1))==' '
        %    listpaq(pos(1))='c';
        %elseif  listpaq(pos(1))=='a' && listpaq(pos(2))==' ' && listpaq(pos(3))==' '
        %    listpaq(pos(2))='b';        
        %    listpaq(pos(3))='c';           
        %Se tienen tres caminos hacia un sumidero, un camino se  tiene
        %marcado con 'a' o 'b', luego los dos restantes se deben marcar con
        %'c=a|b' y 'b' o 'c', según como esté previamente marcado el 
        %camino distinto de 'c'.
        %elseif  listpaq(pos(2))=='a' && listpaq(pos(1))==' ' && listpaq(pos(3))==' '
        %    listpaq(pos(1))='b';        
        %    listpaq(pos(3))='c';           
        %elseif  listpaq(pos(3))=='a' && listpaq(pos(1))==' ' && listpaq(pos(2))==' '
        %    listpaq(pos(1))='b';        
        %    listpaq(pos(2))='c';           
        %elseif  listpaq(pos(1))=='b' && listpaq(pos(2))==' ' && listpaq(pos(3))==' '
        %    listpaq(pos(2))='a';        
        %    listpaq(pos(3))='c';           
        %elseif  listpaq(pos(2))=='b' && listpaq(pos(1))==' ' && listpaq(pos(3))==' '
        %    listpaq(pos(1))='a';        
        %    listpaq(pos(3))='c';           
        %elseif  listpaq(pos(3))=='b' && listpaq(pos(1))==' ' && listpaq(pos(2))==' '
        %    listpaq(pos(1))='a';        
        %    listpaq(pos(2))='c';           
        %Se tienen tres caminos hacia un sumidero, un camino se tiene
        %marcasdo con 'c=a|b' y otro camino marcado con 'a' o 'b', luego se
        % debe marcar el camino restante con 'b' o 'a', según como esté
        % marcado previamente el camino distinto de  'c'.
        %elseif  (listpaq(pos(1))=='c' && listpaq(pos(2))=='a' || listpaq(pos(1))=='a' && listpaq(pos(2))=='c') && listpaq(pos(3))==' '
        %    listpaq(pos(1))='b';        
        %elseif  (listpaq(pos(1))=='c' && listpaq(pos(3))=='a' || listpaq(pos(1))=='a' && listpaq(pos(3))=='c') && listpaq(pos(2))==' '
        %    listpaq(pos(2))='b';        
        %elseif  (listpaq(pos(2))=='c' && listpaq(pos(3))=='a' || listpaq(pos(2))=='a' && listpaq(pos(3))=='c') && listpaq(pos(1))==' '
        %    listpaq(pos(1))='b';        
        %elseif  (listpaq(pos(1))=='c' && listpaq(pos(2))=='b' || listpaq(pos(1))=='b' && listpaq(pos(2))=='c') && listpaq(pos(3))==' '
        %    listpaq(pos(1))='a';        
        %elseif  (listpaq(pos(1))=='c' && listpaq(pos(3))=='b' || listpaq(pos(1))=='b' && listpaq(pos(3))=='c') && listpaq(pos(2))==' '
        %    listpaq(pos(2))='a';        
        %elseif  (listpaq(pos(2))=='c' && listpaq(pos(3))=='b' || listpaq(pos(2))=='b' && listpaq(pos(3))=='c') && listpaq(pos(1))==' '
        %    listpaq(pos(1))='a'; 
        %Ninguno de los tres caminos está marcado. Se deben marcar los
        %tres caminos con 'a', 'b' y 'c'.
        %elseif listpaq(pos(1))==' ' && listpaq(pos(2))==' ' && listpaq(pos(3))==' '
        %    listpaq(pos(1))='a';        
        %    listpaq(pos(2))='b';           
        %    listpaq(pos(3))='c';    
        %end
    %else
    %    if (listpaq(pos(1))==' ' && listpaq(pos(2))==' ' && listpaq(pos(3))=='a' && listpaq(pos(4))=='b') || ...
    %            (listpaq(pos(1))==' ' && listpaq(pos(2))==' ' && listpaq(pos(4))=='a' && listpaq(pos(3))=='b')
    %        listpaq(pos(1))='a';        
    %        listpaq(pos(2))='c'; 
    %    else
    %        fprintf('ERROR ERROR ERRORR\n\n');
        end
    end 
    if ~isempty(find(listpaq(1:numel(segnodo))=='c'))
        bandera=2;
    end
    sw_orden_paq=bandera;
end

%marcamat=false(1,length(listas));
%posmaymat=find(lmatc==max(lmatc));
%matpaqc=repmat(' ',[numel(dests),numel(listas)]);
%matpaqc(matconf(:,posmaymat)==1,posmaymat)='a';
%marcapq(posmaymat)='a';
%marcamat(posmaymat)=true;
%while ~isempty(find(marcamat~=1))
%    posmaymat=find(max(lmatc(find(marcamat~=true))));
%    marcamat(posmaymat)=true;
%    posnue=find(matconf(:,posmaymat)==1);
%    [fi ,co]=find(matpaqc~=' ');
%    
%end
