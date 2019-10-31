#!/bin/bash
cd ..
grafos=($( ls graphs/ |	sort -V | sed -e 's/\..*$//'))
selected=$(echo ${grafos[$1]}| sed 's/[1-9]des//g')
number=$(echo ${grafos[$1]} | tail -c 5 | sed 's/des//g')
echo ${grafos[$1]}
{ echo $selected; echo $number; }|/usr/local/MATLAB/R2018b/bin/matlab -nodesktop -nosplash -r ff_rutasDisyuntas42_p > Results.txt
#Retrieve execution time
rutadest=$(cat Results.txt | awk '/^#/')
echo $rutadest
c=$(cat Results.txt  | awk '/^Elapsed/ { print $4}')
#Retrieve the generated file for validate on C++
f=$(tail -n 1 Results.txt )
cd scripts/networkCodingValidator
#Prueba la validez del grafo
{ echo $f; echo 1; echo 1; } |./proyecto_final_Salcedo_Carolina >&-
#Dice si el grafo resultante es valido o no
NetworkC=$(grep ok -n $f-sim-let.out | wc -l)
if [ ! $NetworkC == 0 ]; then echo si, si es valido con Networ Coding; else echo no, no es valido con Network Coding; fi
rm -r ../../Results.txt
