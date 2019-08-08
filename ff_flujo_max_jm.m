function [flujo_max, cf, residual, corte] =ff_flujo_max_jm(origen,destino,capacidad,numero_nodos)

flujo_actual=zeros(numero_nodos,numero_nodos);
flujo_max=0;
pathaumentado = ff_pathaumentado(origen,destino,flujo_actual,capacidad,numero_nodos);

while ~isempty(pathaumentado)
    % Si existe un camino aumentado, actualice el flujo_actual    
    incremento = inf;
    for i=1:length(pathaumentado)-1
        incremento=min(incremento, capacidad(pathaumentado(i),pathaumentado(i+1))-flujo_actual(pathaumentado(i),pathaumentado(i+1)));
    end
    % Incremento en el flujo actual
    for i=1:length(pathaumentado)-1
        flujo_actual(pathaumentado(i),pathaumentado(i+1))=flujo_actual(pathaumentado(i),pathaumentado(i+1))+incremento;
        flujo_actual(pathaumentado(i+1),pathaumentado(i))=flujo_actual(pathaumentado(i+1),pathaumentado(i))-incremento;
    end
    flujo_max=flujo_max+incremento;
    pathaumentado = ff_pathaumentado(origen,destino,flujo_actual,capacidad,numero_nodos);% try to find new augment path    
    
end
% Determinación del corte
cf=flujo_actual;
cf(cf<0)=0;
residual=capacidad-cf;
corte=cut(origen,residual,numero_nodos);

end
