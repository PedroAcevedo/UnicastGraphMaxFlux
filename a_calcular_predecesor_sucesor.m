function memoPredSus = a_calcular_predecesor_sucesor(adj, memo, dist, actual, pred)
    tam = size(memo);
    if dist > tam(1)
        for i = 1:length(adj);
            memo(dist,i).pred = [];
            memo(dist,i).sus = [];
            memo(dist,i).taken = 0;
            memo(dist,i).paths = [];
        end
    end
    memo(dist,actual).pred = [memo(dist,actual).pred pred];
    if memo(dist,actual).taken == 0
        memo(dist,actual).taken = 1;
        for i = 1:length(adj);
            if adj(actual, i) == 1
                memo(dist,actual).sus = [memo(dist,actual).sus i];
                memo = a_calcular_predecesor_sucesor(adj, memo, dist+1, i, actual);
            end
        end
    end
    memoPredSus = memo;
end