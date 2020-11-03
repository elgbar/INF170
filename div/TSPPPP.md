# Traveling Salesman Problem

## Symmetric TSP

Nr of vars is half of symmetric
Each var x<sub>i,j</sub> is equal to xx<sub>j,i</sub>

pseudo-constraint i < j

Minimize tour length

For each node `n`, make sure that the sum of nodes from `1` to `n-1` plus sum of nodes from `n+1` to `N` (total number of nodes) is exactly equal to two

Iterate through all subset, make sure each subsection (called `S`) have `|S| - 1` connections.

## MTZ

count at what stop each city is

Minimize tour length

Make sure all cities have exactly one path in and one out

Make sure we set the city nr to the previous city plus one, or more exact the city number of city `i` should be strictly less than city `j` if we go directly from city `i` to `j`. both `i` and `j` should be greater than 1 (ie not contain the first node)

This works as given a sub tour a -> b -> c -> a will have f.eks <code>u<sub>a</sub></code> = 1, <code>u<sub>b</sub></code> = 2, <code>u<sub>c</sub></code> = 3. Now <code>u<sub>a</sub></code> must be < <code>u<sub>c</sub></code> which is impossible.

## Flow (Svestka)

## Steps (Dantzig)