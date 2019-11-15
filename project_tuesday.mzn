% Number of interviews per student
int: number_of_interviews;

% Number of students to be matched
int: number_of_students;

% Number of companies undertaking interviews
int: number_of_companies;

% Name of each company
array[1..number_of_companies] of string: company_name;

% Student preferences for each company (1 is best, 5 is worst)
array[1..number_of_students,1..number_of_companies] of int: preference;

% The disappointment cost per company
array[1..number_of_companies] of int: disappointment_cost;

% The disappointment cost per company
array[1..number_of_companies] of int: min_assignment;

% The disappointment cost per company
array[1..number_of_companies] of int: max_assignment;


int: sum_disappointment = sum(j in 1..number_of_companies)(disappointment_cost[j]);
float: weight_3 = 1/sum_disappointment;
int: weight_1 = (5-1)*number_of_interviews;
float: weight_2 = 10/(15*number_of_students);

% define function to compute the best preference score for 1 student
% the function will first sort the marks in ascending order
% --> best score will be sum of several first value in sorted array
% input 
%  1d array pre: the preference marks of that students
%  int numb_interview: number of interview of each students
% ouput is the best preference marks scores (integer)
function int: best_preference(array[int] of int: pre, int: numb_interview) = let {array[1..length(pre)] of int: sort_pre_idx = arg_sort(pre)} in sum(i in 1..numb_interview)(pre[sort_pre_idx[i]]);


% define function to extract the selected row in a 2d array
% input
%  2d array ar
%  int row: the row that you want to extract
% output will be 1d array
function array[int] of int: take_row_array(array[int,int] of int: ar, int: row, int: ncol) = [ar[row,i]|i in 1..ncol];

% pre-calculated best preference score of all student
array[1..number_of_students] of int: best_preference_students = [best_preference(take_row_array(preference, i, number_of_companies), number_of_interviews)|i in 1..number_of_students];



array[1..number_of_students, 1..number_of_companies] of var 0..1: result; % final result
array[1..number_of_students] of var 3..15: best_assign_students;  % preference score after assigning of all student (1d array)
var int: score1; % score of minimize regret
var int: score2; % score of minimize the preference
var int: score3; % score of minimize disappointment



% constraint for n number of interview
constraint forall(i in 1..number_of_students)
            (
              sum(j in 1..number_of_companies)(result[i,j]) == number_of_interviews
            );
            
% constraint for capacity (0, min <= capa <= max)
constraint forall(j in 1..number_of_companies)
            (
              (sum(i in 1..number_of_students)(result[i,j]) <= max_assignment[j] /\ sum(i in 1..number_of_students)(result[i,j]) >= min_assignment[j]) \/ sum(i in 1..number_of_students)(result[i,j]) == 0
            );

% Find preference score of all student after assigning interview
% Sum of preference marks of companies that a student has an interview with             
constraint forall(i in 1..number_of_students)
                 (
                   best_assign_students[i] = sum(j in 1..number_of_companies)
                                                (
                                                  if result[i,j] == 1 then preference[i,j] else 0 endif
                                                )
                 );

constraint score1 = sum(i in 1..number_of_students)(abs(best_preference_students[i]-best_assign_students[i])); % regret score
constraint score2 = sum(i in 1..number_of_students, j in 1..number_of_companies)(result[i,j] * preference[i,j]); % preference score
constraint score3 = sum(c in 1..number_of_companies)(if sum(i in 1..number_of_students)(result[i,c]) == 0 then disappointment_cost[c] else 0 endif); % disappointment score

solve :: int_search(result,
                    dom_w_deg,
                    indomain_min)
                    minimize (weight_1*score1 + weight_2*score2 + weight_3*score3);
                    
output [concat([show(i)++":"++company_name[j]++"\n"|i in 1..number_of_students, j in 1..number_of_companies where fix(result[i,j]==1)])] ++ 
      ["*** Score ***\nScore 1: ", show(score1), "\n", "Score 2: ", show(score2), "\n", "Score 3: ", show(score3),"\n", "Weighted Score: ", show(weight_1*score1 + weight_2*score2 + weight_3*score3),"\n"];