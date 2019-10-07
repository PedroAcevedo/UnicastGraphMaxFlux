#include<stdio.h>
#include<vector>
#include<queue>
#include<bitset>
#include<string.h>
#include<algorithm>
#include<ctime>
#include<stdlib.h>

using namespace std;


const int N_MAX = 100;
const int MAX_NAME = 100;
/* const int F_MAX = 10;*/
// f = valor flujo maximo
// n = cantidad de nodos
// e_i \in F_2^f representa paquete i

/*
class F2_f{ // elemento de F_2^f
    public:
    static int f;
    bitset<F_MAX> v;
    F2_f(bool zero){
        //v = new int [f];
        if(zero) v.reset();
            //memset(v,0,sizeof v);
    }
    F2_f(){
    }
    F2_f operator + (const F2_f w){
        F2_f ans = F2_f();
        ans.v = v^w.v;
        return ans;
    }
    void operator += (const F2_f w){
        (*this) = (*this) + w;
    }
    static F2_f get_e(int i){
        F2_f ans = F2_f(true);
        ans.v.set(i);
        return ans;
    }
    string to_string(){
        return v.to_string();
    }
};*/

class F2_f{ // elemento de F_2^f
    public:
    static int f;
    int v;
    F2_f(){
        v = 0;
    }

    F2_f(int num){
        v = num;
    }

    F2_f operator + (const F2_f w){
        F2_f ans = F2_f();
        ans.v = v^w.v;
        return ans;
    }
    void operator += (const F2_f w){
        (*this) = (*this) + w;
    }


    void operator = (const F2_f w){
        v = w.v;
    }

    void set(int i){
        v |= (1<<i);
    }

    bool get(int i){
        return (v&(1<<i))>0;
    }

    static F2_f get_e(int i){
        F2_f ans = F2_f();
        ans.set(i);
        return ans;
    }


    string to_string(bool let){

        if(!let){
            string str = "";
            for(int i=f-1; i>=0; i--){
                if(get(i))
                    str.push_back('1');
                else str.push_back('0');
            }
            return str;
        }else{
            string str = "0";
            bool emp = true;
            for(int i=f-1; i>=0; i--){
                if(get(i)){
                    if(emp){
                        str = "";
                        str.push_back(char(i+'A'));
                        emp = false;
                    }else{
                        str.push_back(char('+'));
                        str.push_back(char(i+'A'));
                    }
                }

            }
            return str;
        }

    }
};

class node{
    public:
    static const int SOURCE = 0, ENCODER = 1, INTERM = 2;
    bool target;
    int type, in_d, out_d;
    F2_f info;
    vector<F2_f> infos;

    node(){
        info = F2_f();
        in_d = 0;
        out_d = 0;
        target = false;
    }

    void receive(F2_f inf){
        if(target){
            infos.push_back(inf);
        }
        //printf("%s + %s = ", info.to_string().c_str(), inf.to_string().c_str());
        info += inf;
        //printf("%s\n", info.to_string().c_str());
    }

    void set_target(){
        target = true;
    }

    void clear(){
        info = F2_f();
        infos.clear();
    }
};

class sending{
    public:
    int out_d;
    F2_f * send;
    sending(int out_d):out_d(out_d){
        send = new F2_f[out_d];
    }
    sending(int out_d, int * config, bool simple):out_d(out_d){
        send = new F2_f[out_d];
        if(simple){
            for(int i=0; i<out_d; i++)
                send[i] = F2_f::get_e(config[i]);
        }else{
            for(int i=0; i<out_d; i++)
                send[i].v = config[i];
        }
    }

    sending(int out_d, bool equ):out_d(out_d){
        send = new F2_f[out_d];
        for(int i=0; i<out_d; i++)
            send[i] = F2_f::get_e(i);
    }

    void print(bool let){
        for(int i=0; i<out_d; i++){
            printf("%s\t",send[i].to_string(let).c_str());
        }
    }

    void operator = (const sending s){
        out_d = s.out_d;
        send = new F2_f[out_d];
        for(int i=0; i<out_d; i++){
            send[i] = s.send[i];
        }
    }

    void println(bool let){
        print(let);
        printf("\n");
    }
};

bool li(vector<F2_f> infos, int f){
    //printf("\n");
    for(int i=0; i<f; i++){
        printf("%s\n",infos[i].to_string(false).c_str());
        if(!infos[i].get(i)){
            //printf("Dijo que era cero\n");
            bool ok = false;
            for(int j=i+1; j<f; j++){
                if(infos[j].get(i)){
                    ok = true;
                    swap(infos[i],infos[j]);
                }
            }
            if(!ok) return false;
        }
        for(int j=i+1; j<f; j++){
            if(infos[j].get(i)){
                infos[j] += infos[i];
            }
        }
    }
    //printf("Finalmente fue li\n");
    return true;
}

class network{
    public:
    int n;
    bool adj_mat[N_MAX][N_MAX];
    vector<int> adj_list[N_MAX];
    vector<int> top;
    vector<int> targs;
    vector<vector<F2_f> > equations;
    node nodes[N_MAX];
    int source;

