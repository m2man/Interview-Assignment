int: p; int: nh; int: ng;
set of int : HostBoats = 1..nh;
set of int : GuestCrews = 1..ng;
set of int : Time = 1..p;
array [GuestCrews] of int : crew;
array [HostBoats] of int : capacity;

array [GuestCrews, Time] of var HostBoats : hostedBy;
array [GuestCrews, HostBoats, Time] of var 0..1 : visits;
constraint forall (g in GuestCrews, h in HostBoats, t in Time)
( visits[g,h,t] = 1 <-> hostedBy[g,t]=h ); % channel

constraint forall (h in HostBoats)
( forall (g in GuestCrews)
(sum (t in Time) (visits[g,h,t]) <= 1) % at_most_one_visit
/\ forall (t in Time)
(sum (g in GuestCrews) (crew[g]*visits[g,h,t]) <= capacity[h]));
% capacity

array [GuestCrews, GuestCrews, Time] of var 0..1 : meet;
constraint forall (k, l in GuestCrews where k<l)
( forall (t in Time)
(hostedBy[k,t] = hostedBy[l,t] -> meet[k,l,t] = 1) % will_meet
/\ sum (t in Time) (meet[k,l,t]) <= 1 ); % meet_once

solve satisfy;
	output [show(hostedBy)];

    % party.1.dzn
crew = [6, 5, 4, 4, 4, 3, 2, 2, 2, 2];
capacity = [7, 10, 8, 8, 11];
nh = 5;
ng = 10;
p = 3;