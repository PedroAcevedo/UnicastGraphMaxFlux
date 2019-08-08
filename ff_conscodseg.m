function [codseg,ijl] = ff_conscodseg(codseg, nodos_cod, tdr, ijl)
%ijl=length(codseg)+1;
for ij=1:length(tdr.tdrmn)
  codint=intersect(nodos_cod,tdr.tdrmn(ij).camino);
  if ~isempty(codint)
       nodos=[codint tdr.tdrmn(ij).camino(2)];
       swc=false;
       ik=1;
       while ~swc && ik<=length(codseg)
            if isequal(nodos, codseg(ik).nodos)
                swc=true;
            else
                ik=ik+1;
            end
        end
        if ~swc 
            codseg(ijl).nodos=nodos;
            ijl=ijl+1;
        end
  end
end