    network(int n, bool mat[N_MAX][N_MAX], vector<int> targets):n(n){
        for(int i=0; i<n; i++)
            nodes[i] = node();
        for(int i=0; i<n; i++){
            for(int j=0; j<n; j++){
                adj_mat[i][j] = mat[i][j];
                if(mat[i][j]){
                    nodes[i].out_d++;
                    nodes[j].in_d++;
                    adj_list[i].push_back(j);
                }
            }
        }

        int sz = targets.size();
        for(int i=0; i<sz; i++){
            nodes[targets[i]].set_target();
            targs.push_back(targets[i]);
        }

        for(int i=0; i<n; i++){
            if(nodes[i].in_d == 0 && nodes[i].out_d !=0){
                nodes[i].type = node::SOURCE;
                source = i;
            }else if(nodes[i].in_d == 1){
                nodes[i].type = node::INTERM;
            }else{
                nodes[i].type = node::ENCODER;
            }
        }
        top = topological_sort();
        get_equations();

    }

    void get_equations(){
        sending equ = sending(nodes[source].out_d, true);
        send(equ);
        equations.clear();
        for(int i=0; i<n; i++){
            if(nodes[i].target){
                equations.push_back(nodes[i].infos);
                /*int sz = nodes[i].infos.size();
                for(int j=0; j<sz; j++){
                    printf("%s\n",nodes[i].infos[j].to_string().c_str());
                }
                printf("\n");*/
            }
        }
    }

    vector<int> verify_sending(sending s){
        int sz = equations.size();
        int out_d = nodes[source].out_d;
        vector<F2_f> infos;
        bool ok = true;
        int first_ok = false;
        vector<int> ok_nodes;
        for(int i=0; i<sz; i++){
            infos.clear();
            int f = equations[i].size();
            //printf("Lo que llego fue %d\n",f);
            for(int j=0; j<f; j++){
                F2_f sum = F2_f();
                for(int k=0; k<out_d; k++){
                    if(equations[i][j].get(k)){
                        sum += s.send[k];
                    }
                }
                //printf("%s\n",sum.to_string(true).c_str());
                infos.push_back(sum);
            }
            /*for(int k=0; k<f; k++){
                printf("%s\n",infos[k].to_string(true).c_str());
            }*/
            if(!li(infos,F2_f::f)) ok = false;
            else{
                ok_nodes.push_back(targs[i]);
                /*if(first_ok) printf(",%d",targs[i]);
                else{
                    first_ok = true;
                    printf("%d",targs[i]);
                }*/
            }
        }
        /*if(first_ok) printf(" -> ");
        else printf("Ninguno -> ");*/
        return ok_nodes;
    }

    int get_sending_size(){
        return nodes[source].out_d;
    }

    /*void bfs_adj_list(queue<int> q){
        while(!q.empty()){
            int u = q.front();
            q.pop();
            F2_f sent_info = nodes[u].info;
            printf("Nodo %d : tiene %s\n", u,sent_info.to_string().c_str() );
            int sz = adj_list[u].size();
            for(int i=0; i<sz; i++){
                int w = adj_list[u][i];
                q.push(w);
                nodes[w].receive(sent_info);
            }
        }
    }*/
    vector<int> topological_sort(){
        vector<int> top;
        bool * check = new bool [n];
        memset(check, false, sizeof check);
        dfs(0,top, check);
        reverse(top.begin(),top.end());
        return top;
    }

    void dfs(int u, vector<int> &top, bool * &check){
        check[u] = true;
        int sz = adj_list[u].size();
        for(int i=0; i<sz; i++){
            if(!check[adj_list[u][i]])
                dfs(adj_list[u][i], top, check);
        }
        top.push_back(u);
    }

    void clear(){
        for(int i=0; i<n; i++){
            nodes[i].clear();
        }
    }

    void send(sending s){

        clear();

        int sz = adj_list[source].size();
        //queue<int> q;
        //printf("source = %d\n",source);
        for(int i=0; i<sz; i++){
            int w = adj_list[source][i];
            //q.push(w);
            nodes[w].receive(s.send[i]);
        }
        //bfs_adj_list(q);
        //aqu\ED hac\EDa el ordenamiento topologico
        int tsz = top.size();
        for(int u=0; u<tsz; u++){
            int act = top[u];
            if(act!=source){
                F2_f sent_info = nodes[act].info;
                //printf("Nodo %d : tiene %s\n", act,sent_info.to_string(false).c_str() );
                sz = adj_list[act].size();
                for(int i=0; i<sz; i++){
                    int w = adj_list[act][i];
                    nodes[w].receive(sent_info);
                }
            }
        }
        //return show_results();
    }

    /*bool show_results(){
        bool ok = true;
        for(int i=0; i<n; i++){
            if(nodes[i].target){
                //printf("Nodo %d:\n",i);
                int sz = nodes[i].infos.size();
                for(int j=0; j<sz; j++){
                    //printf("%s ",nodes[i].infos[j].to_string().c_str());
                }
                //printf("\n");
                if(!li(nodes[i].infos,F2_f::f)) return false;
            }
        }
        return true;
    }*/

