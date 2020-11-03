# Task 3 lab 2
#reset; model lab2/t3.mod; data lab2/t3.dat; solve; display produced;

set DEPS;    #Departments
set CLOTHES; #Differernt types of clothes

param capasity {DEPS} >= 0; # How many hours a deparment has

param demand  {CLOTHES} >= 0; #Max to sell
param profit  {CLOTHES} >= 0; #$ pr sold
param penalty {CLOTHES} >= 0; #Penality pr not delivered

param dep_time {DEPS, CLOTHES} >= 0; #How long each cloth needs in each department

var produced {c in CLOTHES} >= 0;

maximize income:
    sum {c in CLOTHES} ((produced[c] * profit[c]) - ((demand[c] - produced[c]) * penalty[c]));

subject to time {d in DEPS}:
    (sum {c in CLOTHES} (dep_time[d, c] * produced[c])) <= capasity[d];
    
subject to max_sold {c in CLOTHES}:
    produced[c] <= demand[c]