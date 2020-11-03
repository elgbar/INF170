reset;
#option solver "/home/elg/ampl/cplex";

set P; #Workpiece
set M; #Machine
param Ben {P} >= 0;
param Sol {P} >= 0;
param Ass {P} >= 0;



############
#   DATA   #
############
data;

set M := B S A;

param: P: Ben Sol Ass :=
    1   3   5   5
    2   6   4   2
    3   3   2   4
    4   5   4   6
    5   5   4   3
    6   7   5   6
;

solve;
display x;