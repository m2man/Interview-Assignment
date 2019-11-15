var 1..8: a;
var 1..8: b;
var 1..8: c;
var 1..8: d;
var 1..8: e;
var 1..8: f;
var 1..8: g;
var 1..8: h;

%array [1..8] of var 1..8: ar;

include "alldifferent.mzn";

constraint alldifferent([a, b, c, d, e, f, g, h]);

constraint abs(a-b)!=1;
constraint abs(a-c)!=1;
constraint abs(a-d)!=1;

constraint abs(b-e)!=1;
constraint abs(b-f)!=1;

constraint abs(c-b)!=1;
constraint abs(c-e)!=1;
constraint abs(c-f)!=1;
constraint abs(c-g)!=1;
constraint abs(c-d)!=1;

constraint abs(d-f)!=1;
constraint abs(d-g)!=1;

constraint abs(f-e)!=1;
constraint abs(f-g)!=1;

constraint abs(h-e)!=1;
constraint abs(h-f)!=1;
constraint abs(h-g)!=1;

solve satisfy;