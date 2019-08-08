%BLANCO =0;
%GRIS=1;
%NEGRO=2

function pathaumentado=ff_pathaumentado1(inicio,fin,flujo_actual,capacity) %,n)
    BLANCO=0;
    GRIS=1;
    NEGRO=2;
    color(1:fin)=BLANCO;
    %head=1;
    %tail=1;
    q=[];
    pathaumentado=[];
    
    % Encolamiento
    q=[inicio q];
    color(inicio)=GRIS;
    
    %pred(inicio) = -1;
    
    pred=zeros(1,fin);
    while ~isempty (q) 
    %    [u,q]=desencole(q);
            u=q(end);
            q(end)=[];
            color(u)=NEGRO;
    %     Final de densencolamiento
            
            for v=1:fin
                if (color(v)==BLANCO && capacity(u,v)>flujo_actual(u,v) )
    %Encole(v,q)
                    q=[v q];
                    color(v)=GRIS;
    % Final de desencole 
                    pred(v)=u;                        

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
    else
       pathaumentado=[];         
    end
    
        
