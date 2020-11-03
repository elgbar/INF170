# Task 4 lab 2
# reset; model lab2/t4.mod; data lab2/t4.dat; solve; display loans;

set TYPE;
set COMPETATIVE_TYPE within TYPE;
set HOUSE_HELP within TYPE ordered;

param total_max_loans > 0;          #Max loan in million
param max_bad_depth >= 0, <= 1;     #Max percent bad depth
param min_comp_percent >= 0, <= 1;  #Min percent in the competative markets of total
param min_house_percent >= 0, <= 1; #Min percent of house loans of HOUSE_HELP

param rate {TYPE} >= 0;             #The interest rate for each type of loan
param bd_ratio {TYPE} >= 0, <= 1;   #The bad depth ratio for each type of loan 

var loans {t in TYPE} >= 0;

#How much income from the loans
maximize income:
    sum {t in TYPE} (loans[t] - loans[t] * bd_ratio[t]) * rate[t];

subject to max_loan:
    1 <= sum {t in TYPE} loans[t] <= total_max_loans;

subject to good_depth:
    (sum {t in TYPE} loans[t] * bd_ratio[t]) / sum {t in TYPE} loans[t] <= max_bad_depth;

subject to competition:
    min_comp_percent <= (sum {c in COMPETATIVE_TYPE} loans[c]) / sum {t in TYPE} loans[t];
    
subject to house_help:
    min_house_percent <= loans[first(HOUSE_HELP)] / (sum {t in HOUSE_HELP} loans[t])