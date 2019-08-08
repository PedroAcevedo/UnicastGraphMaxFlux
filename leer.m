clc
clear all
ngrafo = input('Archivo de grafo = ', 's');
nd = input('Número de destinos = ');
des.nodo = dlmread(ngrafo,' ', [0 0 0 nd-1]);
C = dlmread(ngrafo,' ',1,0);
disp(des.nodo);
disp(C);


