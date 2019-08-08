function [cm, indz, indnz] = ff_recorte_matriz(cm)
indz=[];
indnz=[];
for ic=1:length(cm)
    if all(cm(ic,:)==0) && all(cm(:,ic)==0)
        indz=[indz ic];
    else
        indnz=[indnz ic];
    end
end
for id=length(indz):-1:1
    cm(indz(id),:)=[];
    cm(:,indz(id))=[];
end
end