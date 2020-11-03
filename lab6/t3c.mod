reset;
option solver "/home/elg/ampl/cplex";

set ALG;
set CODE;

param quality {CODE} >= 0;
param ability {ALG, CODE} binary; #If a code can solve an algorithm

var x {ALG, CODE} binary;  # 1 if the given code is selected for an algorithm, 0 otherwise

maximize CodeQuality:
    sum {i in ALG, j in CODE} x[i,j] * quality[j];

subject to Chosen {i in ALG}:
    sum {j in CODE} ability[i,j] * x[i,j] <= 1;

#Each code is only chosen once
subject to OneEach {j in CODE}:
    sum {i in ALG} x[i,j] <= 1;

############
#   DATA   #
############
data;

set ALG := LP IP NLP;

param: CODE: quality :=
        1     3
        2     4
        3     61
        4     4
;

param ability: 
        1 2 3 4 :=
    LP  1 1 1 1
    IP  0 1 0 1
    NLP 0 0 1 1
;

solve;
display x;