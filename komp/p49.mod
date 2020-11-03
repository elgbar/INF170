#Maximum flow problem

reset;

set NODES;
param start symbolic in NODES;
param stop  symbolic in NODES;

set EDGES within (NODES diff {stop}) cross (NODES diff {start}); #Connections
param cap {EDGES} >= 0;

var flow {(i,j) in EDGES} >= 0, <= cap[i,j];

maximize Flow:
    sum {(i,stop) in EDGES} flow[i,stop];

subject to Balance {n in NODES diff {start, stop}}:
    sum {(i,n) in EDGES} flow[i,n] == sum {(n, o) in EDGES} flow[n,o];

data;

set NODES := A B C D E F G;
param start := A;
param stop := G;

param: 
   EDGES: cap :=
    A C 100
    A B 50
    B D 40
    B E 20
    C D 60
    C F 20
    D E 50
    D F 60
    E G 70
    F G 70
    G 1
    ;
    

solve;
display flow;