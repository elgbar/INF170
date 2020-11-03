reset;

set INTER;  #I
set FINAL;  #J
set ATTRI;  #K

param avaliable {INTER} >= 0;

param r {INTER,ATTRI} >= 0;
param u {FINAL,ATTRI} >= 0;
param s {INTER, FINAL} >= 0; # binary

param c {FINAL} >= 0;

var X{INTER, FINAL}; #>= (s[i,j] * avaliable[i]), X[i,j] >= 0;
var Y{FINAL} >= 0;

maximize Objective:
    sum{j in FINAL} c[j] * Y[j];

subject to Avail {i in INTER}:
    sum{j in FINAL} X[i,j] == avaliable[i];

subject to Comp {j in FINAL}:
    sum{i in INTER} X[i,j] == Y[j];

subject to Balance {j in FINAL, k in ATTRI}:
    sum{i in INTER} r[i,k] * X[i,j] <= u[j,k]*Y[j];

subject to X_Bound{i in INTER,j in FINAL}:
    0 <= X[i,j] <= s[i,j] * avaliable[i];


data;

# set INTER := SRG N RF CG B DI GO RS;
set FINAL := PG RG D HF;
set ATTRI := vap oct den sul;

param: INTER:  avaliable :=
        SRG     21170
        N       500
        RF      16140
        CG      4610
        B       370
        DI      250
        GO      11600
        RS      25210

solve;

display X;
display Y;