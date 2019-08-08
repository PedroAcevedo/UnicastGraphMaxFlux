function [minmaxflujo, nodos_cod] = ff_actflujo(minmaxflujo, nodos_cod, camino, tcod)    
selnod=find(camino==tcod);
tnodp=camino(selnod-1);
minmaxflujo(tnodp,tcod)=0;
if ~nnz(minmaxflujo(tnodp,:))
    prevnodp=find(minmaxflujo(:,tnodp)==1);
    for ip=1:length(prevnodp)
        minmaxflujo(prevnodp(ip),tnodp)=0;
    end
end
if sum(minmaxflujo(:,tcod)) < 2
    %       pcod=find(nodos_cod==tcod);
    nodos_cod(nodos_cod==tcod)=[];
end