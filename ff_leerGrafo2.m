%Leer grafo para ff_rutasDisyuntas421.m
function [leerGrafo, dest] = ff_leerGrafo2(ngrafo)
% ngrafo = input('Archivo de grafo = ', 's');
% nd = input('Número de destinos = ');
% ngrafo = strcat(ngrafo,int2str(nd),'des.txt');
nd=ngrafo(strfind(ngrafo,'v')+1:strfind(ngrafo,'des')-1);
nd=str2num(nd);
dest = dlmread(ngrafo,' ', [1 0 1 nd-1]);
C = dlmread(ngrafo,' ',2,0);
fprintf('Nodos destinos\n');
disp(dest);
leerGrafo=C;
end
