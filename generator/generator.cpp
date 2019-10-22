#include <iostream>
#include <string>
#include <fstream>
#include <list> 
#include <iterator>
#include <unordered_map>
#include <algorithm>
#include <utility>
#include <stdlib.h>
#include <time.h>     
//#define PATH "../graphs/"

using namespace std;

bool contains(list<int> L, int element){
	return find(L.begin(), L.end(), element) != L.end();
}


class Graph {
  public:
    unordered_map<int, list<int>> adj;   
    list<int> sinks;
    unordered_map<int, int> weightNode;

    void addEdge(int a, int b){
    	if(adj.find(a) == adj.end()){
    		list<int> aux;
    		adj[a] = aux;
    	}
    	list<int> nodes = adj.at(a);
    	nodes.push_back(b);
    	adj[a] = nodes;
    	if(weightNode.find(b) == weightNode.end()){
    		weightNode[b] = 1;
    	}else{
    		weightNode[b] = weightNode.at(b) + 1;
    	}
    }

    bool existsEdge(int a, int b){
    	if(adj.find(a) != adj.end()){
    		return contains(adj.at(a),b);
    	}
    	return false;
    }

    int getWeightOUT(int n){
    	if(adj.find(n) != adj.end()){
    		return adj.at(n).size();
    	}
    	return 0;
    }

    int getWeightIN(int n){
    	return weightNode.at(n);
    }


    void removeEdge(int a, int b){
    	if(existsEdge(a,b)){
    		adj.at(a).remove(b);
    		int weightB = weightNode.at(b);
    		weightNode[b] = weightB-1;
    	}
    }

    
};


void createFile(string name){
	ofstream outfile (name);
	outfile << "something here" << endl;
	outfile.close();
}

string replaceElement(string original, int pos, string newVal){
	return original.substr(0,pos) + newVal + original.substr(pos+1);
}

void formatFile(list<list<int>> adj, int noNodes){
	string line("");
	for (int i = 0; i < noNodes; ++i){
		if(i == noNodes){
			line.append("0");
		}else{
			line.append("0 ");
		}
	}
	cout << line << endl;
	cout << replaceElement(line,(3-1)*2,"1") << endl;
	/*list <list<int>> :: iterator it; 
    for(it = adj.begin(); it != adj.end(); ++it){ 
        list <int> :: iterator it2;
        for(it2 = it.begin(); it2 != it.end();++it2){

        } 
    }
    cout << '\n'; */
 
}

void printGraph(unordered_map<int, list<int>> graph){
	unordered_map<int, list<int>>::iterator cursor;
	for (cursor = graph.begin(); cursor != graph.end(); ++cursor){
		list<int> nodes = cursor->second;
		list<int> :: iterator nodesIt;
		cout << cursor->first << " ->";
		for (nodesIt = nodes.begin(); nodesIt !=  nodes.end(); ++nodesIt)
		{
			cout << " " <<*nodesIt;
		}
		cout << endl;
	}
}


Graph generateMinGraph(int noNodes, list<int> sinks){
	Graph graph;
	graph.sinks = sinks;
	graph.sinks.push_back(noNodes);
	for (int i = 1; i < noNodes; ++i){
		if(!contains(sinks,i)){
			graph.addEdge(i,i+1);
		}else{
			int aux = i-1;
			while(contains(sinks, aux)){
				aux--;
			}
			graph.addEdge(aux, i+1);
		}
	}
	return graph;
}


int getSuitableRandomNode(int distance, int nodeA,Graph graph){
	srand (time(NULL));
	int attemp = 0;
	do{
		attemp =  (int)rand() % (distance+1) + nodeA;
	}while(graph.existsEdge(nodeA,attemp));
	return attemp;
}

int getSuitableLowestWeightNode(Graph graph, int start, int end){
	int min = 99999999;
	for(int i = end; i > start+1; i--){
		if(graph.adj.find(i) != graph.adj.end()){
			int aux = graph.adj.at(i).size();
			if(aux < min){
				min = i;
			}
		}
		
	}
	return min;
}

int getSuitableLowWeightRandomNode(int iterations, Graph graph, bool isSink){
	int min = 9999999;
	int aux = 0;
	srand (time(NULL));
	for(int i = 0; i < iterations; i++){
		int attemp =  0;
		do{
			attemp =  (int)rand() % graph.weightNode.size() + 1;
			
		}while(contains(graph.sinks, attemp) == isSink);

		if(graph.getWeightOUT(attemp) < min){
			aux = attemp;
			min = graph.getWeightOUT(attemp);
		}
	}
	
	return aux;
}

int getSuitableLowWeightRandomNodeB(int iterations, Graph graph, int start, int distance){
	int min = 9999999;
	int aux = 0;
	srand (time(NULL));
	for(int i = 0; i < iterations; i++){
		int attemp = 0;
		do{
			attemp =  (int)rand() % (distance) + start+1;
		}while(graph.existsEdge(start,attemp));
		if(graph.getWeightIN(attemp) < min){
			aux = attemp;
			min = graph.getWeightIN(attemp);
		}
	}
	return aux;
}

void addRandomEdges(Graph graph, int noEdges, int distance, bool random){
	srand (time(NULL));
	for(int i = 0; i < noEdges; i++){
		
		int nodeA = getSuitableLowWeightRandomNode(10, graph , true);
		
		int nodeB = 0;
		if(random){
			nodeB = getSuitableRandomNode(5, nodeA, graph);
		}else{
			nodeB = getSuitableLowWeightRandomNodeB(5,graph,nodeA,graph.weightNode.size()-nodeA);
		}
		graph.addEdge(nodeA,nodeB);
		cout << nodeA << " --> " << nodeB << endl;
	}
}


void generateNextGraph(Graph min, int noEdges, int distance, bool random){
	addRandomEdges(min, noEdges,distance, random);
}



int main(int argv, char* argc[]){
	string PATH("");
	unordered_map<int, list<int>> adj; 
	if(argv > 3){
		string directoryName = argc[1];
		int noGraphs = stoi(argc[2]);
		int noNodes = stoi(argc[3]);
		//cout << "directory name: " + directoryName  + " number of graphs: " + noGraphs + " number of nodes: " + noNodes << endl;
		//createFile(PATH.append(fileName));
		//cout << "looking good" << endl;
	}else {
		//list<list<int>> algo;
		list<int> sinks;
		sinks.push_back(4);
		sinks.push_back(10);
		Graph g = generateMinGraph(30,sinks);
		printGraph(g.adj);
		cout << "------------------------" << endl;
		generateNextGraph(g,5,6,true);
		printGraph(g.adj);
		//cout << "usage : generator <directory name> <number of graphs> <number of nodes>" << endl;
	}
}

