reset;
#option solver "/home/elg/ampl/cplex";

set YEAR;
set PROJECT;

param Flow {YEAR, PROJECT};
param Bank_rate;
param Max_value;

var x {}

############
#   DATA   #
############
data;

set YEAR := 1 2 3 4 5;
set PROJECT := 1 2 3 4;

param Bank_rate := 0.65;
param Max_value := 10000;
param Flow: 
         1   2        3        4        5 :=
    1   -1  0.50     0.30     1.80     1.20
    2   -1  0.60     0.20     1.50     1.30
    3    0 -1.00     0.80     1.90     0.80
    4   -1  0.40     0.60     1.80     0.95
    ;

solve;
display x;