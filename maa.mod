#maa = Mandatory Assignment A
reset;

#You might want to change this to just "gurobi"
option solver "/home/elg/ampl/gurobi";
# option gurobi_options "outlev=0";

param ports >= 1;       #Number of ports 
param cargoes >= 1;     #Number of cargoes
param dv = ports + 1;   #d(v), Destination port (artificial)
param hn = -1;          #Home node
param dn = 0;           #Destination node

set V;                  # Set of all vessels
set C;                  # Set of all cargoes
set N;                  # set of all nodes 
set P = 1..(ports+1);   # Set of all ports (inc art dest port)

set PTC within {V, N};              # port times and costs
set A within {V, P, P};             # Travel time and cost
param can_transport {V, C} binary;  # if a given vessel is able to transport a given cargo

#Vessel params
param home_port {V} >= 0, <= ports; # Home port (o(v))
param start_time {V} >= 0;          # starting time
param capacity {V} >= 0;            # capacity (Kv)

#Cargo params
param origin_port {C} >= 0, <= ports;   # Origin port
param dest_port {C} >= 0, <= ports;     # Destination port
param size {C} >= 0;                    # Size of cargo
param nt_cost {C} >= 0;                 # Cost of not transporting (math: C)
param lower_pickup {C} >= 0;            # Lowerbound time window for pickup
param upper_pickup {C} >= 0;            # Upper time window for pickup
param lower_delivery {C} >= 0;          # Lowerbound time window for delivery
param upper_delivery {C} >= 0;          # Upper time window for delivery

#Node constraints
#The commented out checks are there to make sure ive correctly copied values from cargo
# to N, they will not pass if N {-1, 0} exists so make sure to comment them out before 
# un-commenting checks under 
param cargo {N} >= 0, <= 7;
    #make sure there are two cargoes for each
    # check {n in C}: cargo[n] == cargo[n+cargoes];

param port {N} >= 0, <= ports;
    #Each port in node is correct from origin/dest nodes
    # check {n in N}: port[n] == if(n <= cargoes) 
    #     then origin_port[cargo[n]] 
    #     else dest_port[cargo[n]];
    
param lower_time {N} >= 0;
    #make sure the correct lower time is set
    # check {n in N}: lower_time[n] == if(n <= cargoes) then lower_pickup[cargo[n]] else lower_delivery[cargo[n]];

param upper_time {N} >= 0;
    #make sure the correct upper time is set
    # check {n in N}: lower_time[n] <= upper_time[n] && 
    #                 upper_time[n] == if(n <= cargoes) then upper_pickup[cargo[n]] else upper_delivery[cargo[n]];

#port times and costs params
param port_time {PTC} >= 0;     #origin port time (in hours)
param port_cost {PTC} >= 0;     #origin port costs (in �)

#Travel time and cost params
param travel_time {A} >= 0;     #T_vij, travel time (in hours)
param travel_cost {A} >= 0;     #C_vij, travel cost (in �)

#Nv from the model
#on the form {..., (v,n,i), ...} where v is in V(essel), n is N(ode), and i is in P(ort)
#n and i are connected with a node n must have the port i for it to be in the set
#
set Nv := {v in V, n in N, i in P: 
            (n == hn && i == home_port[v]) || # force home node to be with home port of v aka o(v)
            (n == dn && i == dv) ||           # All vessels should have home node coupled with d(v)
            (n >= 1 && can_transport[v,cargo[n]] && port[n] == i) # If a vessel can transport the cargo of n then its port should be the node port
          };

#Av from the model
#In the form {..., (v,n,i,m,j), ...} where v is in V, n and m is in N and i and j is in P
#n and i are in the same way as in Nv, the same is true for m and j
set Av := {v in V, (v,n,i) in Nv, (v,m,j) in Nv: n != dn && m != hn};

#Loading nodes 1 to 7
set NP := {n in N: 1 <= n <= cargoes};
#unloading nodes 8 to 14
set ND := {n in N: n > cargoes};

#All Nv where n is in NP
set NPV := {v in V, n in NP, (v,n,i) in Nv};
#All Nv where n is in ND
set NDV := {v in V, n in ND, (v,n,i) in Nv};

