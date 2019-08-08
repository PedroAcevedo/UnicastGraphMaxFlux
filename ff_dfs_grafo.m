function  pathaumentado = ff_dfs_grafo(inicio,fin,flujo_actual,C)  %[color,pred]
%n=length(C);
BLANCO=0;
GRIS=1;
NEGRO=2;
color(1:fin)=BLANCO;
pred=zeros(1,fin);
%color(origen) = BLANCO;
[color,pred] = ff_visita_dfs2(C,inicio,color,pred,flujo_actual,fin,BLANCO,GRIS,NEGRO);
% for u=1:n
%     if color(u)==BLANCO && C(inicio,u) > flujo_actual(inicio,u)
%         [color,pred] = ff_visita_dfs(C,u,color,pred,flujo_actual,BLANCO,GRIS,NEGRO);
%     end
% end
% Aquí se empieza el cálculo del pathaumentado.
pathaumentado=[];
if color(fin)==NEGRO       % Si fin es accesible
    temp=fin;
    while pred(temp)~=inicio
        pathaumentado = [pred(temp) pathaumentado];     % El camino aumentado no contiene ni el inicio ni el fin
        temp=pred(temp);
    end
    pathaumentado=[inicio pathaumentado fin];
end
end
