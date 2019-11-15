include "alldifferent.mzn";

var {1,3}:X;
var {1,3}:Y;
var 1..3:Z;

constraint alldifferent([X,Y,Z]) :: domain;
solve satisfy;