var t {V, N} >= 0;  # When vessel v is at node n
var l {V, N} >= 0;  # Size of cargo for vessel v at node n

#In the form {..., (v,n,i,m,j), ...} where v is in V, n and m is in N and i and j is in P
#n and i are in the same way as in Nv, the same is true for m and j
var x {V, N, P, N, P} binary;   #whether ship v moves  directly from  node n to node m.
var y {C} binary;               #whether cargo is transported by the available vessel fleet.

# (1)
minimize Z:
    sum {v in V, (v,n,i,m,j) in Av: m <> dn} 
        x[v,n,i,m,j] * (travel_cost[v,i,j] + port_cost[v,m]) 
    + sum {c in NP} nt_cost[c] * y[c]
;

# (2)
# Each cargo is picked up or handled by spot charter
subject to all_cargo_handled {n in NP, i in {port[n]}}:
    sum {v in V, (v,n,i,m,j) in Av} x[v,n,i,m,j] + y[n] = 1;

# (3)
# All vessels move from home port to any other port (or D(v))
subject to vessels_move_from_home_port {v in V}:
    sum {(v,m,j) in Nv: m <> hn} x[v, hn,home_port[v], m, j] = 1;

# (4)
# If we go into a port we go out of it (minus home and destination port)
subject to connected_route {v in V, (v,n,i) in Nv: n >= 1}:
    sum {(v,n,i,m,j) in Av} x[v,n,i,m,j] - sum {(v,m,j,n,i) in Av} x[v,m,j,n,i] = 0;

# (5)
# All vessels moves to d(v) eventually
subject to arrive {v in V}:
    sum {(v,n,i) in Nv: n <> dn} x[v,n,i,dn,dv] = 1;

# (6)
subject to loading {v in V, (v,m,j) in NPV, (v,n,i,m,j) in Av: n >= 1}:
    l[v,n] + size[m] - l[v,m] <= capacity[v] * (1 - x[v,n,i,m,j]);

# (7)
subject to unloading {v in V, (v,m,j) in NPV, (v,n,i,cm,cj) in Av: n >= 1 && cm = m+cargoes}:
    l[v,n] - size[m] - l[v,cm] <= capacity[v] * (1 - x[v,n,i,cm,cj]);

# (8)
# The load onboard should be positive and less than capacity
subject to vessel_capacity {(v,n,i) in NPV}:
    0 <= l[v,n] <= capacity[v];

# (9)
# Arrive within the time window
subject to total_travel_time {v in V, (v,n,i,m,j) in Av: m <> dn}:
    t[v,n] + (travel_time[v,i,j] + port_time[v,m]) - t[v,m] 
        <= (upper_time[n] + (travel_time[v,i,j] + port_time[v,m])) * (1-x[v,n,i,m,j]);

# (10)
# You should visit loading and unloading with the same ship
subject to same_ship_loaded {v in V, (v,n,i) in NPV: n >= 1}:
    sum {(v,n,i,m,j) in Av} x[v,n,i,m,j] -
    sum {(v,n,i,m,j) in Av: 1 <= n <= cargoes} x[v,n+cargoes,port[n+cargoes],m,j] = 0;

# (11)
# Don't unload before you load
subject to load_order {v in V, (v,n,i) in NPV}:
    t[v,n] + (travel_time[v,i,port[n+cargoes]] + port_time[v, n + cargoes]) - t[v,n + cargoes] <= 0;

# (12)
# Arrive within the time window
subject to time_window_pickup {v in V, (v,n,i) in Nv}:
    lower_time[n] <= t[v, n] <= upper_time[n];


#Make sure we don't start using vessel v before 
# we are allowed to
subject to starting_time {v in V}:
    t[v,-1] = start_time[v];

#relative path to data file
data "oblig3-A/maa.dat";

solve;

#What vessels are we using freight shipping in
# display y;
#Whats our route (vessel, from node, to node)
# display {(v,n,i,m,j) in Av: x[v,n,i,m,j]} (v,n,m);

#Display times for each vessel at each node
# display {v in V, n in N} (v,n,t[v,n]);

#Display load for each vessel at each node
# display {v in V, n in N} (v,n,l[v,n]);