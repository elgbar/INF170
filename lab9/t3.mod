reset;
option solver "/home/elg/ampl/cplex";

set AL; #Air lines 
set EM := {3, 5, 6}; #extra miles
param extra {AL, EM} default 0; #Bonus tickets

param per {AL} >= 0;    # Miles per ticket bought
param tickets >= 0;     #Number of tickets to buy

var x {AL} integer; #Tickets bought
var m {AL, EM} binary; #extra miles 

maximize most_miles: 
    sum {i in AL} x[i] * per[i] + sum {i in AL, j in EM} (m[i,j]*extra[i,j]+m[i,j]); #add m[i,j] to force all valid m[i,j] to be 1

#Make sure we buy exactly the specified number of tickets
subject to nr_of_tickets:
    sum {i in AL} x[i] = tickets;

#Make sure only extra miles are enabled when 
# we have bought enough tickets
subject to extra_miles {i in AL, j in EM}:
    j - (1-m[i,j])*tickets <= x[i];

#Force eastern to have max 4 flights (just test constraint)
# subject to test:
#     x["Eastern"] <= 4;

############
#   DATA   #
############
data;

param tickets := 16;

param:  AL:         per  :=
        Eastern     1500
        US_Air      1800
        Continental 2000
;

param extra :    3    5    6 :=
    Eastern     5000 5000 .
    US_Air      .    .    12000
    Continental .    7500 .
;

solve;
display x;
display m;