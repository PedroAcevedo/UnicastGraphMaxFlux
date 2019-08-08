function grafo = ff_grafo(C,dest,ncod)

[CC, iz, inz] = ff_recorte_matriz(C);
bg=biograph(CC,[],'ShowWeights','off', 'EdgeFontSize',12, 'ArrowSize',10, 'NodeAutoSize','off');
for ii=1:length(inz)
     bg.nodes(ii).ID=strcat(num2str(inz(ii)));
end
set(bg.nodes,'Color',[1 1 1],'Shape','circle','LineColor',[0 0 0], 'LineWidth', 1.5, 'FontSize', 12, 'Size',[20 20]);
set(bg.edges,'LineWidth', 1.5,'LineColor',[0 0 0]);
for ii=1:length(bg.nodes)
    if ~isempty(find(str2num(bg.nodes(ii).ID)==dest))
        bg.nodes(ii).Color=[0.4 0.4 0.4];
    end
    if ~isempty(find(str2num(bg.nodes(ii).ID)==ncod))
        bg.nodes(ii).Color=[0.7 0.7 0.7];
    end
end
%set(bg.nodes(dest),'Color',[0.4 0.4 0.4]);
%set(bg.nodes(ncod),'Color',[0.7 0.7 0.7]);
view(bg);
end
