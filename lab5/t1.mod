reset;

set COMP;

param avg_time >= 0;

param base_cost {COMP} >= 0;
param per_minute_cost {COMP} >= 0;

var Used_comp {COMP} binary; # 1 if company is used, 0 otherwise
var Time_used {COMP} >= 0; 

minimize Cost:
    sum{c in COMP} (Used_comp[c] * base_cost[c] + Time_used[c] * per_minute_cost[c]);

subject to Total_Time :
    sum {c in COMP} Time_used[c] >= avg_time;

subject to  Used {c in COMP}:
    Time_used[c] <= avg_time * Used_comp[c];

############
#   DATA   #
############
data;

param avg_time := 200;

param:
    COMP :      base_cost   per_minute_cost :=
    MaBell      16          0.25
    PaBell      25          0.21
    BabyBell    18          0.22    
;

solve;
display Used_comp;
display Time_used;
display Cost;