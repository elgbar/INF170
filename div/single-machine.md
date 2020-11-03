# Single Machine

## params & vars
```ampl
set J = {1..7} integer;
param NJ = |J|
set R = {1..NJ} integer;

param release {J};  #Time of release
param duration {J}; #Duration of job
param dd {J};       # due date

var x {J, R} binary;
var start {R};              #Start time of task at rank r

```
## Objectives

### makespan objective

```ampl
objective makespan:
    minimize start[NJ] + sum {j in J} x[j,NJ] * duration[j];
```

### average time objective

```ampl
objective avg:
    minimize sum {j in J, r in R: x[j,r]} (start[r] + duration[j]);
```

### tardiness objective

```ampl
objective tardiness:
    minimize sum {j in J, r in R: x[j,r]} (start[r] + duration[j] - dd[j]);
```
    
## constraints 

```ampl
s.t. job_rank {r in R}: #One job per rank
    sum {j in J} x[j,r] = 1;

s.t. rank_rob {j in J}: #One rank per job
    sum {r in R} x[j,r] = 1;

#Each job start at the earliest when released
s.t. release_date {j in J}:
    sum {r in R} x[j,r]*start[r] >= release[j];

s.t. earliest_rank_start {r in R: r >= 2}:
    sum {j in J} x[j,r]*duration[r] + start[r-1] <= start[r]

```



# Flow Shop