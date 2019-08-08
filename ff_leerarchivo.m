%PROGRAMA QUE SE EJECUTA CON TODOS LOS GRAFOS DE PRUEBA
clc
clear all
filegrafo = input('Archivo de grafos = ', 's');
fidr = fopen(filegrafo, 'rt'); % opción rt para abrir en modo texto
fidw = fopen('tiempo2.txt','w');
%  nf=1;
 tiempoacum=[];
 nnodos=[];
while ~feof(fidr)
    linea=fgetl(fidr);
    display (linea);
    linea=strcat(linea,'.txt');
%     [tiempo, nenl]=ff_total_nc2_rutm_Mejor_v2(linea);  %BFS/DFS MÁS LARGO (ML)
%     [tiempo, nenl]=ff_total_nc2_38_Mejor2(linea);  % BFS/DFS PRIMERO (PRI)
    [tiempo, nenl]=ff_rutasDisyuntas421(linea);  % Disyuntas
    nn=str2num(linea(1:strfind(linea,'grafo')-1));
    nd=str2num(linea(strfind(linea,'v')+1:strfind(linea,'des')-1));
    fl=str2num(linea(strfind(linea,'grafo')+5:strfind(linea,'fm')-1));
%      tiempo=nf;
     tiempoacum=[tiempoacum tiempo];
     nnodos=[nnodos nn];
    fprintf(fidw,'%3d %3d %3d %3d  %2.6f\n',nn,nd,nenl,fl,tiempo);
    display (linea);
%      nf=nf+1;
end
% cdato=textscan(fid,'%s');
% cdato=cell2mat(cdato);
% formato = '%s %s %s %s %s'; % formato de cada línea
plot(nnodos,tiempoacum);
fclose(fidr); 
fclose(fidw);