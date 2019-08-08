function rutas = a_obtener_rutas(colum, max_d)
    rut = [];
    index = 1;
    for i = 1:max_d
        if colum(i).taken == 1
            tam = size(colum(i).paths);
            for j = 1:tam(1)
                rut(index).camino = colum(i).paths(j,:);
                index = index + 1;
            end
        end
    end
    rutas = rut;
end