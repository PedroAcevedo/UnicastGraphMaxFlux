function escribirGrafo = ff_escribirGrafo(M)
[fil,col]=size(M);
for i=1:fil
    for j=1:col
        fprintf('%d ',M(i,j));
    end
    fprintf('\n');
end
end