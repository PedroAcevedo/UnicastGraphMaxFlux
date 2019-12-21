# UnicastGraphMaxFlux

Este proyecto se encuentran los archivos y programas desarrollados en el proyecto de tesis "Códigos de Red Aplicados sobre Múltiples Flujos de Datos en Transmisión Multicast" del profesor Jose Duvan Marquez, Phd, junto con la participación de los estudiantes Pedro Acevedo y Carlos Conrado en la modificación de uno de los componentes de dicha tesis, para su proyecto final de pregrado del programa de ingeniería de sistemas y computación de la Universidad del Norte.  

Para correr el programa.

a_proyecto_final2.m --> Algoritmo propuesto (Matriz de adyacencia de caminos)

a_proyecto_final.m --> Algoritmo previo (Colisiones) 

Disjoints_routesv3.m --> Versión actual.

ff_grafo(..); --> Descomentar para dibujar los grafos.

Para correr scripts de prueba dirigirse a la carpeta scripts y ejecutar los siguientes comandos (UBUNTU).

Prueba con los primeros 35 grafos, ambos algoritmos,

```
sudo ./TestingScript.sh > resultsHTML/Resultados-versionX.html
```
Prueba con un solo grafo por parametro, algoritmo propuesto.

```
sudo ./TestOneGraph.sh 1
```
Archivo de configuracion para el generador de grafos: generator/conf/generator.conf

Compilar el generador(usando GCC):
 
```
g++ -g -Wall -o generator generator.cpp
```
Tambien se puede compilar con Make:

```
make
```
Ejecutar el generador:

```
./generator
```


Esto obtiene como resultado una tabla en formato HTML.

<img src="/scripts/table.png" alt="tabla de resultados"/>
