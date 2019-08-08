function [opt_minflujo, nodos_cod] = ff_opt_minflujo(minflujo, nodos_cod, minmaxflujo, dest)
jj=1;
ndest=length(dest);
tdrmin=[];
for ii=1:ndest
    tdrdest=ff_todas_las_rutas4(1,dest(ii),minmaxflujo);
    if length(tdrdest)>minflujo
        tdrmin(jj).tdrmn=tdrdest;
%        contseg(1:length(segnodtot))=0;
%        segundos=[];
        penultimo=[];
        for kk=1:length(tdrdest)
%            segundos=union(segundos, tdrdest(kk).camino(2));
            penultimo=union(penultimo, tdrdest(kk).camino(end-1));
%            segnod=find(segnodtot==tdrdest(kk).camino(2));
%            contseg(segnod)=contseg(segnod)+1;
        end
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
%clc;
ijl=1;
%minflujo=3; % OJO: CAMBIARLA POR CADA PRUEBA
codseg(ijl).nodos=[];
for hkl=1:length(tdrmin)    
    sw=false;
    jkl=1;
    tdrmin(hkl).val=true; %% POSIBLEMENTE ELIMINAR TODO LO DE .val
    while ~sw && jkl <= length(tdrmin(hkl).extremos) - 1
        swe=false;
        aa=ff_reducir(tdrmin(hkl).extremos(jkl).listseg);
        ikl=jkl+1;
        while ~swe && ikl <= length(tdrmin(hkl).extremos)
            if isequal(aa, ff_reducir(tdrmin(hkl).extremos(ikl).listseg))
                swe=true;
                tdrmin(hkl).val=false;%% POSIBLEMENTE ELIMINAR TODO LO DE .val
                for ij=1:length(tdrmin(hkl).tdrmn)
                    codint=intersect(nodos_cod,tdrmin(hkl).tdrmn(ij).camino);
                    if ~isempty(codint)
                        nodos=[codint tdrmin(hkl).tdrmn(ij).camino(2)];
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
                   tdrmin(hkl).val=false;
              else
                   kjl=kjl+1;
              end
          end
          if swr
               for ij=1:length(tdrmin(hkl).tdrmn)
                   codint=intersect(nodos_cod,tdrmin(hkl).tdrmn(ij).camino);
                   if ~isempty(codint)
                        nodos=[codint tdrmin(hkl).tdrmn(ij).camino(2)];
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
          end           
     end  %%% FIN AGREGADO
end
if isempty(codseg(1).nodos)
    codseg=[];
end
swc=false;
hkl=1;
while ~swc && hkl<=length(codseg)
    sw=true;
    ikl=1;
    while sw && ikl<=length(tdrmin)
        jkl=1;
        swe=false;
        while ~swe && jkl<=length(tdrmin(ikl).tdrmn)
            codint=intersect(nodos_cod, tdrmin(ikl).tdrmn(jkl).camino);
            if ~isempty(codint)
                nodos=[codint tdrmin(ikl).tdrmn(jkl).camino(2)];
                %%intnodos=intersect(nodos,codseg(hkl).nodos); %%% AGREGADO
                %% Aqu� se debe probar si intnodos es subconjunto de
                %% codseg(codseg(hkl).nodos.
                %if isequal(sort(intnodos),sort(codseg(hkl).nodos)) %% CAMBIO
%                if isequal(nodos, codseg(hkl).nodos)
                conj1=[nodos(1) nodos(end)];
                conj2=[codseg(hkl).nodos(1) codseg(hkl).nodos(end)];
                if length(nodos)>length(codseg(hkl).nodos)
                    conj=nodos;
                    subconj=codseg(hkl).nodos;
                else
                    conj=codseg(hkl).nodos;
                    subconj=nodos;
                end
                if all(ismember(subconj, conj)) && isequal(conj1,conj2)
                    swe=true;
                else
                    jkl=jkl+1;
                end
            else
                jkl=jkl+1;
            end
        end
        if swe
            tpen=tdrmin(ikl).tdrmn(jkl).camino(end-1);
            tsec=tdrmin(ikl).tdrmn(jkl).camino(2);
            tcod=nodos(1);
            ijl=1;
            swp=false;
            while ~swp && ijl<=length(tdrmin(ikl).extremos)
                if tdrmin(ikl).extremos(ijl).pen==tpen
                    swp=true;
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
                else
                     possec=possec+1;
                end
            end
               
            zxor=tdrmin(ikl).extremos(1).listseg;
            for iex=2:minflujo
                [zxor, swx]=ff_xorvect(zxor, tdrmin(ikl).extremos(iex).listseg);
            end
            %Recuperaci�n del segundo nodo que fue retirado para prueba
            tdrmin(ikl).extremos(ijl).listseg(end+1)=tsec;
            if ~swx %&& ~tdrmin(ikl).val
                 sw=false;
            else
                swi=ff_config_listseg(nodos,tdrmin(ikl),tsec,minflujo);
                if ~swi
                    sw=false;
                else
                %if swx && ~tdrmin(ikl).val
                    selsum=ikl;
                    selrut=jkl;
                    ikl=ikl+1;
                end  %Del if ~swi
                %ikl=ikl+1;
            end
        else
            ikl=ikl+1;
        end
    end
    if ikl-length(tdrmin)==1 %Termin� todas las pruebas en tdrmin con un string de nodos codificaci�n
        swc=true;
    else
        hkl=hkl+1;
    end 
end
if swc
    selnod=find(tdrmin(selsum).tdrmn(selrut).camino==tcod);
    tnodp=tdrmin(selsum).tdrmn(selrut).camino(selnod-1);
    minmaxflujo(tnodp,tcod)=0;
    if sum(minmaxflujo(:,tcod)) < 2
        pcod=find(nodos_cod==tcod);
        nodos_cod(pcod)=[];
    end
end
opt_minflujo=minmaxflujo;
end