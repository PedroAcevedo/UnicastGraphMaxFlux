%Leer grafo
function [leerGrafo, dest] = ff_leerGrafo()
ngrafo = input('Archivo de grafo = ', 's');
%ngrafo = strcat(ngrafo,'.txt'); 
nd = input('N�mero de destinos = ');
ngrafo = strcat("graphs/",ngrafo,int2str(nd),'des.txt');
dest = dlmread(ngrafo,' ', [1 0 1 nd-1]);
C = dlmread(ngrafo,' ',2,0);
%nn = length(C);
fprintf('Nodos destinos\n');
disp(dest);
leerGrafo=C;
end
