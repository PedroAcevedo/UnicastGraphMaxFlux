function [sw_orden_paq, listpaq] = ff_orden_paq3(flujo,nc,dests)
%Se obtienen los nodos siguientes al nodo fuente 1. Estos nodos
%determinarán las diferentes rutas a seguir.
%También se adicionan los nodos de codificación para que sean puntos de
%salida de rutas a probar.
%VARIABLES:
%flujo: Matriz de los flujos mínimos obtenidos del algoritmo de
%enrutamiento basado en FF y después de aplicar o no el algoritmo de
%optimización de nodos codificadores.
%nc: Vector de nodos codificadores, puede estar vacío si no hay nodos
%codificacores.
%dests: Vector de nodos destinos. Normalmente es es des.nodo, definido en
%el algoritmo de enrutamiento.

segnodo=find(flujo(1,:)~=0);
nodsalt=[segnodo sort(nc)];
bandera=1;
syms xpqt;
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
listpaq=[];
for jl=1:length(listas)
    for jd=1:length(listas(jl).nodos)
        matconf(destinos==listas(jl).nodos(jd),jl)=1;
    end
    listpaq=[listpaq ' '];
end
kr=0;
cad='abxy';
for jn=1:length(destinos)
    pos=[];
    npos=[];
    for js=1:length(nodsalt)
        if matconf(jn,js)==1
            pos=[pos js];
            npos=[npos nodsalt(js)];
        end
    end
    if numel(pos)==2
        posdnc=find(nodsalt==destinos(jn));
        if ~isempty(intersect(npos,segnodo))
            if intersect(npos,segnodo)==npos %Regla 1 y 2
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
                elseif (listpaq(pos(1))=='a' && listpaq(pos(2))=='x' ) || (listpaq(pos(1))=='a' && listpaq(pos(2))=='y' ) %Regla 9
                    listpaq(pos(2))='b';
                    post=find(rel(:,1)==pos(2));
                    poss=rel(post,2);
                    listpaq(poss)='a';
                elseif (listpaq(pos(1))=='b' && listpaq(pos(2))=='x' ) || (listpaq(pos(1))=='b' && listpaq(pos(2))=='y' )
                     listpaq(pos(2))='a';
                elseif (listpaq(pos(1))=='x' && listpaq(pos(2))=='a' ) || (listpaq(pos(1))=='y' && listpaq(pos(2))=='a' )
                     listpaq(pos(1))='b';    
                     post=find(rel(:,1)==pos(1));
                     poss=rel(post,2);
                     listpaq(poss)='a';
                elseif (listpaq(pos(1))=='x' && listpaq(pos(2))=='b' ) || (listpaq(pos(1))=='y' && listpaq(pos(2))=='b' ) %Termina Regla 9
                     listpaq(pos(1))='a';    
                     post=find(rel(:,1)==pos(1));
                     poss=rel(post,2);
                     listpaq(poss)='b';
                elseif (listpaq(pos(1))=='a' && listpaq(pos(2))=='a') || (listpaq(pos(1))=='b' && listpaq(pos(2))=='b') %Regla  5*
                    bandera=2;
                    post=pos(2);
                end
                if find(nc==destinos(jn))  %Regla 1 y 1* exclusivamente, la Regla 2 no marca nada. La regla 1* no marca nada en el paso anterior.
                    listpaq(posdnc)='c';
                end
            elseif find(segnodo==npos(1)) && find(nc==npos(2)) %Regla 3. Como están ordenados ascendentemente, el primero debe estar en segnodo y el segundo en nc
                if listpaq(pos(1))==' ' && listpaq(pos(2))=='c' 
                    if find(nc==destinos(jn))
                        listpaq(pos(1))='x';
                        listpaq(posdnc)='y';
                        kr=kr+1;
                        rel(kr,:)=[pos(1) posdnc];
                    else                                   %Regla 8. 
                        listpaq(pos(1))='x';
                    end
                elseif (listpaq(pos(1))=='a' || listpaq(pos(1))=='b') && (listpaq(pos(2))=='x' || listpaq(pos(2))=='y') && find(dests==destinos(jn)) %Regla 6. 
                    posnd=find(rel(:,2)==pos(2));
                    posc=rel(posnd,1);
                    posns=find(rel(:,1)==pos(2));
                    if listpaq(pos(1))=='a'
                        listpaq(pos(2))='b';
                        listpaq(posc)='a';
                        if ~isempty(posns)
                            posc=rel(posns,2);
                            listpaq(posc)='a';
                        end
                    else
                        listpaq(pos(2))='a';
                        listpaq(posc)='b';
                        if ~isempty(posns)
                            posc=rel(posns,2);
                            listpaq(posc)='b';
                        end
                    end
                elseif find(listpaq(pos(1))==cad) && listpaq(pos(2))=='c' && ~isempty(find(nc==destinos(jn)))
                    xpqt=listpaq(pos(1));
                    listpaq(posdnc)=ff_intercambio(xpqt);
                end
            end
        elseif intersect(npos,nc)==npos %Regla 4: *Se incluyó los casos de [c b], [b c], [c a], [a c]
            temp=[listpaq(pos(1)) listpaq(pos(2))];
            if find(nc==destinos(jn))
                if (length(find(temp==['c' 'x']))==2) || length(find((temp==['x' 'c']))==2)
                    listpaq(posdnc)='y';
                elseif (length(find(temp==['c' 'y']))==2) || length(find((temp==['y' 'c']))==2)
                    listpaq(posdnc)='x';
                elseif (length(find(temp==['c' 'a']))==2) || length(find((temp==['a' 'c']))==2)
                    listpaq(posdnc)='b';
                elseif (length(find(temp==['c' 'b']))==2) || length(find((temp==['b' 'c']))==2)
                    listpaq(posdnc)='a';                 
                end
                kr=kr+1;
                if listpaq(pos(1))=='x' || listpaq(pos(1))=='y'
                   rel(kr,:)=[pos(1) posdnc];
                elseif listpaq(pos(2))=='x' || listpaq(pos(2))=='y'
                   rel(kr,:)=[pos(2) posdnc];
                end
            end
        end 
    end
end
if bandera==2
    listpaq(post)='c';
end 
sw_orden_paq=bandera;
end