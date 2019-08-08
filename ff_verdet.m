function [tcod,selsum,selrut,sw] = ff_verdet(tdrmin,minflujo,dest,segnodtot, nodos_cod)
%function [tsupmat,supmat,codseg,tcod,selsum,selrut] = ff_supmat(tdrmin,minflujo,dest,segnodtot, nodos_cod)
supmat=zeros(minflujo,minflujo,length(dest));
tcod=[];
selsum=[];
selrut=[];
%swp=false;
for hn=1:length(tdrmin)
    for in=1:minflujo
        for jn=1:length(tdrmin(hn).extremos(in).listseg)
             supmat(in,:,hn)=supmat(in,:,hn)+(tdrmin(hn).extremos(in).listseg(jn)==segnodtot);
        end
    end
end
%tsupmat=mod(supmat,2);
msupmat=mod(supmat,2);

for hn=1:length(tdrmin)
    dsupm(hn)=det(msupmat(:,:,hn));
end
sw=false;
% sw=nnz(dsupm)==length(dest);
if nnz(dsupm)~=length(dest) % ~sw
%     codseg(1).nodos=[];
%    ijl=1;
    codseg=[];
    for hn=1:length(tdrmin)
%       [codseg,ijl]=ff_conscodseg2(codseg, nodos_cod, tdrmin(hn),ijl);
        [codseg]=ff_conscodseg3(codseg, nodos_cod, tdrmin(hn));
    end
    hn=1;
%    psupmat=tsupmat;
    while ~sw && hn<=length(codseg)
        swt=false;
        jn=1;
        tsupmat=msupmat;
        tdsupm=dsupm;
        while ~swt && jn<=length(tdrmin)
            pensel=[];
            for kn=1:length(tdrmin(jn).tdrmn)
                codint=intersect(nodos_cod, tdrmin(jn).tdrmn(kn).camino);
                if ~isempty(codint)
                    nodos=[codint tdrmin(jn).tdrmn(kn).camino(2)];
                    if all(ismember(nodos, codseg(hn).nodos))
                        pensel=[pensel kn];
                        tcod=nodos(1);
                        selsum=jn;
                        selrut=kn;
                    end
                end
            end
            if ~isempty(pensel)
                for kn=1:length(pensel)
                    tsec=tdrmin(jn).tdrmn(pensel(kn)).camino(2);
                    tpen=tdrmin(jn).tdrmn(pensel(kn)).camino(end-1);
                    swa=false;
                    fil=1;
                    while ~swa && fil <= length(tdrmin(jn).extremos)
                        if tdrmin(jn).extremos(fil).pen == tpen
                            swa=true;
                        else
                            fil=fil+1;
                        end
                    end
                    col=find(segnodtot==tsec);
                    tsupmat(fil,col,jn)=mod(tsupmat(fil,col,jn)+1,2);
                end
%                 dp=det(tsupmat(:,:,jn));
%                 tdsupm(jn)=dp;
                tdsupm(jn)=det(tsupmat(:,:,jn));
%                 if dp ~= 0
                if tdsupm(jn)
                    jn=jn+1;
                else
                    swt=true;  % Se cambia para no continuar revisando los tdrmin.
                end
            else
                jn=jn+1;
            end
        end
        if ~swt  %Todos los sumideros revisados pasaron la  prueba del  determinante, no se tiene si todos los sumideros están bien.
            if nnz(tdsupm)==length(dest) % Se prueba si todos los sumideros: los probados y los que ya estaban, cumplen con el determinante.
                sw=true;
%                 swp=true;
            else
                hn=hn+1;
            end
        else
            hn=hn+1;
        end
    end
end   
