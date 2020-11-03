reset;
option solver "/home/elg/ampl/cplex";

set MONTH;
set OP; #Operation 

param demand {MONTH} >= 0;

param time {OP} >= 0;
param holding_cost {OP} >= 0; #per month

param cost {MONTH,OP} >= 0;
param capacity {MONTH,OP} >= 0;

var x {MONTH, OP} integer >= 0; #Production of op per month
var y {MONTH, OP} >= 0; #How much extra we have left over from last month

minimize costs:
    sum {i in MONTH, j in OP} x[i,j] * cost[i,j] + sum {i in MONTH, j in OP} y[i,j] * holding_cost[j]
;

#Make sure we can only create the amount we have time for
subject to Time_Capacity {i in MONTH, j in OP}:
    x[i,j] * time[j] <= capacity[i,j];

#Calculate how much we have extra from last month
# This is how much we created + leftover - the demand of the month
subject to Holding_finished {i in MONTH: i >= 2}:
    x[i-1,2] + y[i-1,2] - demand[i-1] = y[i,2];

# How much unfinished we are how much we created + leftover - How much of the finished we created
subject to Holding_unfinished {i in MONTH: i >= 2}:
    x[i-1,1] + y[i-1,1] - x[i-1,2] = y[i,1];

#Make sure we satisfy the demand this month
subject to Demand_Per_Month {i in MONTH}:
    x[i,2] + y[i,2] >= demand[i];

#Make sure we have enough of component I to create the finished product
subject to Stages {i in MONTH, j in OP}:
    x[i,2] <= x[i,1] + y[i,1];

#First month there are no already made components
subject to No_Extra_First {j in OP}:
    y[1,j] <= 0;

############
#   DATA   #
############
data;

param: MONTH:  demand :=
        1       500
        2       450
        3       600
        ;

param: OP:  time    holding_cost :=
        1    0.6    0.20
        2    0.8    0.40
        ;

param cost(tr): 
         1    2    3 :=
    1    10   12   11
    2    15   18   16
    ;

param capacity(tr): 
        1    2    3 :=
    1   800  700  550
    2  1000  850  700
    ;

solve;
display x;
display y;