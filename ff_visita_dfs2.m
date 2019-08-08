function [color,pred] = ff_visita_dfs2(C,u,color,pred,flujo_actual,fin,BLANCO,GRIS,NEGRO)
%nn=length(C);
color(u)=GRIS;
ady=1:fin; %nn
if C(u,fin)==1
    posfin=find(fin==ady);
    tem=ady(1);
    ady(posfin)=tem;
    ady(1)=fin;
end
% ady=find(C(u,:)==1);
% posfin=find(fin==ady);
% if ~isempty(posfin)
%     tem=ady(1);
%     ady(posfin)=tem;
%     ady(1)=fin;
% end
for v=1:fin %nn
    if color(ady(v))==BLANCO && C(u,ady(v))>flujo_actual(u,ady(v))
        pred(ady(v))=u;
        [color,pred]=ff_visita_dfs2(C,ady(v),color,pred,flujo_actual,fin,BLANCO,GRIS,NEGRO);
    end
end
color(u)=NEGRO;
end
