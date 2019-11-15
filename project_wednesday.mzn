include "alldifferent_except_0.mzn";
include "count.mzn";

% Number of interviews per student
int: number_of_interviews;

% Number of students to be matched
int: number_of_students;

% Number of companies undertaking interviews
int: number_of_companies;

% Maximum Number of parallel interviews
int: number_of_suites;

% possible time slots during week
int:number_of_slots;

% Booking cost per suite
int: cost_of_suite;

% Name of each company
array[1..number_of_companies] of string: company_name;

% Student preferences for each company (1 is best, 5 is worst)
array[1..number_of_students,1..number_of_companies] of int: preference;

array[1..number_of_students] of set of int:allowed_slots;

% The disappointment cost per company
array[1..number_of_companies] of int: disappointment_cost;

% The minimum number of students seen, if not zero
array[1..number_of_companies] of int: min_assignment;

% The maximum number of students seen per company
array[1..number_of_companies] of int: max_assignment;

% daily cost of attending the conference per company
array[1..number_of_companies] of int: daily_rate;


% ----- FUNCTIONS -----
function var int: count_unique_in_array(array[int] of var int: ar, int:numbsuites) = sum(i in 1..numbsuites)(if count(ar, i) > 0 then 1 else 0 endif);

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


function var int: attendance_cost_1_company(array[int] of var int: ar, int: day_cost) = 
                  let {
                    var int: max_time = max(ar);
                    var int: day_max = if max_time >= 1 /\ max_time <= 4 then 1 elseif max_time >= 5 /\ max_time <= 8 then 2 elseif max_time >= 9 /\ max_time <= 12 then 3 elseif max_time >= 13 /\ max_time <= 16 then 4 else 5 endif;
                    var opt int: min_time = min(i in index_set(ar) where ar[i] > 0)(ar[i]);
                    var int: day_min = if min_time >= 1 /\ min_time <= 4 then 1 elseif min_time >= 5 /\ min_time <= 8 then 2 elseif min_time >= 9 /\ min_time <= 12 then 3 elseif min_time >= 13 /\ min_time <= 16 then 4 else 5 endif;
                  } 
                  in day_cost * (1 + day_max - day_min);


function var int: count(array[int] of var int: x, var int: y) ::promise_total =
  let { var 0..length(x): c; constraint count(x,y,c); } in c;

predicate alldifferent_except_0_atleast_k(array[int] of var int: vs,
                                          int: k) = 
    forall(k, l in index_set(vs) where k < l) (
       (
         vs[k] != 0 /\ vs[l] != 0 /\ 
         (count(vs, vs[k]) >= k \/ count(vs, vs[l]) >= k)
       ) -> vs[k] != vs[l]
    );
    
predicate one_suite_one_interview(array[int] of var int: sui, 
                                  array[int] of var int: sess) = 
    forall(k, l in index_set(sess) where k < l) (
       (sess[k] == sess[l] /\ 
       sess[k] != 0 /\ 
       sess[l] != 0) -> sui[k] != sui[l]
    );

% pre-calculated best preference score of all student
array[1..number_of_students] of int: best_preference_students = [best_preference(take_row_array(preference, i, number_of_companies), number_of_interviews)|i in 1..number_of_students];


% ------ VARIABLES -------

array[1..number_of_students, 1..number_of_companies, 1..3] of var 0..max([number_of_slots, number_of_suites]): result; % final result
array[1..number_of_students] of var 3..15: best_assign_students;  % preference score after assigning of all student (1d array)

% ----- CONSTRAINTS ------
% Constrain only 0, 1 in the 1st layer of result
constraint forall(i in 1..number_of_students, j in 1..number_of_companies)
                 (
                   result[i,j,1] == 0 \/ result[i,j,1] == 1
                 );
                
% Constrain 0 .. number_of_slots in the 2nd layer of result
constraint forall(i in 1..number_of_students, j in 1..number_of_companies)
                 (
                   result[i,j,1] >= 0 /\ result[i,j,2] <= number_of_slots
                 );
                 
% Constrain 0 .. number_of_suites in the 3nd layer of result
constraint forall(i in 1..number_of_students, j in 1..number_of_companies)
                 (
                   result[i,j,3] >= 0 /\ result[i,j,3] <= number_of_suites
                 );
                 
% constraint for n number of interview
constraint forall(i in 1..number_of_students)
            (
              sum(j in 1..number_of_companies)(result[i,j,1]) == number_of_interviews
            );
            
% constraint for capacity (min <= capa <= max)
constraint forall(j in 1..number_of_companies)
            (
              sum(i in 1..number_of_students)(result[i,j,1]) <= max_assignment[j] /\ sum(i in 1..number_of_students)(result[i,j,1]) >= min_assignment[j]
            );
            
            
% Sum of preference marks of companies that a student has an interview with             
constraint forall(i in 1..number_of_students)
                 (
                   best_assign_students[i] = sum(j in 1..number_of_companies)
                                                (
                                                  if result[i,j,1] == 1 then preference[i,j] else 0 endif
                                                )
                 );
                 
% constraint regret score of each student is <= 1 (EACH)           
constraint forall(i in 1..number_of_students)
                 (
                   abs(best_preference_students[i]-best_assign_students[i]) <= 1
                 );
                 
% constraint if no interview --> no slots in 2nd layer and no suites in 3rd layers
% constraint slot only in given allow slot
% constraint suites only take values from 1 .. 12
constraint forall(i in 1..number_of_students, j in 1..number_of_companies)
                 (
                   if result[i,j,1]==0 
                   then result[i,j,2] = 0 /\ result[i,j,3] = 0 
                   else
                     result[i,j,2] in allowed_slots[i] /\
                     result[i,j,3] in 1..number_of_suites
                   endif
                 );
                 
% constraint for student: only 1 interview in 1 slot (1 session)
constraint forall(i in 1..number_of_students)
                 (
                   alldifferent_except_0([result[i,j,2]|j in 1..number_of_companies])
                 );
                 
% constraint for company: only 2 interview in 1 slot (1 session)
constraint forall(j in 1..number_of_companies)
                 (
                   alldifferent_except_0_atleast_k([result[i,j,2]|i in 1..number_of_students], 2)
                 );
                 
% constraint 1 suite for only 1 interview
constraint one_suite_one_interview([result[i,j,3]|i in 1..number_of_students, j in 1..number_of_companies],
                                   [result[i,j,2]|i in 1..number_of_students, j in 1..number_of_companies]);
                                   
                                   
% ------ SCORES --------
var int: score_preference = sum(i in 1..number_of_students, j in 1..number_of_companies)(result[i,j,1] * preference[i,j]); % preference score
var int: score_rent_suites = cost_of_suite * count_unique_in_array([result[i,j,3]|i in 1..number_of_students, j in 1..number_of_companies], number_of_suites);
var int: score_attendance = sum(j in 1..number_of_companies)(attendance_cost_1_company([result[i,j,2]|i in 1..number_of_students], daily_rate[j]));

solve :: int_search(result,
                    input_order,
                    indomain_min)
                    minimize(score_preference + score_rent_suites + score_attendance);
                    
%solve minimize(score_preference + score_rent_suites + score_attendance);

output ["Student,Company, Time, Room\n"] ++ 
       [concat([show(i)++","++company_name[j]++","++show(result[i,j,2])++","++show(result[i,j,3])++"\n"|i in 1..number_of_students, j in 1..number_of_companies where fix(result[i,j,1]==1)])] ++ 
       ["*** Score ***\nScore Preference: ", show(score_preference),"\n", "Score Rent: ", show(score_rent_suites), "\n", "Score Attend: ", show(score_attendance),"\n"];