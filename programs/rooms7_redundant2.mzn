% rooms.mzn
include "globals.mzn";

int: nrTeams=8;
int: nrGames=round((nrTeams*(nrTeams-1))/2);
set of int: games = 1..nrGames;
int: nrDays=7;
set of int: days =1..nrDays;
int: nrLocations =7;
set of int:locations = 1..nrLocations;
int: nrSlots=nrDays*nrLocations;
set of int:slots = 1..nrSlots;
set of int:team1Games = {1,2,3,4,5,6,7};
set of int:team2Games = {1,8,9,10,11,12,13};
set of int:team3Games = {2,8,14,15,16,17,18};
set of int:team4Games = {3,9,14,19,20,21,22};
set of int:team5Games = {4,10,15,19,23,24,25};
set of int:team6Games = {5,11,16,20,23,26,27};
set of int:team7Games = {6,12,17,21,24,26,28};
set of int:team8Games = {7,13,18,22,25,27,28};

array[slots] of int:mapDay = 
[1,1,1,1,1,1,1,
2,2,2,2,2,2,2,
3,3,3,3,3,3,3,
4,4,4,4,4,4,4,
5,5,5,5,5,5,5,
6,6,6,6,6,6,6,
7,7,7,7,7,7,7];
array[slots] of int:mapLocation = 
[1,2,3,4,5,6,7,
1,2,3,4,5,6,7,
1,2,3,4,5,6,7,
1,2,3,4,5,6,7,
1,2,3,4,5,6,7,
1,2,3,4,5,6,7,
1,2,3,4,5,6,7];

array[games] of var slots:x;
array[games] of var days:pDay;
array[games] of var locations:pLoc;

predicate exactly(array[int] of var int:x,int:count,int:value) = 
 count = sum(i in index_set(x))(x[i] = value);
% predicate exactly(array[int] of var int:x,int:count,int:value) = 
% count(x,value,count);
 
constraint alldifferent(x):: domain;
constraint forall(game in games)
  (pDay[game] = mapDay[x[game]]);
constraint forall(game in games)
  (pLoc[game] = mapLocation[x[game]]);
constraint forall(day in days)
  (exactly(pDay,4,day));
constraint forall(location in locations)
  (exactly(pLoc,4,location));
%constraint global_cardinality(pDay,[1,2,3,4,5,6,7],[4,4,4,4,4,4,4]):: domain;
%constraint global_cardinality(pLoc,[1,2,3,4,5,6,7],[4,4,4,4,4,4,4]):: domain;
  % each team play once on each day
constraint alldifferent([pDay[i]|i in team1Games]):: domain;
constraint alldifferent([pDay[i]|i in team2Games]):: domain;
constraint alldifferent([pDay[i]|i in team3Games]):: domain;
constraint alldifferent([pDay[i]|i in team4Games]):: domain;
constraint alldifferent([pDay[i]|i in team5Games]):: domain;
constraint alldifferent([pDay[i]|i in team6Games]):: domain;
constraint alldifferent([pDay[i]|i in team7Games]):: domain;
constraint alldifferent([pDay[i]|i in team8Games]):: domain;
% each team plays once in each location
constraint alldifferent([pLoc[i]|i in team1Games]):: domain;
constraint alldifferent([pLoc[i]|i in team2Games]):: domain;
constraint alldifferent([pLoc[i]|i in team3Games]):: domain;
constraint alldifferent([pLoc[i]|i in team4Games]):: domain;
constraint alldifferent([pLoc[i]|i in team5Games]):: domain;
constraint alldifferent([pLoc[i]|i in team6Games]):: domain;
constraint alldifferent([pLoc[i]|i in team7Games]):: domain;
constraint alldifferent([pLoc[i]|i in team8Games]):: domain;
  
% hints: preassigned games  
constraint x[2] = 47;
constraint x[4] = 9;
constraint x[19] = 39;
constraint x[24] = 5;
% hints: preassigned teams; 
constraint exists(i in team1Games)(x[i]=28);
constraint exists(i in team1Games)(x[i]=34);
constraint exists(i in team2Games)(x[i]=8);
constraint exists(i in team2Games)(x[i]=26);
constraint exists(i in team4Games)(x[i]=43);
constraint exists(i in team5Games)(x[i]=27);
constraint exists(i in team7Games)(x[i]=15);
constraint exists(i in team8Games)(x[i]=2);
constraint exists(i in team8Games)(x[i]=17);
constraint exists(i in team8Games)(x[i]=29);
% redundant
constraint forall(i in index_set(x) where not( i in team1Games))(x[i]!=28);
constraint forall(i in index_set(x) where not( i in team1Games))(x[i]!=34);
constraint forall(i in index_set(x) where not( i in team2Games))(x[i]!=8);
constraint forall(i in index_set(x) where not( i in team2Games))(x[i]!=26);
constraint forall(i in index_set(x) where not( i in team4Games))(x[i]!=43);
constraint forall(i in index_set(x) where not( i in team5Games))(x[i]!=27);
constraint forall(i in index_set(x) where not( i in team7Games))(x[i]!=15);
constraint forall(i in index_set(x) where not( i in team8Games))(x[i]!=2);
constraint forall(i in index_set(x) where not( i in team8Games))(x[i]!=17);
constraint forall(i in index_set(x) where not( i in team8Games))(x[i]!=29);
% global redundant
constraint forall(i in index_set(x))(x[i] != 1);
constraint forall(i in index_set(x))(x[i] != 22);
constraint forall(i in index_set(x))(x[i] != 36);

predicate exclude(var int:x,set of int:values) = 
 forall(v in values)(x != v);
constraint forall(i in team1Games)( exclude(x[i],{7,14,21,35,42,49,22,23,24,25,26,27}));
constraint forall(i in team1Games)( exclude(x[i],{6,13,20,27,41,48,29,30,31,32,33,35}));
constraint forall(i in team2Games)( exclude(x[i],{1,15,22,29,36,43,9,10,11,12,13,14}));
constraint forall(i in team2Games)( exclude(x[i],{5,12,19,33,40,47,22,23,24,25,27,28}));
constraint forall(i in team4Games)( exclude(x[i],{1,8,15,22,29,36,44,45,46,47,48,49}));
constraint forall(i in team5Games)( exclude(x[i],{6,13,20,34,41,48,22,23,24,25,26,28}));
constraint forall(i in team7Games)( exclude(x[i],{1,8,22,29,36,43,16,17,18,19,20,21}));
constraint forall(i in team8Games)( exclude(x[i],{3,10,24,31,38,45,15,16,18,19,20,21}));
constraint forall(i in team8Games)( exclude(x[i],{1,3,4,5,6,7,9,16,23,30,37,44}));
constraint forall(i in team8Games)( exclude(x[i],{1,8,15,22,36,43,30,31,32,33,34,35}));

solve ::int_search(x,input_order,indomain_min) satisfy;
