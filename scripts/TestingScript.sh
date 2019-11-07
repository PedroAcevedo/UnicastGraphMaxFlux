#!/bin/bash
grafos=($( ls ../graphs/ |	sort -V | sed -e 's/\..*$//'))
echo "<!DOCTYPE html>
<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
</head>
<body>
<h2>HTML Table of results</h2>

<table>
  <tr>
    <th>Graphs</th>
    <th>Previus algorithm</th>
    <th>Is NC valid?</th>
    <th>Proposed algorithm</th>
    <th>Is NC valid?</th>
    <th>Is equal?</th>
  </tr>"
for g in {102..151}
do
	selected=$(echo ${grafos[$g]}| sed 's/[1-9]des//g')
	number=$(echo ${grafos[$g]} | sed 's/[a-z]*[A-Z]*[0-9]*_//g; s/des//g')
	echo '<tr><th>' ${grafos[$g]} '</th>'
	rutasdest=( 0 0 )
	ind=0
	for algorithm in ff_rutasDisyuntas42 ff_rutasDisyuntas42_p
	do	
		cd ..
		{ echo $selected; echo $number; }|/usr/local/MATLAB/R2018b/bin/matlab -nodesktop -nosplash -nojvm -r $algorithm > Results.txt
		#Retrieve execution time
		rutasdest[$ind]=$(echo $(cat Results.txt | awk '/^#/{print}' | sed 's/#//g'))
		ind=$ind+1
		c=$(cat Results.txt  | awk '/^Elapsed/ { print $4}')
		echo '<th>'$c'</th>'
		#Retrieve the generated file for validate on C++
		f=$(tail -n 1 Results.txt )
		cd scripts/networkCodingValidator
		#Prueba la validez del grafo
		{ echo $f; echo 1; echo 1; } |./proyecto_final_Salcedo_Carolina >&-
		#Dice si el grafo resultante es valido o no
		NetworkC=$(grep ok -n $f-sim-let.out | wc -l)
		if [ ! $NetworkC == 0 ]; then echo '<th>yes</th>'; else echo '<th>no</th>'; fi
		cd ..
	done
	if [ "${rutasdest[0]}" == "${rutasdest[1]}" ]; then echo '<th>yes</th>'; else echo '<th>no</th>'; fi
	echo '</tr>'
done

echo "</table>
</body>
</html>"
rm -r ../Results.txt
