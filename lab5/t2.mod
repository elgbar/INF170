reset;
option solver "/home/elg/ampl/cplex";


set FRIENDS;
set BOTTLES;

param content {BOTTLES} >= 0, <= 1;
param amount {BOTTLES} integer;

param total_bottles integer >= 0;
    check sum {b in BOTTLES} amount[b] == total_bottles;
param total_friends integer >= 0;
    check sum {f in FRIENDS} 1 == total_friends;


#How many of a given bottle a friend has
var X{BOTTLES,FRIENDS} integer >= 0;

maximize Dummy: 0;

subject to Bottle_amount {b in BOTTLES}:
    sum {f in FRIENDS} X[b,f] == amount[b];

subject to Bottle_Equality {f in FRIENDS}:
    sum{b in BOTTLES} X[b,f] == total_bottles/total_friends;

subject to Content_Equality {f in FRIENDS}:
    sum {b in BOTTLES} X[b,f]*content[b] == (sum {b in BOTTLES, g in FRIENDS} X[b,g]*content[b])/total_friends;

############
#   DATA   #
############
data;

set FRIENDS := 1 2 3;

param total_bottles := 21;
param total_friends := 3;

param: BOTTLES : content amount :=
        FULL	1	    7	
        HALF    0.5     7   
        EMPTY   0       7
;

solve;
display X;
display sum {b in BOTTLES} X[b,3]*content[b];