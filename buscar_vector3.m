function buscar_vec=buscar_vector3(t,flujo, cont_flujo) 
  pos_dest=find(flujo(t,:)~=0);
  k=1;
  sw=false;
  while (k<=length(pos_dest)) && (~sw)
      if cont_flujo(t,pos_dest(k))==0
          sw=true;
      else
          k=k+1;
      end
  end
  buscar_vec=sw;
end