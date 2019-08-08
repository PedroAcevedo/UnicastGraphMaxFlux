function [minmaxflujo,nodos_cod,swseguir,swp] = ff_opt_minflujo3(minflujo, nodos_cod, minmaxflujo, dest,segnodtot,swseguir)
jj=1;
ndest=length(dest);
tdrmin=[];
ll=0;
for ii=1:ndest
    tdrdest=ff_todas_las_rutas4(1,dest(ii),minmaxflujo);
    if length(tdrdest)>minflujo
        tdrmin(jj).tdrmn=tdrdest;
        ll=ll+1;
        contseg=zeros(1,length(segnodtot));
        penultimo=[];
        for kk=1:length(tdrdest)
            penultimo=union(penultimo, tdrdest(kk).camino(end-1));
            segnod=find(segnodtot==tdrdest(kk).camino(2));
            contseg(segnod)=contseg(segnod)+1;
        end
        contarseg(ll,:)=contseg;
        for kk=1:length(penultimo)
            extremos(kk).pen=penultimo(kk);
            extremos(kk).listseg=[];
        end
        for kk=1:length(tdrdest)
            pospen=find(penultimo==tdrdest(kk).camino(end-1));
            extremos(pospen).listseg=[extremos(pospen).listseg tdrdest(kk).camino(2)];
        end
        tdrmin(jj).extremos=extremos;
        jj=jj+1;
    end
end
ijl=1;
codseg(ijl).nodos=[];
for hkl=1:length(tdrmin)    
    sw=false;
    jkl=1;
    while ~sw && jkl <= length(tdrmin(hkl).extremos) - 1
        swe=false;
        aa=ff_reducir(tdrmin(hkl).extremos(jkl).listseg);
        ikl=jkl+1;
        while ~swe && ikl <= length(tdrmin(hkl).extremos)
            if isequal(aa, ff_reducir(tdrmin(hkl).extremos(ikl).listseg))
                swe=true;
                [codseg,ijl] = ff_conscodseg2(codseg, nodos_cod, tdrmin(hkl), ijl);
            else
                ikl=ikl+1;
            end
        end
        if swe
            sw=true;
        else
            jkl=jkl+1;
        end
    end
    if ~sw %%% AGREGADO
        swr=false;
        kjl=1;
        while ~swr && kjl <= length(tdrmin(hkl).extremos)
            aa=ff_reducir(tdrmin(hkl).extremos(kjl).listseg);
            if isempty(aa)
                swr=true;
            else
                kjl=kjl+1;
            end
        end
        if swr
            [codseg,ijl] = ff_conscodseg2(codseg, nodos_cod, tdrmin(hkl), ijl);
        end
    end  %%% FIN AGREGADO
end
if isempty(codseg(1).nodos)
    codseg=[];
%    swseguir=false;
end
swc=false;
hkl=1;
while ~swc && hkl<=length(codseg)
    sw=true;
    ikl=1;
    conj2=[codseg(hkl).nodos(1) codseg(hkl).nodos(end)];
    sumiseg=[]; % AGREGAGO PARA CORREGIR CASO DE ELIMINAR ENLACES DE SEGUNDO NODO INCORRECTO.
    while sw && ikl<=length(tdrmin)
        %jkl=1;
        swe=false;
        peneleg=[];
        for jkl=1:length(tdrmin(ikl).tdrmn)
            codint=intersect(nodos_cod, tdrmin(ikl).tdrmn(jkl).camino);
            if ~isempty(codint)
                nodos=[codint tdrmin(ikl).tdrmn(jkl).camino(2)];
                conj1=[nodos(1) nodos(end)];
                
                if length(nodos)>length(codseg(hkl).nodos)
                    conj=nodos;
                    subconj=codseg(hkl).nodos;
                else
                    conj=codseg(hkl).nodos;
                    subconj=nodos;
                end

                if all(ismember(subconj, conj)) && isequal(conj1,conj2)
                    swe=true;
                    peneleg=[peneleg jkl];
                    rutesc=jkl;
                    tcod=conj(1);
                    
                end
            end
        end
        if swe
            posextrmod=[];
            for jkl=1:length(peneleg)
                tpen=tdrmin(ikl).tdrmn(peneleg(jkl)).camino(end-1);
                tsec=tdrmin(ikl).tdrmn(peneleg(jkl)).camino(2);
                ijl=1;
                swa=false;
                while ~swa && ijl<=length(tdrmin(ikl).extremos)
                    if tdrmin(ikl).extremos(ijl).pen==tpen
                        swa=true;
                    else
                        ijl=ijl+1;
                    end
                end
                possec=1;
                sws=false;

                while ~sws && possec<=length(tdrmin(ikl).extremos(ijl).listseg)
                    if tdrmin(ikl).extremos(ijl).listseg(possec)==tsec
                        sws=true;
                        %Retiro del segundo nodo para probar
                        tdrmin(ikl).extremos(ijl).listseg(possec)=[];
                        %Posiciones de extremos modificados
                        posextrmod=[posextrmod ijl];
                    else
                        possec=possec+1;
                    end
                end
            end
            zxor=tdrmin(ikl).extremos(1).listseg;
            swx=true;
            iex=2;
            while swx && iex <=minflujo
                [zxor, swx]=ff_xorvect(zxor, tdrmin(ikl).extremos(iex).listseg);
                if swx 
                    iex=iex+1;
                end
            end
            %Recuperación del segundo nodo que fue retirado para prueba
            for ijl=1:length(posextrmod)
                tdrmin(ikl).extremos(posextrmod(ijl)).listseg(end+1)=tsec;
            end
            
            if ~swx %&& ~tdrmin(ikl).val
                 sw=false;
            else
                sumiseg=[sumiseg; ikl]; % AGREGAGO PARA CORREGIR CASO DE ELIMINAR ENLACES DE SEGUNDO NODO INCORRECTO.
                selsum=ikl;
                selrut=rutesc;
                ikl=ikl+1;
            end
        else
            ikl=ikl+1;
        end
    end
    if ikl-length(tdrmin)==1 %Terminó todas las pruebas en tdrmin con un string de nodos codificación
        contarseg(sumiseg,segnodtot==tsec)=contarseg(sumiseg,segnodtot==tsec)-1; % AGREGAGO PARA CORREGIR CASO DE ELIMINAR ENLACES DE SEGUNDO NODO INCORRECTO.
        if nnz(contarseg(:,segnodtot==tsec)) >=length(tdrmin)
            swc=true;
        else
            contarseg(sumiseg,segnodtot==tsec)=contarseg(sumiseg,segnodtot==tsec)+1; %AGREGAGO PARA CORREGIR CASO DE ELIMINAR ENLACES DE SEGUNDO NODO INCORRECTO. Recuperando lo restado
            hkl=hkl+1;
        end
    else
        hkl=hkl+1;
    end 
end
swp=false;
if swc
    [minmaxflujo, nodos_cod] = ff_actflujo(minmaxflujo, nodos_cod, tdrmin, selsum, selrut, tcod);
else
    swseguir=false;
%     segnodtot=find(minmaxflujo(1,:)==1);
% 
    if length(segnodtot)==minflujo
        [tcod,selsum,selrut,swp] = ff_supmat(tdrmin,minflujo,dest,segnodtot, nodos_cod);
        if swp
            [minmaxflujo, nodos_cod] = ff_actflujo(minmaxflujo, nodos_cod,tdrmin, selsum, selrut, tcod);    
        end
    end
end
end
