include "alldifferent.mzn";

var 1..2:X;
var 1..2:Y;
var 1..3:Z;
constraint alldifferent([X,Y,Z]) :: bounds;
solve satisfy;
