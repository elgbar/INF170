# Task 2 lab 2
# reset; model lab2/t2.mod; data lab2/t2.dat; solve; display produced;
set PRODS;

param max_raw >= 0;             #Max raw material per day

param max_sold    {PRODS} >= 0;   #Upper limit on how many to sell
param min_percent {PRODS} >= 0;   #Min percent of this product to produce
param usage_rate  {PRODS} >= 0;   #lb per product made
param profit      {PRODS} >= 0;   #How much we make on each product

var produced {p in PRODS} >= 0; # How many unit produced

maximize income:
    sum {p in PRODS} produced[p] * profit[p];

#Cannot sell more than the given num
subject to max_sold_per_day {p in PRODS}:
    1 <= produced[p] <= max_sold[p];

#Percent made must be satisfied
subject to percentage {p in PRODS}:
    min_percent[p] <= produced[p] / (sum {r in PRODS} produced[r]);

#Must be a valid percent
subject to total_percent:
    0 <= (sum {p in PRODS} (produced[p] / (sum {r in PRODS} produced[r]))) <= 1;

#How much raw material that can be used
subject to raw_material_avaliable:
    (sum {p in PRODS} produced[p] * usage_rate[p]) <= max_raw;
