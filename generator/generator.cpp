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

struct conf {
	int n;
	pair <int, int> noNodes;
	pair <int, int> sinks;
	pair <int, int> noEdges;
	pair <int, int> distance;
	bool allDiferents;
	string nameFile;
};


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


void replaceElement(string& original, int pos, string newVal){
	original = original.substr(0,pos) + newVal + original.substr(pos+1);
}

string getZerosRow(int noNodes){
	
	string line("");
	for (int i = 0; i < noNodes; i++){
		if(i == noNodes-1){
			//cout << "si llego" << endl;
			line.append("0");
		}else{
			line.append("0 ");
		}
	}
	return line;
}

void formatFile(unordered_map<int, list<int>> graph, int noNodes, list<int> sinks, ofstream& out){
	
	//cout << line << endl;
	//cout << replaceElement(line,(-1)*2,"1") << endl;

	out << "Nodos: " << noNodes << endl; 
	list<int> :: iterator sink;
	for (sink = sinks.begin(); sink != sinks.end(); ++sink){
		if(*sink != noNodes){
			out << *sink << " ";
		}else{
			out << *sink;
		}
		
	}
	out << endl;
	for (int i = 1; i <= noNodes; i++){
		string line = getZerosRow(noNodes);
		if(graph.find(i) !=  graph.end()){
			list<int> :: iterator nodesIt;
			for (nodesIt = graph.at(i).begin(); nodesIt !=  graph.at(i).end(); ++nodesIt)
			{
				replaceElement(line, (*nodesIt-1)*2,"1");
			}
		} 
		out <<line << endl;
	}
}

void createFile(string name, unordered_map<int, list<int>> graph, int noNodes, list<int> sinks){
	ofstream outfile ("../graphs/"+name);
	formatFile(graph,noNodes,sinks,outfile);
	outfile.close();
	cout << "file succesfully written file : " << name << endl;
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
	graph.weightNode[1] = 0;
	for (int i = 1; i < noNodes; i++){
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
	//srand (time(NULL));
	int noNodes = graph.weightNode.size();
	int weight = graph.getWeightOUT(nodeA);
	int attemp = 0;
	do{
		attemp =  (int)rand() % (distance) + nodeA+1;
	}while(graph.existsEdge(nodeA,attemp) || attemp >= noNodes);
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

int getSuitableLowWeightRandomNode(int iterations, Graph graph, bool isSink, int distance){
	int min = 9999999;
	int aux = 0;
	//srand (time(NULL));
	for(int i = 0; i < iterations; i++){
		int attemp =  0;
		do{
			attemp =  (int)rand() % (graph.weightNode.size()-distance) + 1;
			
		}while(contains(graph.sinks, attemp) == isSink || graph.getWeightOUT(attemp) == graph.weightNode.size() - attemp);

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
	//srand (time(NULL));
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

void removeRandomEdges(int n, int a, int b, Graph& graph,int iterations){
	while(n>0){
		int node = 0;
		int nodeWeight = -999999;
		for(int i = 0; i < iterations; i++){
			int new_node = (int)(rand() % (b + 1 - a)) + a;
			if(graph.getWeightOUT(new_node) > nodeWeight && !contains(graph.sinks,new_node)){
				node = new_node;
				nodeWeight = graph.getWeightOUT(new_node);
			}
		}
		list<int> :: iterator adj_node;
		int nodeB = 0;
		int nodeBWeight = -99999;
		for(adj_node = graph.adj.at(node).begin(); adj_node != graph.adj.at(node).end(); ++adj_node){
			if(graph.getWeightIN(*adj_node) > nodeBWeight){
				nodeB = *adj_node;
				nodeBWeight = graph.getWeightIN(*adj_node);
			}
		}
		graph.removeEdge(node, nodeB);
		cout << "removed " << node << " -> " << nodeB << endl;
		n--;
	}
}

void addRandomEdges(Graph& graph, int noEdges, int distance, bool random){
	//srand (time(NULL));
	for(int i = 0; i < noEdges; i++){
		
		int nodeA = getSuitableLowWeightRandomNode(10, graph , true, distance);
		
		int nodeB = 0;
		if(random){
			nodeB = getSuitableRandomNode(distance, nodeA, graph);
		}else{
			nodeB = getSuitableLowWeightRandomNodeB(5,graph,nodeA,graph.weightNode.size()-nodeA);
		}
		graph.addEdge(nodeA,nodeB);
		cout <<  "added " << nodeA << " -> " << nodeB << endl;
	}
	//return graph;
}


void generateNextGraph(Graph& min, int noEdges, int distance, bool random){
	addRandomEdges(min, noEdges,distance, random);
	removeRandomEdges(5, 1,noEdges-2,min,7);
	cout << "helolo" << endl;
}

list<int> getRandomDifferentNumbers(int n, int a, int b){
	list<int> numbers;
	while(n > 0){
		int new_number = (int)(rand() % (b + 1 - a)) + a;
		if(!contains(numbers,new_number)){
			numbers.push_back(new_number);
			n--;
		}
	}
	return numbers;
}

void readConfigurationFile(struct conf){

	string line;
    ifstream myfile ("conf/generator.conf");
    if (myfile.is_open()){
       	while ( getline (myfile,line) ){
       		string parameter = line.substr(0,line.find("="));
			switch (parameter) {
        		case "n": 
        			conf.n = stoi(line.substr(line.find("=")+1));
        			cout << "n " << conf.n << endl;
        			break;
        		case "noNodes":
        			conf.noNodes.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
        			conf.noNodes.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
        			cout << "noNodes {" << conf.noNodes.first << ", " << conf.noNodes.second << "}" << endl;
        			break;
        		case "sinks";
        			conf.sinks.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
        			conf.sinks.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
        			cout << "sinks {" << conf.noNodes.first << ", " << conf.noNodes.second << "}" << endl;
        			break;
        		case "noEdges":
        			conf.noEdges.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
        			conf.noEdges.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
        			cout << "noEdges {" << conf.noNodes.first << ", " << conf.noNodes.second << "}" << endl;
        			break;
        		case "distance";
        			conf.distance.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
        			conf.distance.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
        			cout << "distnace {" << conf.noNodes.first << ", " << conf.noNodes.second << "}" << endl;
        			break;
        		case "nameFile":
        			conf.nameFile = line.substr(line.find("=")+1);
        			cout << "nameFile " << conf.nameFile << endl; 
        			break;
        		case "allDiferents";
        			if(line.substr(line.find("=")+1) == "true"){
        				conf.allDiferents = true;
        			}else if(line.substr(line.find("=")+1) == "false"){
        				conf.allDiferents = false;
        			}
        			cout << "allDiferents " << conf.allDiferents << endl; 
        			break;
        	}
    	}
      	myfile.close();
    }
    else cout << "Unable to open file"; 
}


void graphsGenerator(int n, int noNodes ){

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
		/*srand (time(NULL));
		list<int> sinks = getRandomDifferentNumbers(3,25,49);
		Graph g = generateMinGraph(50,sinks);
		//printGraph(g.adj);
		//cout << "------------------------" << endl;
		generateNextGraph(g,80,8,true);
		//cout << "------------------------" << endl;
		printGraph(g.adj);
		cout << "--------------------------" << endl;
		createFile("prueba1" + to_string(g.sinks.size()) + "des.txt",g.adj, g.weightNode.size(), g.sinks);*/

		readConfigurationFile(conf);

		//cout << "usage : generator <directory name> <number of graphs> <number of nodes>" << endl;
	}
}

