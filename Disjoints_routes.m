function [disjoints] = Disjoints_routes(t,rutas)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    adj = zeros(t,t);  
    weigth = zeros(1,length(rutas));
%    lens = zeros(1,length(rutas));
    for ia=1:length(rutas)
        for ja=1:length(rutas(ia).camino)-1
            adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) = adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) + 1;
        end
    end
%% Version1    
%   for ia=1:length(rutas)
%         for ja=1:length(rutas(ia).camino)-1
%             weigth(ia) = weigth(ia) + adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1));
%         end
%         weigth(ia) = weigth(ia) + length(rutas(ia).camino)*2;
%     end
    
%VERSION 2
for ia=1:length(rutas)
      weigth(ia) = length(rutas(ia).camino)*2 + sum(adj(rutas(ia).camino(2:end-1),:),'all');
end

%%Version 3
%   for ia=1:length(rutas)
%       weigth(ia) = sum(adj(rutas(ia).camino(2:end-1),:),'all');
%       lens(ia) = length(rutas(ia).camino);
%   end
    segs = length(find(adj(1,:)~=0));
    disjoints = zeros(1,length(segs));
    f = 0;
%    while ~(isempty(find(weigth ~= intmax('int16'), 1)))
     while ~(isempty(find(weigth ~= intmax('int32'), 1)))
        [~, ind] = min(weigth);
%V3
%         [~, mind] = min(lens);
%         routes = find(weigth == min(weigth(lens == lens(mind))))
%         ind = routes(1);
        f = f + 1;
        disjoints(f) = ind;
        if(length(disjoints) == segs)
            break;
        end
        adj(rutas(ind).camino(1),rutas(ind).camino(2)) = 0;
        for ja=2:length(rutas(ind).camino)
            adj(rutas(ind).camino(ja),:) = 0;
        end
%% V1        
%         for ia=1:length(rutas)
%             if(weigth(ia)~=intmax('int32'))
%                 for ja=1:length(rutas(ia).camino)-1
%                     if(adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) == 0 )
%                         weigth(ia) = intmax('int32');
%                         break;
%                     end
%                 end
%                end
%          end

%V2        
        for ia=1:length(rutas)
            if(weigth(ia)~=intmax('int32'))
                for ja=1:length(rutas(ia).camino)-1
                    if(adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) == 0 )
                        weigth(ia) = intmax('int32');
                        break;
                    end
                end
                if(weigth(ia) == intmax('int32'))
                    for ja=1:length(rutas(ia).camino)-1
                        if(adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) ~= 0)
                            adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1))= adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1))-1;  
                        end
                    end
                end
            end
        end
        for ia=1:length(rutas)
            if(weigth(ia)~=intmax('int32'))
                weigth(ia) = sum(adj(rutas(ia).camino(2:end-1),:),'all');
            end
        end

%%V3
%         for ia=1:length(rutas)
%             if(weigth(ia)~=intmax('int16'))
%                 for ja=1:length(rutas(ia).camino)-1
%                     if(adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) == 0 )
%                         weigth(ia) = intmax('int16');
%                         lens(ia) = intmax('int16');
%                         break;
%                     end
%                 end
%                 if(weigth(ia) == intmax('int16'))
%                     for ja=1:length(rutas(ia).camino)-1
%                         if(adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1)) ~= 0)
%                             adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1))= adj(rutas(ia).camino(ja),rutas(ia).camino(ja+1))-1;  
%                         end
%                     end
%                 end
%             end
%         end
%         for ia=1:length(rutas)
%             if(weigth(ia)~=intmax('int16'))
%                 weigth(ia) = sum(adj(rutas(ia).camino(2:end-1),:),'all');
%             end
%         end
    end
    disjoints = disjoints(1:f);
end

