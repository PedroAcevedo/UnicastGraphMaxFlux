function [disjoints] = Disjoints(t,segnodo,rutaseg,rutas,dis,fseg,segs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    disjoints = dis;
    lim = ceil(length(rutaseg(t).nodo(segnodo).lista)/2);
    used = rutaseg(t).nodo(segnodo).inter(:);
    for i=1:lim
        [minval ind] = min(used);
        if(isempty(disjoints) && segnodo==fseg)
            disjoints(1) = rutaseg(t).nodo(segnodo).lista(ind);
            tmp = segs; 
            tmp(segnodo) = 100;
            [val inds] = min(tmp);
            disjoints = Disjoints(t,inds,rutaseg,rutas,disjoints,fseg,tmp);
        else
            if(isdisjoint(rutaseg(t).nodo(segnodo).lista(ind),disjoints,rutas)==1)
                disjoints(end+1) = rutaseg(t).nodo(segnodo).lista(ind);
                if(length(disjoints)==length(rutaseg(t).nodo))
                    return;
                else
                   tmp = segs;
                   tmp(segnodo) = 100;
                   [val inds] = min(tmp);
                   disjoints = Disjoints(t,inds,rutaseg,rutas,disjoints,fseg,tmp);
                end
            end
        end
        used(ind) = 1000;
        if(length(disjoints)==length(rutaseg(t).nodo))
            return;
        end
        if (segnodo == fseg && length(disjoints) == 1)
            disjoints = [];
        end
    end
    
    if (~(length(find(segs == 100)) == length(segs)))
        if ~(length(segs)-length(find(segs==100))==1)
            tmp = segs;
            tmp(segnodo) = 100;
            [val inds] = min(tmp);
            disjoints = Disjoints(t,inds,rutaseg,rutas,disjoints,fseg,tmp); 
        else
            return
        end
    else
        return
    end
end

