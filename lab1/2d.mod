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
param min_share {PROD} >= 0, <= 1;
param market {PROD} >= 0; # upper limit on tons sold in week

var Make {p in PROD} <= market[p]; # tons produced

maximize Total_Profit: 
    sum {p in PROD} profit[p] * Make[p];

# Objective: total profits from all products
subject to Time {s in STAGE}:
    sum {p in PROD} (1/rate[p,s]) * Make[p] <= avail[s];

subject to Share {p in PROD}:
     Make[p] >= min_share[p] * sum {k in PROD} Make[k];

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


param:     profit  min_share  market :=
    bands   25      0.5        6000
    coils   30      0.5        4000
    plate   29      0.1        3500
    ;

solve;

display Make;