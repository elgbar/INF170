reset;
option solver "/home/elg/ampl/cplex";

set STATE;

param votes {STATE} >= 0;
param cost {STATE} >= 0;

param budget >= 0;

var x {STATE} binary; # 1 if the state is selected as advertising, 0 otherwise

maximize Votes:
    sum{i in STATE} x[i] * votes[i];

subject to Budget:
    sum {i in STATE} x[i] * cost[i] <= budget;

############
#   DATA   #
############
data;

param budget := 10;

param: STATE: votes cost :=
        1       9   2
        2       29  5
        3       6   1
        4       10  2
        5       4   1
        6       18  4
        7       13  3
;

solve;
display x;