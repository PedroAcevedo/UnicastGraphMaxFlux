function [flujo, nc, q, swdisy] = ff_visitapred2(ipr,flujo,nc,dests,q, swdisy) %La q(cola) se  env�a inicialmente vac�a.
    
    for j=1:length(nc(ipr).predecesor)
            %Moment�neamente se desactiva el enlace predecesor(j) del nodo 
            %i para probar si siguen obteniendo dos caminos o m�s.
%        flujo(nc(ipr).predecesor(j),nc(ipr).nodo)=0;
%ELIMINADO        it=ipr;
%            disyuntos=ff_disyuntos(1,nc(ipr).destino,flujo,dests);
        if nc(ipr).marca(j)==1
%            nc(ipr).marca(j)=1;
            q=[q nc(ipr).predecesor(j)];
%        else
            %Si es disyunto, se debe probar la funci�n de configuraci�n de 
            %paquetes iniciales(pruebarut.m). Si esta funci�n pasa la  prueba, se debe 
            %guardar la matriz correspondiente al grafo de flujo y guardar
            %el n�mero de nodos de codificaci�n con los que queda. Nos
            %debemos quedar con la que resuelva el problema y tenga el
            %menor n�mero de nodos de codificaci�n.
%            nc(ipr).marca(j)=2;
           % ipr=ipr+1;
%ELIMINADO            it=it+1;
            if ipr+1<=length(nc)
                [flujo, nc, q, swdisy]=ff_visitapred2(ipr+1,flujo,nc,dests,q,swdisy);
                if ~swdisy
                    flujo(q(end),nc(length(q)).nodo)=1;
                    q(end)=[];
%                    swdisy=true;
                end
            else
                disp(q);
                for kq=1:length(q)
                   flujo(q(kq),nc(kq).nodo)=0; 
                end
                swdisy=true;
                kn=1;
                while kn<=length(nc) && swdisy 
                    swdisy=ff_disyuntos(1,nc(kn).destino,flujo);
                    kn=kn+1;
                end
                if ~swdisy
                    flujo(q(end),nc(length(q)).nodo)=1;
                    q(end)=[];
                end
% AQU� SE DEBE TOMAR UNA ACCI�N SI DA DISYUNTO,llamar a ff_orden_paq, SI NO DA, DEBE CONTINUAR.
            end
        end
%        flujo(nc(ipr).predecesor(j),nc(ipr).nodo)=1;
    end
end