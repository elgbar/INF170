# Mathematical model of Knapsack problem (optimalInvest)

## vars

x<sub>j</sub> = 1 if project j is chosen

x<sub>j</sub> = Otherwise 

j in prods

## obj

max sum {i in prods} x<sub>i</sub>*value<sub>i</sub>

## st

sum {i in prods} x<sub>i</sub>*staff<sub>i</sub> <= 28 #max number of staff

sum {i in prods} x<sub>i</sub> <= 9 #max nr of projects

sum {i in prods} x<sub>i</sub>*budget<sub>i</sub> <= 225 #max nr of projects

### Not together
x1 + x10 <= 1
x5 + x6 <= 1
x11 + x15 <= 1

### Needed

x3 <= x15
x4 <= x15

x8 <= x7

x13 <= x2
x14 <= x2

prods elem {1..15}
x elem {0,1}
