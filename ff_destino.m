function destino = ff_destino(orig,dest,flujo)

    l=length(flujo);
    q=[orig];
    cont_flujo=false(l,l);
    destino=false;
    while ~isempty(q)
        i=q(end);
        j=2;
        sw=false;
        %Aquí en vez de  dest puede ser l
        while (j<=l) && (~sw)
            if (flujo(i,j)~=0) && (~cont_flujo(i,j))
                q=[q j];
                cont_flujo(i,j)=true;
                sw=true;
            else
                j=j+1;
            end
        end
        if ~sw
            q(end)=[];
        else
            if j==dest
                destino=true;
                q=[];
            end
        end
    end
end