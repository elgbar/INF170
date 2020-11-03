reset;
option solver "/home/elg/ampl/cplex";

set C;

param time{C, C};
param maxTime >= 0;
param withinRange {i in C, j in C} = 
    if (time[i,j] <= maxTime) then 1 else 0;

var X {C} binary;    #If there is a firestation in city i

minimize firestations:
    sum {i in C} X[i];

subject to Closeness {i in C}:
    sum{j in C} (withinRange[i,j] * X[j]) >= 1;

############
#   DATA   #
############
data;

set C := 1 2 3 4 5 6;

param maxTime := 15;

param time:
      1  2  3  4  5  6 :=
    1 0  10 20 30 30 20
    2 10 0  25 35 20 10
    3 20 25 0  15 30 20
    4 30 35 15 0  15 25
    5 30 20 30 15 0  14
    6 20 10 20 25 14 0
;

solve;
display X;