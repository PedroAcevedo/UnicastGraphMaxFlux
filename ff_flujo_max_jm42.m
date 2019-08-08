function [flujo_max, flujo_actual, residual, corte] =ff_flujo_max_jm42(origen,destino,capacidad,numero_nodos)

flujo_actual = zeros(numero_nodos, numero_nodos); %AGREGADO PARA PROBAR
flujo_max=0;
pathaumentado = ff_pathaumentado1(origen,destino,flujo_actual,capacidad,numero_nodos);
% pathaumentado = ff_dfs_grafo(origen,destino,flujo_actual,capacidad);
jp=0;
while ~isempty(pathaumentado)
    % Si existe un camino aumentado, actualice el flujo_actual    
    % Incremento en el flujo actual
    for i=1:length(pathaumentado)-1
        flujo_actual(pathaumentado(i),pathaumentado(i+1))=1; %AGREGADO PARA PROBAR
    end
    flujo_max=flujo_max+1;
   
    jp=jp+1;
    if jp==1
        pathaumentado = ff_pathaumentado1(origen,destino,flujo_actual,capacidad,numero_nodos);% try to find new augment path
%         pathaumentado = ff_dfs_grafo(origen,destino,flujo_actual,capacidad);
    end
    if jp>=2
        ii=2;
        swe=false;
        while (ii~=destino) && (~swe)
            tf=flujo_actual(:,ii);
            posc=find(tf==1);
            if length(posc)==2
                swe=true;
            else
                ii=ii+1;
            end
        end
        if swe
            for i=1:length(pathaumentado)-1
               flujo_actual(pathaumentado(i),pathaumentado(i+1))=0; %AGREGADO PARA PROBAR
            end
%             flujo_max=flujo_max-incremento;
            flujo_max=flujo_max-1;
            pp=intersect(pathaumentado,posc);
            capacidad(pp,ii)=0;         
        end
        pathaumentado = ff_pathaumentado1(origen,destino,flujo_actual,capacidad,numero_nodos);
%         pathaumentado = ff_dfs_grafo(origen,destino,flujo_actual,capacidad);
    end
end
% Determinación del corte
%cf=flujo_actual;
%cf(cf<0)=0;
% cf=marcado;
residual=capacidad-flujo_actual;
corte=cut(origen,residual,numero_nodos);
end
