reset;
# option solver "/home/elg/ampl/cplex";

set RP;  #Refined products
set COP; #Crude oil COP

param min_demand {RP} >= 0; #bbl/day

param min_percent {COP} >= 0, <= 1;
    check sum {p in COP} min_percent[p] = 1;

param yield {COP, RP} >= 0; #in bbl

var caps {COP} >= 0;

minimize Objective:
    sum{r in RP, c in COP} yield[c,r] * caps[c];

subject to demand {r in RP}:
    sum {c in COP} caps[c] * yield[c,r] >= min_demand[r];

subject to percent {c in COP}:
    caps[c] >= min_percent[c] * (sum {i in COP} caps[i]);


############
#   DATA   #
############
data;

param: RP : min_demand :=
    diesel      14000
    gasoline    30000
    lubricant   10000
    jet_fuel     8000
;

param: COP: min_percent :=
        Iraq        0.4
        Dubai       0.6
;

param yield(tr):    Iraq    Dubai :=
    diesel      0.20    0.10
    gasoline    0.25    0.60
    lubricant   0.10    0.15
    jet_fuel    0.15    0.10
;


solve;
display caps;
display {r in RP, c in COP} yield[c,r] * caps[c];
display {r in RP} sum {c in COP} yield[c,r] * caps[c];
display {c2 in COP} (caps[c2]) / (sum {c in COP} caps[c]);