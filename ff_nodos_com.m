function n_com = ff_nodos_com(graf_red,dest,nnodos)
n_com=[]; 
for i=1:nnodos
     if i~=dest && numel(find(graf_red(:,i)==1))>1;
        n_com=[i n_com];
     end
end
end
