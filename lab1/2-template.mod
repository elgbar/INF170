reset;

set PROD;
set STAGE;
# products
# stages
param rate {PROD,STAGE} > 0; # tons per hour in each stage
param avail {STAGE} >= 0;
# hours available/week in each stage
param profit {PROD};
# profit per ton
param commit {PROD} >= 0;
param market {PROD} >= 0;
# lower limit on tons sold in week
# upper limit on tons sold in week

var Make {p in PROD} >= commit[p], <= market[p]; # tons produced

maximize Total_Profit: 
    sum {p in PROD} profit[p] * Make[p];

# Objective: total profits from all products
subject to Time {s in STAGE}:
    sum {p in PROD} (1/rate[p,s]) * Make[p] <= avail[s];
    # In each stage: total of hours used by all
    # products may not exceed hours available

data;

set PROD := bands coils plate;

param: STAGE: avail := 
        reheat  35   
        roll    40
        ;

param rate: reheat roll :=
    bands   200     200
    coils   200     140
    plate   200     160
    ;


param:     profit  commit  market :=
    bands   25      1000    6000
    coils   30      500     4000
    plate   29      750     3500
    ;

solve;

display Make;