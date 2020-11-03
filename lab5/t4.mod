reset;
option solver "/home/elg/ampl/cplex";

set M;

param setup {M} >= 0;
param unit {M} >= 0;
param cap {M} >= 0;

param amount >= 0;

var X {M} binary;
var Prod {M} integer;

minimize Cost:
    sum {i in M} (X[i] * setup[i] + Prod[i]*unit[i]);

subject to machineCap {i in M}:
    Prod[i] <= cap[i];

subject to setupCost {i in M}:
    Prod[i] <= X[i] * amount;

subject to totalProduced:
    sum {i in M} Prod[i] == amount;

############
#   DATA   #
############
data;

param amount := 2000;

param:  M: setup unit cap :=
        1   300   2   650
        2   100   10  850
        3   200   5   1250
;

solve;
display X;
display Prod;