reset;
option solver "/home/elg/ampl/cplex";

set C;
set S;

param P {S,C} >= 0, <= 100;
param cap {C} >= 0;

var X {S,C} binary;

maximize Preferance:
    sum {i in S, j in C} X[i,j] * P[i, j];

subject to CoursePerStudent {i in S}:
    sum {j in C} X[i,j] = 2;

subject to CourseCapasity {j in C}:
    sum {i in S} X[i,j] <= cap[j];

############
#   DATA   #
############
data;

set S := 1 2 3 4 5 6 7 8 9 10;

param:
    C: cap :=
    1   6
    2   8
    3   5
    4   5
    5   6
    6   5
;

param P:   1  2   3   4   5  6 :=
        1  20 40  50  30  90 100
        2  90 100 80  70  10 40
        3  25 40  30  80  95 90
        4  80 50  60  80  30 40
        5  75 60  90  100 50 40
        6  60 40  90  10  80 80
        7  45 40  70  60  55 60
        8  30 100 40  70  90 55
        9  80 60  100 70  65 80
        10 40 60  80  100 90 10
;


solve;
display X;