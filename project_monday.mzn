int: k; % number of contact company of each student (k = 3)
int: number_of_students;
int: number_of_companies;

array[1..number_of_companies] of string: companies;
array[1..number_of_students, 1..number_of_companies] of int: preferences;
array[1..number_of_companies] of int: capacity;


array[1..number_of_students, 1..number_of_companies] of var 0..1: result;
var int: score1; % score of minimize
var int: score2; % score of minimize the maximize

% constraint for n number of interview
constraint forall(i in 1..number_of_students)
            (
              sum(j in 1..number_of_companies)(result[i,j]) == k
            );
            
% constraint for capacity
constraint forall(j in 1..number_of_companies)
            (
              sum(i in 1..number_of_students)(result[i,j]) <= capacity[j]
            );

   
       
constraint score1 = sum(i in 1..number_of_students, j in 1..number_of_companies)(result[i,j] * preferences[i,j]);
constraint score2 = max(i in 1..number_of_students)(sum(j in 1..number_of_companies)(result[i,j]*preferences[i,j]));

% Redundant constraint
%constraint sum(i in 1..number_of_students, j in 1..number_of_companies)(result[i,j]) == k * number_of_students;

/*
solve :: int_search(result,
                    first_fail,
                    indomain_min) 
                    minimize (score1 + score2);
*/

%solve minimize(score1+score2);


solve :: int_search(result,
                    dom_w_deg,
                    indomain_min)
                    minimize (score1 + score2);

output [concat([show(i)++":"++companies[j]++"\n"|i in 1..number_of_students, j in 1..number_of_companies where fix(result[i,j]==1)])] ++ 
      ["Score 1: ", show(score1), "\n", "Score 2: ", show(score2),"\n"];