    void print(){
        printf("%d\n",n);
        for(int i=0; i<n; i++, printf("\n"))
            for(int j=0; j<n; j++)
                printf("%d ", adj_mat[i][j]? 1 : 0);
    }

};

bool next_config_simple(vector<int> &v, int f){
    int sz = v.size();
    int i = 0;
    while(v[i]+1>=f){
        v[i] = 0;
        i++;
        if(i>=sz){
            return false;
        }
    }
    v[i]+=1;
    return true;
}

bool next_config(vector<int> &v, int f, bool simple){
    if(simple) return next_config_simple(v,f);
    int lc = (1<<f);
    return next_config_simple(v,lc);
}

string int_to_string(int a){
    if(a == 0) return "0";
    string s="";44
    while(a>0){
        s.push_back((a%10)+'0');
        a/=10;
    }
    string rs;
    rs.assign(s.rbegin(), s.rend());
    return rs;
}

string vector_to_string(vector<int> v){
    if(v.empty()) return "-";
    string s=int_to_string(v[0]);
    int sz = v.size();
    for(int i=1; i<sz; i++){
        s+=",";
        //printf("%d ",v[i]);
        s+=int_to_string(v[i]);
    }
    return s;
}


int F2_f::f = 0;

int main(){
    /*F2_f::f = 2;
    vector<F2_f> prueba;
    prueba.push_back(F2_f(2));
    prueba.push_back(F2_f(2));
    printf("%s\n", li(prueba,2)? "es li" : "nah, no es li");*/

    bool let;
    int rep, sim;
    char cad[MAX_NAME];
    printf("Digite el nombre del archivo: ");
    scanf("%s",cad);
    printf("Digite la representaci\F3n deseada 1-letras   0-vectores binarios : ");
    scanf("%d",&rep);
    let = rep == 1;
    printf("Digite 1-simples   0-combinados: ");
    scanf("%d",&sim);
    freopen(cad,"r",stdin);
    string str(cad);
    str+= sim? "-sim": "-comb";
    str+= let? "-let.out" : "-vec.out";
    freopen(str.c_str(),"w",stdout);

    // comienzo a medir tiempo
    unsigned t0, t1;

    t0=clock();


    // comienzo de lectura del grafo
    int n,f,aux, number_targets;
    scanf("%d %d %d",&n,&f,&number_targets);
    bool mat[N_MAX][N_MAX];

    vector<int> targets;

    for(int i=0; i<number_targets; i++){
        scanf("%d",&aux);
        targets.push_back(aux);
    }
    int con_arist = 0;
    for(int i=0; i<n; i++){
        for(int j=0; j<n; j++){
            scanf("%d",&aux);
            con_arist += (aux==1)? 1:0;
            mat[i][j] = (aux == 1);
        }
    }
    //printf("Aristas = %d\n",con_arist);
    F2_f::f = f;
    // fin de lectura del grafo
    network g = network(n,mat,targets);
    /*g.print();
    for(int i=0; i<g.n; i++){
        printf("node %d  es de tipo %d\n", i,g.nodes[i].type);
    }*/

    /*int config [] = {0,0,1,0,1};

    g.send(s);*/

    int ssz = g.get_sending_size();
    vector<int> perm(ssz,0);
    for(int i=0; i<ssz; i++){
        printf("%d-%d\t",g.source,g.adj_list[g.source][i]);
    }
    printf("  V\E1lidos\n");
    for(int i=0; i<ssz; i++){
        printf(" \t");
    }
    printf(" \n");

    bool simple = sim==1;
    int val = 0, can = 0;
    int max_found = -1;
    sending copy_max_found = sending(g.nodes[g.source].out_d);
    do{
        sending s = sending(ssz, &perm[0],simple);
        s.print(let);
        vector<int> ok_nodes = g.verify_sending(s);
        int ok_amount = ok_nodes.size();
        if(ok_amount > max_found){
            max_found = ok_amount;
            copy_max_found = s;
        }
        if(ok_amount == number_targets){
            printf("\tok\t%s\n",vector_to_string(ok_nodes).c_str());
            val++;
        }else{
             printf("\tno\t%s\n",vector_to_string(ok_nodes).c_str());
        }
        can++;
    }while(next_config(perm,f,simple));
    aux = g.top.size();
    printf("\n");
    printf("Ordenamiento topol\F3gico usado: \n");
    for(int i=0; i<aux; i++)
        printf("%d ",g.top[i]);
    printf("\n\n");
    printf("Proporci\F3n v\E1lidas: %d/%d = %.3f\n\n",val,can,((double)val)/can);
    printf("Mejor soluci\F3n encontrada :\n");
    copy_max_found.print(let);
    printf(", y %ses \F3ptima\n\n",(max_found==number_targets)? "":"no ");
    //for(int i=1; i<256;i++) printf("%c",char(i));

    t1 = clock();
    double time = (double(t1-t0)/CLOCKS_PER_SEC);
    printf("Tiempo de ejecuci\F3n total : %.15f\n", time);

    return 0;
}
