%Aqu� se debe ejecutar el algoritmo de disyuntos para cada nodo de
%codificaci�n y as� establecer las marcas. 
for jn=1:length(ncod)
    for jp=1:length(ncod(jn).predecesor)
        fa_min(ncod(jn).predecesor(jp),ncod(jn).nodo)=0;
        swdisy=ff_disyuntos(1,ncod(jn).destino,fa_min);
        if swdisy
            ncod(jn).marca(jp)=1;
        else
            ncod(jn).marca(jp)=0;
        end
        fa_min(ncod(jn).predecesor(jp),ncod(jn).nodo)=1;  
    end
end

f=1;
ncdep=[];
for jn=1:length(ncod)
    if ~isempty(find(ncod(jn).marca~=0))
 %       c=1;
 %       for jp=1:length(ncod(jn).marca)
 %           if ncod(jn).marca(jp)==1
 %               matenl(f,c)=ncod(jn).predecesor(jp);
 %           else
 %               matenl(f,c)=0;
 %           end
 %           c=c+1;
 %       end
        ncdep=[ncdep ncod(jn)];
    end
    f=f+1;
end
f=f-1;
%c=c-1;

%disp(matenl);
disp(ncdep);


%icom=[];
%valida=false(f,c);
%while kc<=ncomb Aqu� se debe  controlar por el n�mero de combinaciones
%for jf=1:f
%    jc=1;
%    sw=false;
%    while jc<=c && ~sw
%        if matenl(jf,jc)~=0 && ~valida(jf,jc)
%           icom=[icom matenl(jf,jc)];
%           valida(jf,jc)=true;
%           sw=true;
%        else
%            jc=jc+1;
%        end        
%    end
%end
%for kq=1:length(icom)
%    fa_min(icom(kq),ncdep(kq).nodo)=0; 
%end
%swdisy=true;
%kn=1;
%while kn<=length(ncdep) && swdisy 
%    swdisy=ff_disyuntos(1,ncdep(kn).destino,fa_min,des.nodo);
%    kn=kn+1;
%end
%if ~swdisy
%    t=q(end);
%    q(end)=[];
%    while ~isempty(q) && ~swdisy
%        
%    end
    
%end
