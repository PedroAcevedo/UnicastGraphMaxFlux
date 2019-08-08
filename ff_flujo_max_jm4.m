function [flujo_max, cf, residual, corte] =ff_flujo_max_jm4(origen,destino,capacidad,numero_nodos)

flujo_actual=zeros(numero_nodos,numero_nodos);
% marcado = zeros(numero_nodos, numero_nodos); %AGREGADO PARA PROBAR
flujo_max=0;
pathaumentado = ff_pathaumentado1(origen,destino,flujo_actual,capacidad);  % BFS
 %pathaumentado = ff_dfs_grafo(origen,destino,flujo_actual,capacidad); %DFS
jp=0;
while ~isempty(pathaumentado)
    % Si existe un camino aumentado, actualice el flujo_actual    
%     incremento = inf;
      incremento = 1;
%     for i=1:length(pathaumentado)-1
%         incremento=min(incremento, capacidad(pathaumentado(i),pathaumentado(i+1))-flujo_actual(pathaumentado(i),pathaumentado(i+1)));
%     end
    % Incremento en el flujo actual
    for i=1:length(pathaumentado)-1
        flujo_actual(pathaumentado(i),pathaumentado(i+1))=flujo_actual(pathaumentado(i),pathaumentado(i+1))+incremento;
        flujo_actual(pathaumentado(i+1),pathaumentado(i))=flujo_actual(pathaumentado(i+1),pathaumentado(i))-incremento;
        marcado(pathaumentado(i),pathaumentado(i+1))=1; %AGREGADO PARA PROBAR
    end
    flujo_max=flujo_max+incremento;
    
    jp=jp+1;
    if jp==1
        pathaumentado = ff_pathaumentado1(origen,destino,flujo_actual,capacidad); % BFS
%         pathaumentado = ff_dfs_grafo(origen,destino,flujo_actual,capacidad); %DFS
    end
    if jp>=2
        cf=flujo_actual;
        cf(cf<0)=0;
        ii=1;
        swe=false;
        while (ii~=destino) && (~swe)
            tf=cf(:,ii);
            posc=find(tf==1);
            if length(posc)==2
                swe=true;
            else
                ii=ii+1;
            end
        end
        if swe
            for i=1:length(pathaumentado)-1
               flujo_actual(pathaumentado(i),pathaumentado(i+1))=flujo_actual(pathaumentado(i),pathaumentado(i+1))-incremento;
               flujo_actual(pathaumentado(i+1),pathaumentado(i))=flujo_actual(pathaumentado(i+1),pathaumentado(i))+incremento;
            end
            flujo_max=flujo_max-incremento;
            pp=intersect(pathaumentado,posc);
            capacidad(pp,ii)=0;         
        %else
        %    pathaum=pathaumentado;
        end
        pathaumentado = ff_pathaumentado1(origen,destino,flujo_actual,capacidad);   %BFS
%         pathaumentado = ff_dfs_grafo(origen,destino,flujo_actual,capacidad); %DFS
    end
end
% Determinación del corte
cf=flujo_actual;
cf(cf<0)=0;
residual=capacidad-cf;
corte=cut(origen,residual,numero_nodos);

end
