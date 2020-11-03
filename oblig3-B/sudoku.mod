reset;
option solver "/home/elg/ampl/cplex";

set SIZE = 1..9;
set GIVEN within {SIZE, SIZE};

param known {GIVEN} >= 1, <= 9; 

var X {SIZE, SIZE, SIZE} binary;

maximize Dummy: 0;

subject to fill_in_known {(x,y) in GIVEN}:
    X[x, y, known[x,y]] == 1;

subject to verticalLine {y in SIZE, n in SIZE}:
    sum {x in SIZE} X[x,y,n] == 1;

subject to horizontalLine {x in SIZE, n in SIZE}:
    sum {y in SIZE} X[x,y,n] == 1;

subject to filled_in {x in SIZE, y in SIZE}:
    sum {n in SIZE} X[x,y,n] == 1;

#Loop over every square to make sure there are 1 .. 9 in each of them
subject to square {n in SIZE, v in {1..3}, h in {1..3}}:
    sum {x in (h*3-2)..(3*h), y in (v*3-2)..(3*v)} X[x,y,n] == 1;

data "oblig3-B/Sudoku-Karl-Henrik-Elg-Barlinn.dat";
solve;

#collapse the 3D binary matrix into a standard 2D matrix
display {x in SIZE, y in SIZE} sum {n in SIZE} X[x,y,n]*n;
