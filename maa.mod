reset;
# option solver "/home/elg/ampl/cplex";
option solver "/home/elg/ampl/gurobi";
option gurobi_options "timelim=3600 outlev=0";

param ports >= 1; #Number of ports 
param dv = ports + 1;
param hn = -1;  #Home node
param dn = 0;   #Destination node

param cargoes >= 1;

set V;                              # Set of all vessels
set C;                              # Set of all cargoes
set N;                              # set of all nodes 
set P = 1..(ports+1);               # Set of all ports (inc art dest port)

set PTC within {V, N};              # port times and costs
set A within {V, P, P};             # Travel time and cost          (officially A)
param can_transport {V, C} binary;      # if a given vessel can transport a given cargo

#Vessel params
param home_port {V} >= 0, <= ports;     # Home port
param start_time {V} >= 0;              # starting time
param capacity {V} >= 0;                # capacity

#Cargo params>
param origin_port {C} >= 0, <= ports;   # Origin port
param dest_port {C} >= 0, <= ports;     # Destination port
param size {C} >= 0;                    # Size of cargo
param nt_cost {C} >= 0;                 # Cost of not transporting (math: C)
param lower_pickup {C} >= 0;            # Lowerbound time window for pickup
param upper_pickup {C} >= 0;            # Upper time window for pickup
param lower_delivery {C} >= 0;          # Lowerbound time window for delivery
param upper_delivery {C} >= 0;          # Upper time window for delivery

#Node constraints
param cargo {N} >= 0, <= 7;
    #make sure there are two cargoes for each
    # check {n in C}: cargo[n] == cargo[n+cargoes];

param port {N} >= 0, <= ports;
    # check {n in N}: port[n] == if(n <= cargoes) 
    #     then origin_port[cargo[n]] 
    #     else dest_port[cargo[n]];
    
param lower_time {N} >= 0;
    #make sure the correct lower time is set
    # check {n in N}: lower_time[n] == if(n <= cargoes) then lower_pickup[cargo[n]] else lower_delivery[cargo[n]];

param upper_time {N} >= 0;
    # check {n in N}: lower_time[n] <= upper_time[n] && 
    #                 upper_time[n] == if(n <= cargoes) then upper_pickup[cargo[n]] else upper_delivery[cargo[n]];

#port times and costs params
param port_time {PTC} >= 0;      #origin port time (in hours)
param port_cost {PTC} >= 0;     #origin port costs (in �)

#Travel time and cost params
param travel_time {A} >= 0;           #travel time (in hours)
param travel_cost {A} >= 0;           #travel cost (in �)

set Nv := {v in V, n in N, i in P: (n == -1 && i == home_port[v]) || (n == 0 && i == dv) || (n >= 1 && can_transport[v,cargo[n]] && port[n] == i)};
set Av := {v in V, (v,n,i) in Nv, (v,m,j) in Nv: n != dn && m != hn};

set NP := {n in N: 1 <= n <= cargoes};
set ND := {n in N: n > cargoes};

set NPV := {(v,n,i) in Nv: 1 <= n <= cargoes};
set NDV := {(v,n,i) in Nv: cargoes < n <= cargoes*2};

var t {V, N} >= 0; #when vessel v is at node p 
var l {V, N} >= 0; #size of cargo for vessel v at node p

var x {V, N, P, N, P} binary;   #whether ship v moves  directly  from  node i to  node j.
var y {C} binary;               #whether cargo is transported by the available vessel fleet.

#(1)
minimize Z:
    sum {v in V, (v,n,i,m,j) in Av: m <> dn} 
        x[v,n,i,m,j] * (travel_cost[v,i,j] + port_cost[v,m]) 
    + sum {c in NP} nt_cost[c] * y[c]
;

# subject to hard_y {c in C}:
#     y[c] == if c mod 2 then 0 else 1;

# subject to v1:
#     x[1,hn,home_port[1], 3,port[3]] + 
#     x[1,3,port[3],3+cargoes,port[3+cargoes]] +
#     x[1,3+cargoes,port[3+cargoes],dn,dv] 
#     = 3;

