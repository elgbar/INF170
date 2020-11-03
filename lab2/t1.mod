# Task 1 lab 2
#reset; model lab2/t1.mod; data lab2/t1.dat; solve; display produced;

set MONTH;

param storage_cost   >= 0;  # Cost of storing a window each month
param commit {MONTH} >= 0;  # How many to create in a month
param cost   {MONTH} >= 0;  # The cost of each window this month

var produced {m in MONTH} >= 0;

minimize total_cost:
    sum {m in MONTH} (produced[m] * cost[m] + (sum {n in 1..m} (produced[n] - commit[n]) * storage_cost));

subject to total_production: 
    (sum {m in MONTH} produced[m]) == (sum {m in MONTH} commit[m]);

subject to production {m in MONTH}:
    produced[m] + (sum {n in 1..(m-1)} (produced[n] - commit[n])) >= commit[m];

