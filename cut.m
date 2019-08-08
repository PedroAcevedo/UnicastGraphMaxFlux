%WHITE =0;
%GRAY=1;
%BLACK=2

function cut=cut(start,residual,n)
    WHITE =0;
    GRAY=1;
    BLACK=2;
    cut(1:n)=WHITE;
    %head=1;
    %tail=1;
    q=[];
    %cut=[];
    
    %ENQUEUE
    q=[start q];
    cut(start)=GRAY;
    
    %pred(start) = -1;
    
    pred=zeros(1,n);
    while ~isempty (q) 
    %    [u,q]=dequeue(q);
            u=q(end);
            q(end)=[];
            cut(u)=BLACK;
    %     dequeue end here
            
            for v=1:n
                if (cut(v)==WHITE && residual(u,v)>0)
    %enqueue(v,q)
                    q=[v q];
                    cut(v)=GRAY;
    % enqueue end here
                    pred(v)=u;                        

                end
            end
    end
    cut(cut==2)=1;
    
    
    
        
