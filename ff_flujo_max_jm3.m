function [flujo_max, cf, residual, corte] =ff_flujo_max_jm(origen,destino,capacidad,numero_nodos)

sw=false;
kk=0;
tf=0;
tc=0;
%while ~sw
flujo_actual=zeros(numero_nodos,numero_nodos);
flujo_max=0;
jpth=1;
pathaumentado = ff_pathaumentado(origen,destino,flujo_actual,capacidad,numero_nodos);
pathaum(jpth).path=pathaumentado;
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
%    jpth=jpth+1;
    pathaumentado = ff_pathaumentado(origen,destino,flujo_actual,capacidad,numero_nodos);% try to find new augment path   
    sw2pth=false;
    while ~sw2pth
        swpth=false;
        jp=1;
        while (jp<=jpth) && (~swpth)
            tmppth=pathaum(jp).path;
            ic=intersect(tmppth(2:end-1), pathaumentado(2:end-1));    
            if ~isempty(ic)
                swpth=true;
            else
                jp=jp+1;
            end
        end
    
        if swpth
            for j=1:length(ic)
                kl=find(pathaumentado==ic(j));
                capacidad(pathaumentado(kl-1),pathaumentado(kl))=0;
            end
            pathaumentado = ff_pathaumentado(origen,destino,flujo_actual,capacidad,numero_nodos);% try to find new augment path 
%        ic=intersect(pathaum(2:end-1), pathaumentado(2:end-1));
        else
            sw2pth=true;
            jpth=jpth+1;
            pathaum(jpth).path=pathaumentado;
        end
    end
end
% Determinación del corte
cf=flujo_actual;
cf(cf<0)=0;
%%%%%%% ELIMINADO TODO ESTO
%[sw, ic]=ff_disyuntos(origen,destino,cf);
%if kk>=1 
%    capacidad(tf,tc)=1;
%end
%if ~sw 
%    for j=1:length(ic)
%        posc=find(cf(:,ic(j))~=0);
%        capacidad(posc(1),ic(j))=0;
%    end
%    kk=kk+1;
%    tf=posc(1);
%    tc=ic(j);
%end
%end
residual=capacidad-cf;
corte=cut(origen,residual,numero_nodos);

end
