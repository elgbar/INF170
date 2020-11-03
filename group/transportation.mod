set ORIG;
set DEST;

param supply{ORIG} >= 0;
param demand{DEST} >= 0;
    check: sum {o in ORIG} supply[o] = sum {d in DEST} demand[d];

param cost{ORIG, DEST} >= 0;

var trans {ORIG, DEST} >= 0;

minimize Total_Cost:
    sum {o in ORIG, d in DEST} cost[o,d] * trans[o,d];
    
subject to Supply{o in ORIG}:
    sum {d in dest} trans[o,d] == supply[o];
    
subject to Demand{d in DEST}:
    sum {o in ORIG} trans[o,d] == demand[d];