reset;
option solver "/home/elg/ampl/cplex";

set C;

param inTime{C,C} binary;

var X {C} binary;    #If there is a firestation in city i

minimize firestations:
    sum {i in C} X[i];

subject to Closeness {i in C}:
    sum {j in C} inTime[i,j]*X[j] >= 1;

############
#   DATA   #
############
data;

set C := 1 2 3 4 5 6;

param inTime:
    1 2 3 4 5 6 :=
  1 1 1 0 0 0 0
  2 1 1 0 0 0 1
  3 0 0 1 1 0 0
  4 0 0 1 1 1 0
  5 0 0 0 1 1 1
  6 0 1 0 0 1 1
;

solve;
display X;