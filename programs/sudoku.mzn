%-----------------------------------------------------------------------------%
% Sudoku for squares of arbitrary size N = (S x S)
%-----------------------------------------------------------------------------%

int: S;
int: N = S * S;


array[1..N,1..N] of var 1..N: puzzle;


include "alldifferent.mzn";

    % All cells in a row, in a column, and in a subsquare are different.
constraint
    forall(i in 1..N)( alldifferent(j in 1..N)( puzzle[i,j] ):: domain)
    /\
    forall(j in 1..N)( alldifferent(i in 1..N)( puzzle[i,j] ):: domain)
    /\
    forall(i,j in 1..S)
        ( alldifferent(p,q in 1..S)( puzzle[S*(i-1)+p, S*(j-1)+q] ):: domain);


solve satisfy;


output [ "sudoku:\n" ] ++
    [ show(puzzle[i,j]) ++
        if j = N then
            if i mod S = 0 /\ i < N then "\n\n" else "\n" endif
        else
            if j mod S = 0 then "  " else " " endif
        endif
    | i,j in 1..N ];


S=3;
puzzle=[|
4, _, 8, _, _, _, _, _, _|
_, _, _, 1, 7, _, _, _, _|
_, _, _, _, 8, _, _, 3, 2|
_, _, 6, _, _, 8, 2, 5, _|
_, 9, _, _, _, _, _, 8, _|
_, 3, 7, 6, _, _, 9, _, _|
2, 7, _, _, 5, _, _, _, _|
_, _, _, _, 1, 4, _, _, _|
_, _, _, _, _, _, 6, _, 4|
|];