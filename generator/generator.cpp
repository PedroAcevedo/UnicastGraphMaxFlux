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
#include <math.h>
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
    
    float averageWeight(){
        float sum = 0;
        for(int i = 1; i <= weightNode.size(); i++){
            sum += (float)getWeightOUT(i);
        }
        return sum/((float)weightNode.size());
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
	//int weight = graph.getWeightOUT(nodeA);
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
		//cout << "removed " << node << " -> " << nodeB << endl;
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
		//cout <<  "added " << nodeA << " -> " << nodeB << endl;
	}
	//return graph;
}


void generateNextGraph(Graph& min, int noEdgesADD, int noEdgesRM, int distance, bool random){
	addRandomEdges(min, round((double)(noEdgesADD/2))-round(min.sinks.size()/2),distance, random);
	removeRandomEdges(noEdgesRM,(int)(rand()%(5)+1),(int)(rand()%(3) + min.weightNode.size()-5),min,(int)(rand()%(12-6)+6));
	addRandomEdges(min, round((double)(noEdgesADD/2))-round(min.sinks.size()/2),distance, random);
	list<int> :: iterator sink;
	//cout << "por aqui governador " << endl;
	for(sink = min.sinks.begin(); sink != min.sinks.end();++sink){
		int noExtras = min.getWeightIN(*sink);
		while(noExtras < 2){
			int nodeA = 0;
			int weightA = 99999;
			int aux = 0;
			for(int j = 0; j < 5; j++){
				do{
					nodeA = (int)(rand() % (std::min(*sink-1,distance)) + max(1,*sink-distance));
				}while(min.existsEdge(nodeA,*sink) && !contains(min.sinks, nodeA));
				if(min.getWeightOUT(nodeA) <= weightA){
					weightA = min.getWeightOUT(nodeA);
					aux = nodeA;
				}
			}
			min.addEdge(aux,*sink);
			noExtras++;
		}
            
	}
	//cout << "por aqui presidente " << endl;
	for(int i= 1; i < min.weightNode.size();i++){
		if(min.getWeightOUT(i) == 0 && !contains(min.sinks, i)){
			int nodeB = 0;
			do{
				//cout << "distance "  << distance << " i " << i << " rest " << std::min(distance, (int)(min.weightNode.size()-i))-1 << endl;
				nodeB = (int)(rand()%(max(std::min(distance, (int)(min.weightNode.size()-i))-1,1))) + i + 1;
			}while(min.existsEdge(i, nodeB) && !contains(min.sinks, nodeB));
			min.addEdge(i, nodeB);
		}else if(min.getWeightIN(i) == 0 && i != 1){
			int nodeA = 0;
			do{
				nodeA = (int)(rand() % (std::min(i-1,distance)) + max(1,i-distance));
			}while(!contains(min.sinks, nodeA));
			min.addEdge(nodeA,i);
		}
	}
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

Graph generateCompletelyRandomGraph(int noNodes, list<int> sinks, int distance){
	Graph randomGraph;
	randomGraph.sinks = sinks;
	randomGraph.sinks.push_back(noNodes);
	randomGraph.weightNode[1] = 0;
	for(int i = noNodes; i > 1; i--){
		int nodeA = 0;
		do{
			nodeA = (int)(rand() % (min(i-1,distance)) + max(1,i-distance));
		}while(randomGraph.existsEdge(nodeA,i));
		randomGraph.addEdge(nodeA,i);
	}
	return randomGraph;
}

void readConfigurationFile(conf& configuration){

	string line;
    ifstream myfile ("conf/generator.conf");
    if (myfile.is_open()){
    	cout << "generator configuration [conf/generator.conf]" << endl;
       	while ( getline (myfile,line) ){
       		string parameter = line.substr(0,line.find("="));
				
    		if(parameter == "n"){
    			configuration.n = stoi(line.substr(line.find("=")+1));
    			cout << "n = " << configuration.n << endl;
    		}else if(parameter == "noNodes"){
    			configuration.noNodes.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
    			configuration.noNodes.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
    			cout << "noNodes = {" << configuration.noNodes.first << ", " << configuration.noNodes.second << "}" << endl;
    		}else if(parameter == "sinks"){
    			configuration.sinks.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
    			configuration.sinks.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
    			cout << "sinks = {" << configuration.sinks.first << ", " << configuration.sinks.second << "}" << endl;
    		}else if(parameter == "noEdges"){
    			configuration.noEdges.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
    			configuration.noEdges.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
    			cout << "noEdges = {" << configuration.noEdges.first << ", " << configuration.noEdges.second << "}" << endl;
    		}else if(parameter == "distance"){
    			configuration.distance.first = stoi(line.substr(line.find("{")+1,line.find(",")-line.find("{")-1));
    			configuration.distance.second = stoi(line.substr(line.find(",")+1,line.find("}")-line.find(",")-1));
    			cout << "distance = {" << configuration.distance.first << ", " << configuration.distance.second << "}" << endl;
    		}else if(parameter == "nameFile"){
    			configuration.nameFile = line.substr(line.find("=")+1);
    			cout << "nameFile = " << configuration.nameFile << endl; 
    		}else if(parameter == "allDiferents"){
    			if(line.substr(line.find("=")+1) == "true"){
    				configuration.allDiferents = true;
    			}else if(line.substr(line.find("=")+1) == "false"){
    				configuration.allDiferents = false;
    			}
    			cout << "allDiferents = " << configuration.allDiferents << endl; 
    		}	
    	}
      	myfile.close();
    }
    else cout << "Unable to open file"; 
}


void graphsGenerator(conf configuration){
	srand (time(NULL));
	if(!configuration.allDiferents){
		//cout << "here my friend" << endl;
		int noSinks = (int)(rand() % (configuration.sinks.second - configuration.sinks.first)) + configuration.sinks.first;
		int noNodes = (int)(rand() % (configuration.noNodes.second - configuration.noNodes.first)) + configuration.noNodes.first;
		list<int> sinks = getRandomDifferentNumbers(noSinks,round((double)(noNodes/2)), noNodes-1);
		int distance = (int)(rand() % (configuration.distance.second - configuration.distance.first)) + configuration.distance.first;
		Graph g = generateCompletelyRandomGraph(noNodes,sinks,distance);
		int noEdges = (int)(rand() % (configuration.noEdges.second - configuration.noEdges.first)) + configuration.noEdges.first;
		int extraEdges = (int)(rand() % (20-10)) + 10;
		generateNextGraph(g, noEdges + extraEdges,extraEdges, distance,true);
        createFile(configuration.nameFile + to_string(1) + "_" + to_string(g.weightNode.size()) + "_" + to_string(g.sinks.size()) + "des.txt",g.adj, g.weightNode.size(), g.sinks);
		for(int i = 2; i <= configuration.n; i++){
			noEdges = (int)(rand() % (configuration.noEdges.second - configuration.noEdges.first)) + configuration.noEdges.first;
			distance = (int)(rand() % (configuration.distance.second - configuration.distance.first)) + configuration.distance.first;
			generateNextGraph(g,noEdges,noEdges,distance,true);
            createFile(configuration.nameFile + to_string(i) + "_" + to_string(g.weightNode.size()) + "_" + to_string(g.sinks.size()) + "des.txt",g.adj, g.weightNode.size(), g.sinks);
		}

	}else{
		for(int i = 1; i <= configuration.n; i++){
			int noSinks = (int)(rand() % (configuration.sinks.second - configuration.sinks.first)) + configuration.sinks.first;
			int noNodes = (int)(rand() % (configuration.noNodes.second - configuration.noNodes.first)) + configuration.noNodes.first;
			//cout << "noNodes " << noNodes << " noSinks " << noSinks << endl;
			list<int> sinks = getRandomDifferentNumbers(noSinks,round((double)(noNodes/2)), noNodes-1);
			int distance = (int)(rand() % (configuration.distance.second - configuration.distance.first)) + configuration.distance.first;
			Graph g = generateCompletelyRandomGraph(noNodes,sinks,distance);
			//printGraph(g.adj);
			int noEdges = (int)(rand() % (configuration.noEdges.second - configuration.noEdges.first)) + configuration.noEdges.first;
			int extraEdges = (int)(rand() % (20-10)) + 10;
			//cout << "noEdges " << noEdges << " distance " << distance << " extra "<< extraEdges << endl;
			generateNextGraph(g, noEdges + extraEdges,extraEdges, distance,true);
			createFile(configuration.nameFile + to_string(i) + "_" + to_string(g.weightNode.size()) + "_" + to_string(g.sinks.size()) + "des.txt",g.adj, g.weightNode.size(), g.sinks);
		}
	}
}


int main(int argv, char* argc[]){
	string PATH("");
	unordered_map<int, list<int>> adj; 
	if(argv > 1){
		cout << "no need arguments..." << endl;
	}else {
		struct conf configuration;
		readConfigurationFile(configuration);
		graphsGenerator(configuration);		
	}
}

