# q 1

non-linear

if 0 <= x <= 3 
    y = 2x
else if  4 <= x <= 7
    y=9-x
else if 8 <= x <= 9
    y=-5+x

var a,b,c binary
var x

obj a*(2x) + b * (9-x) + c*(-5+x)

#One at a time
a + b + c <= 1

0 - (1-a) * M <= x <= 3 + (1-a) * M
4 - (1-b) * M <= x <= 7 + (1-b) * M
8 - (1-c) * M <= x <= 9 + (1-c) * M

























# q 2

<code>If 2x<sub>1</sub> + x<sub>2</sub> ≤ 5 then 2x<sub>3</sub> - x<sub>4</sub> ≥ 2</code>

var <code>x<sub>i</sub></code> integer

var y binary

<code>2x<sub>1</sub> + x<sub>2</sub> ≤ 5 + (1-y)*M</code>

<code>2 - (1-y)*M ≤ 2x<sub>3</sub> - x<sub>4</sub></code>

