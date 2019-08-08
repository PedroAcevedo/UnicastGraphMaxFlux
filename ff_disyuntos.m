function [disyuntos, ic] = ff_disyuntos(orig,dests,flujo) %,destinos)
    disyuntos=true;
    i=1;
    while (disyuntos) && (i<=length(dests))
        rutas=ff_todas_las_rutas4(orig,dests(i),flujo);%,destinos);
        ic=rutas(1).camino(2:end-1);
        if length(rutas)>1
            j=2;
            while j<=length(rutas) && ~isempty(ic)
                ic=intersect(ic,rutas(j).camino(2:end-1));
                j=j+1;
            end
        else
            ic=[];
        end
        if (~isempty(ic))
            disyuntos=false;
        else
            i=i+1;
        end
    end
end