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
    	return contains(adj.at(a),b);
    }

    int getWeight(int n){
    	return adj.at(n).size();
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

/*list<int> getRandomElements(list<int> L, int noElements){
	list<int> randomElements;
	if(L.size() > noElements){
		srand (time(NULL));
		while(noElements > 0){
			int element = rand() % L.size() + 1;
			list<int> :: iterator it = next(L.begin(), element);
			randomElements.push_back(*it);
			noElements--;
		}
	}else{
		return NULL;
	}
	return randomElements;
}

pair<unordered_map<int, list<int>>,list<int>> generateNexGraph(pair<unordered_map<int, list<int>>, list<int>> graph, double entropy){
	srand (time(NULL));
	
}

int getRandomViableNode(pair<unordered_map<int, list<int>>, list<int>> graph, bool criteria){
	srand (time(NULL));
	unordered_map<int, list<int> nodes = graph->first;
	list<int> sinks = graph->second;
	int attempts = 3;
	int attempA = 0;
	int sizeAttemp;
	if(criteria){
		sizeAttemp = 9999999;
	}else{
		sizeAttemp = -99999;
	}
	while(attempts > 0){
		int attemp =  rand() % (sinks.size()-1) + 1;
		if(!contains(sinks,attemp) && nodes.at(attemp).size() < (nodes.size() - attemp - 1)){
			if(criteria){
				if(nodes.at(attemp).size() < sizeAttemp){
					attempA = attemp;
					sizeAttemp = nodes.at(attemp).size();
				}
			}else{
				if(nodes.at(attemp).size() > sizeAttemp){
					attempA = attemp;
					sizeAttemp = nodes.at(attemp).size();
				}
			}
			attempts--;
		}
		
	}
	return attempA;
}

int getRandomViableNodeB(pair<unordered_map<int, list<int>>, list<int>> graph){

}

pair<unordered_map<int, list<int>>, list<int>> addRandomEdges(pair<unordered_map<int, list<int>>, list<int>> graph, int noEdges){
	srand (time(NULL));
	while(noEdges > 0){
		int nodeA  = getRandomViableNode(graph,true);
		bool sw = true;
		while(sw){
			int nodeB = rand() % (nodeA) + (graph.size()-nodeA);
		}
	}

	
}*/

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
		sinks.push_back(6);
		printGraph(generateMinGraph(1000,sinks).adj);
		//cout << "usage : generator <directory name> <number of graphs> <number of nodes>" << endl;
	}
}

