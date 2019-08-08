function memoRutas = a_expansion_rutas(memo, n, max_d)
    initP = [1];
    memo(1,1).paths = initP;
    for i = 1:max_d
        for j = 1:n
            if memo(i,j).taken == 1
                for su = 1:length(memo(i,j).sus)
                    tam = size(memo(i,j).paths);
                    for pat = 1:tam(1);
                        memo(i+1,memo(i,j).sus(su)).paths = [memo(i+1,memo(i,j).sus(su)).paths; memo(i,j).paths(pat,:) memo(i,j).sus(su)];
                    end
                end
            end
        end
    end
    memoRutas = memo;
end