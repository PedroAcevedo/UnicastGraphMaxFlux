function sw_listigual = ff_config_listseg(nodos,ttdr,tsec,minflujo)
aaa=[nodos(1) nodos(end)];
listpen=[];
for ikl=1:length(ttdr.tdrmn)
    zz=find(ismember(ttdr.tdrmn(ikl).camino,aaa));
    if length(zz)==2
        listpen=[listpen ttdr.tdrmn(ikl).camino(end-1)];
    end
end
textremos=ttdr.extremos;
for ikl=1:length(textremos)
    if ~isempty(find(textremos(ikl).pen==listpen))
        pseg=find(textremos(ikl).listseg==tsec);
        textremos(ikl).listseg(pseg(1))=[];
        textremos(ikl).listseg=ff_reducir(textremos(ikl).listseg);
    end
end

% sw=false;
% jkl=1;
% while ~sw && jkl <= length(textremos) - 1
%     swe=false;
%     aaa=textremos(jkl).listseg;
%     ikl=jkl+1;
%     while ~swe && ikl <= length(textremos)
%         if isequal(aaa, textremos(ikl).listseg)
%             swe=true;
%         else
%             ikl=ikl+1;
%         end
%     end
%     if swe
%          sw=true;
%     else
%          jkl=jkl+1;
%     end
% end
zxor=textremos(1).listseg;
for iex=2:minflujo
     [zxor, sw]=ff_xorvect(zxor, textremos(iex).listseg);
end
sw_listigual=sw;