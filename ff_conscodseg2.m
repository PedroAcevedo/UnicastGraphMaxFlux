function [codseg,ijl] = ff_conscodseg2(codseg, nodos_cod, tdr, ijl)
%ijl=length(codseg)+1;
for ij=1:length(tdr.tdrmn)
  codint=intersect(nodos_cod,tdr.tdrmn(ij).camino);
  if ~isempty(codint)
       nodos=[codint tdr.tdrmn(ij).camino(2)];  
       swc=false;
       if ijl>1
%            conj1=[nodos(1) nodos(end)];
           ik=1;
           while ~swc && ik<=length(codseg)
%                conj2=[codseg(ik).nodos(1) codseg(ik).nodos(end)];
               if length(nodos)>length(codseg(ik).nodos)
                   conj=nodos;
                   subconj=codseg(ik).nodos;
               else
                   conj=codseg(ik).nodos;
                   subconj=nodos;
               end
               if all(ismember(subconj, conj)) %&& isequal(conj1,conj2)
                   if length(codseg(ik).nodos) < length(nodos)
                       codseg(ik).nodos=nodos;
                   end
                   swc=true;
               else
                   ik=ik+1;
               end
           end
       end
       if ~swc
           codseg(ijl).nodos=nodos;
           ijl=ijl+1;
       end
  end
end