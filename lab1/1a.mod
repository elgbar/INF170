reset;

set ADVER;

param budget >= 0;

param cost {ADVER} >= 0;
param reach {ADVER} >= 0;
param min_time {ADVER} >= 0;

var bought {i in ADVER} >= 0;

maximize Reach:
    sum{i in ADVER} bought[i]* reach[i];

subject to Time {i in ADVER}:
   min_time[i] <= bought[i];

subject to Budget:
    sum{i in ADVER} cost[i] * bought[i] <= budget;

data;

param budget := 1000000;

param: 
    ADVER: cost     reach min_time :=
    TV      20000   1.8     10
    MAG     10000   1.0     0
    ;

solve;
display bought;
