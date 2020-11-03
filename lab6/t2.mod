reset;
option solver "/home/elg/ampl/cplex";

set FSF;
set Flight;

param cost {FSF} >= 0;
param fly {FSF,Flight} binary;

var X {FSF} binary;

minimize Cost:
    sum {i in FSF} X[i] * cost[i];

subject to Crews:
    sum {i in FSF} X[i] = 3;

subject to FlightCover {j in Flight}:
    sum {i in FSF} X[i] * fly[i,j] >= 1;

############
#   DATA   #
############
data;

set Flight := 1 2 3 4 5 6 7 9 10 11;

param: 
    FSF:   cost :=
    1       2
    2       3
    3       4
    4       6
    5       7
    6       5
    7       6
    8       8
    9       9
    10      9
    11      8
    12      9
;

param fly(tr):
        1  2  3  4  5  6  7  8  9  10 11 12  :=
    1   1  0  0  1  0  0  1  0  0  1  0  0
    2   0  1  0  0  1  0  0  1  0  0  1  0
    3   0  0  1  0  0  1  0  0  1  0  0  1
    4   0  0  0  1  0  0  1  0  1  1  0  1
    5   1  0  0  0  0  1  0  0  0  1  1  0
    6   0  0  0  1  1  0  0  0  1  0  0  0
    7   0  0  0  0  0  0  1  1  0  1  1  1
    8   0  1  0  1  1  0  0  0  1  0  0  0
    9   0  0  0  0  1  0  0  1  0  0  1  0
    10  0  0  1  0  0  0  1  1  0  0  0  1
    11  0  0  0  0  0  1  0  0  1  1  1  1
;

solve;
display X;