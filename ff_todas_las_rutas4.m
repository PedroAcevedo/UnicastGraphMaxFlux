function todas_las_rutas = ff_todas_las_rutas4(orig,dest,flujo)
    ruta=[];
    if dest > orig
        l=length(flujo);
        q=[orig];
        for icf=1:l
            for jcf=1:l
                cont_flujo(icf,jcf)=0;
            end
        end
        k=1;
        while ~isempty(q)
            i=q(end);
            j=2;
            sw=false;
            while (j<=dest) && (~sw)
                if (flujo(i,j)~=0) && (cont_flujo(i,j)==0)
                    q=[q j];
                    cont_flujo(i,j)=1;
                    sw=true;
                else
                    j=j+1;
                end
            end
            if j==dest 
                ruta(k).camino=q;
                k=k+1;
                d=q(end);   %no se hace nada con esta asignación, porque no utilizo la d calculada aquí         
                q(end)=[];
                t=q(end);
                cont_flujo(t,:)=0;
                if length(q)>1 
                    d=q(end);
                    q(end)=[];
                    t=q(end);
                else
                    q(end)=[];
                end
                if t==orig
                    sw=true;
                else
                    sw=buscar_vector3(t,flujo,cont_flujo);
                end
                while (~sw) && (~isempty(q))
                    cont_flujo(t,d)=0;
                    if ~isempty(find(cont_flujo(t,:)==2 | cont_flujo(t,:)==1)) 
                        for jk=1:l
                            if cont_flujo(t,jk)==2 || cont_flujo(t,jk)==1  
                                cont_flujo(t,jk)=0;
                            end
                        end
                    end
                    d=q(end);
                    q(end)=[];
                    if ~isempty(q)
                        t=q(end);
                        sw=buscar_vector3(t,flujo,cont_flujo); 
                    end
                end
                if sw
                    cont_flujo(t,d)=2;
                end
            else
                if j>dest
                    t=q(end);
                    q(end)=[]; %si no existe un camino de longitud 1 entre el origen y el destino, cualquier iteración va a llevar a pasar de una vez a vaciar la pila 
                    if ~isempty(q)
                        if q(end)==orig
                            for icf=orig+1:l %aquí cambié icf=2:l por icf=orig+1,l
                                for jcf=1:l
                                    cont_flujo(icf,jcf)=0;
                                end
                            end   
                            cont_flujo(orig,t)=1; %ojo si se debe quitar, ya está puesto
                        else
                            if ~isempty(find(cont_flujo(t,:)==2 | cont_flujo(t,:)==1)) 
                                for jk=1:l
                                    if cont_flujo(t,jk)==2 || cont_flujo(t,jk)==1
                                        cont_flujo(t,jk)=0;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    todas_las_rutas=ruta;
end