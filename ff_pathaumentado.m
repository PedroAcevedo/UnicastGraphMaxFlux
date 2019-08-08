function pathaumentado=ff_pathaumentado(inicio,fin,flujo_actual,capacity,n)
BLANCO=0;
GRIS=1;
NEGRO=2;
color(1:n)=BLANCO;
q=[];
pathaumentado=[];

% Encolamiento
q=[inicio q];
color(inicio)=GRIS;
pred=zeros(1,n); %SE MANEJARÁ COMO UNA  LISTA

while ~isempty (q)
    %    [u,q]=desencole(q);
    u=q(end);
    q(end)=[];
    color(u)=NEGRO;
    %     Final de densencolamiento
    colcap=find(capacity(u,:)==1); %Solo revisa las capacidades iguales a 1.
    for v=1:length(colcap)
        if (color(colcap(v))==BLANCO && capacity(u,colcap(v))>flujo_actual(u,colcap(v)))
            %Encole(v,q)
            q=[colcap(v) q];
            color(colcap(v))=GRIS;
            % Final de desencole
            pred(colcap(v))=u;
            
        end
    end
end
if color(fin)==NEGRO       % Si fin es accesible
    temp=fin;
    while pred(temp)~=inicio
        pathaumentado = [pred(temp) pathaumentado];     % El camino aumentado no contiene ni el inicio ni el fin
        temp=pred(temp);
    end
    pathaumentado=[inicio pathaumentado fin];
end