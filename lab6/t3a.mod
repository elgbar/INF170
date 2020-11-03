reset;
option solver "/home/elg/ampl/cplex";

set CODE;

param cost {CODE} >= 0;

var X {CODE} binary; # 1 if X is chosen as the software, 0 otherwise

minimize Cost:
    sum {i in CODE} X[i]*cost[i];

subject to CoverLP:
    X[1] + X[2] + X[3] + X[4] >= 1;

subject to CoverIP:
    X[2] + X[4] >= 1;

subject to CoverNLP:
    X[3] + X[4] >= 1;

############
#   DATA   #
############
data;

param: CODE:    cost :=
        1       3
        2       4
        3       61
        4       4
;

solve;
display X;