# subject to v2:
#     x[2,hn,home_port[2], 7,port[7]] + 
#     x[2,7,port[7],1,port[1]] +
#     x[2,1,port[1],7+cargoes,port[7+cargoes]] +
#     x[2,7+cargoes,port[7+cargoes],1+cargoes,port[1+cargoes]] +
#     x[2,1+cargoes,port[1+cargoes],dn,dv] 
#     = 5;

# subject to v3:
#     x[3,hn,home_port[3], 5,port[5]] + 
#     x[3,5,port[5],5+cargoes,port[5+cargoes]] +
#     x[3,5+cargoes,port[5+cargoes],dn,dv] 
#     = 3;


# (2)
# Each cargo is picked up or handled by spot charter
subject to all_cargo_handled {n in NP, i in {port[n]}}:
    sum {v in V, (v,n,i,m,j) in Av} x[v,n,i,m,j] + y[n] = 1;

# #(3)
# #all vessels move from home port to any other port (or D(v))
subject to vessels_move_from_home_port {v in V}:
    sum {(v,m,j) in Nv: m <> hn} x[v, hn,home_port[v], m, j] = 1;

# #(4)
# #if we go into a port we go out of it (minus home and destination port)
subject to connected_route {v in V, (v,n,i) in Nv: n >= 1}:
    sum {(v,n,i,m,j) in Av} x[v,n,i,m,j] - sum {(v,m,j,n,i) in Av} x[v,m,j,n,i] = 0;

# #(5)
# #all vessels moves to d(v) eventually
subject to arrive {v in V}:
    sum {(v,n,i) in Nv: n <> dn} x[v,n,i,dn,dv] = 1;

# #(6)
subject to loading {v in V, (v,m,j) in NPV, (v,n,i,m,j) in Av: n >= 1}:
    l[v,n] + size[m] - l[v,m] <= capacity[v] * (1 - x[v,n,i,m,j]);

# #(7)
subject to unloading {v in V, (v,m,j) in NPV, (v,n,i,cm,cj) in Av: n >= 1 && cm = m+cargoes}:
    l[v,n] - size[m] - l[v,cm] <= capacity[v] * (1 - x[v,n,i,cm,cj]);

# #(8)
# #The load onboard should be positive and less than capacity
subject to vessel_capacity {(v,n,i) in NPV}:
    0 <= l[v,n] <= capacity[v];

# #(9)
# #Arrive within the time window
subject to total_travel_time {v in V, (v,n,i,m,j) in Av: m <> dn}:
    t[v,n] + (travel_time[v,i,j] + port_time[v,m]) - t[v,m] 
        <= (upper_time[n] + (travel_time[v,i,j] + port_time[v,m])) * (1-x[v,n,i,m,j]);

# #(10)
# #you should visit loading and unloading with the same ship
subject to same_ship_loaded {v in V, (v,n,i) in NPV: n >= 1}:
    sum {(v,n,i,m,j) in Av} x[v,n,i,m,j] -
    sum {(v,n,i,m,j) in Av: 1 <= n <= cargoes} x[v,n+cargoes,port[n+cargoes],m,j] = 0;

# #(11)
# #don't unload before you load
subject to load_order {v in V, (v,n,i) in NPV}:
    t[v,n] + (travel_time[v,i,port[n+cargoes]] + port_time[v, n + cargoes]) - t[v,n + cargoes] <= 0;

# #(12)
# #arrive within the time window
subject to time_window_pickup {v in V, (v,n,i) in Nv}:
    lower_time[n] <= t[v, n] <= upper_time[n];

# # #(13?)
# # #Make sure the start time for each vessel is at least at start time defined
# # subject to vessel_start_time {v in V, n in N: can_transport[v,cargo[n]]}:
# #     x[home_port[v], port[n], v] * start_time[v] <= t[v,n];

subject to starting_time {v in V}:
    t[v,-1] = start_time[v];

data "oblig3-A/maa.dat";

solve;

#What vessels are we using freight shipping in
display y;
#Whats our route
display {(v,n,i,m,j) in Av: x[v,n,i,m,j]} (v,i,j);


# display sum {v in V, i in P, j in P: x[i,j,v] && j <> dv} (travel_cost[v,i,j]);
# display sum {(v,n,i,m,j) in Av: x[i,j,v] && j <> dv} (travel_cost[v,i,j]);
# display sum {c in C} (y[c] * nt_cost[c]);
