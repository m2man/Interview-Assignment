int: n; % number of point
int: m; % number of edge
array[1..m,1..2] of int: e; % edge matrix (m rows x 2 points)

array[1..n] of var 1..n: p; % vector of points

include "alldifferent.mzn";

constraint alldifferent(p);  

constraint forall(i in 1..m)(abs(p[e[i,1]] - p[e[i,2]]) > 1);

solve satisfy;

output ["points=\(p)"];