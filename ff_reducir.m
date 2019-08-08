function ar = ff_reducir(a)
 au=unique(a);
 ar=[];
 for x=1:length(au)
     if mod(sum(a==au(x)),2)==1
         ar=[ar au(x)];
     end
 end
end