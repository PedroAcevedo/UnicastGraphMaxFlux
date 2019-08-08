 function [xorvect, sw]= ff_xorvect(a,b)
 ar=ff_reducir(a);
 br=ff_reducir(b);
 %display(ar);
 %display(br);
 %swr=false; % swr determina que el xor es vac�o por tener un conjunto 
            %vac�o y no por la acci�n propia del xor
 if isempty(ar) || isempty(br)
     xorvect=[];
     %xx=input('Genero vac�o. Dar enter...');
%     swr=true;
 else
     xorvect=setxor(ar,br);
     %xx=input('No genera vac�o. Dar enter...');
%     uab=union(ar,br);
%     an=setdiff(uab,ar);
%     bn=setdiff(uab,br);
%     uabn=union(an,bn);
%     xorvect=intersect(uab,uabn);
 end
 if isempty(xorvect)
     sw=false; % sw que determina si el xor es vac�o o no
 else
     sw=true;
 end
  %display(xorvect);
 end