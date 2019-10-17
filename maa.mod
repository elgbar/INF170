reset;
option solver "/home/elg/ampl/cplex";

param ports >= 1; #Number of ports 
param dv = ports + 1;

param cargoes >= 1;

set V;                              # Set of all vessels            (officially V)
set C;                              # Set of all cargoes            (official)
set N;                              # set of all nodes 
set P = 1..(ports+1);               # Set of all ports

# set N_P within {P};               # Set of loading nodes          (official)
# set N_D within {P};               # Set of destination nodes      (official)
# set N_V within {P, V};          
set PTC within {V, N};              # port times and costs
set A within {V, P, P};             # Travel time and cost          (officially A)
param can_transport {V, C} binary;      # if a given vessel can transport a given cargo

#Vessel params
param home_port {v in V} >= 0, <= ports;          # Home port
param start_time {V} >= 0;              # starting time
param capacity {V} >= 0;                # capacity

#Cargo params>
param origin_port {C} >= 0, <= ports;   # Origin port
param dest_port {C} >= 0, <= ports;     # Destination port
param size {C} >= 0;                    # Size
param nt_cost {C} >= 0;                    # Cost of not transporting (math: C)
param lower_pickup {C} >= 0;            # Lowerbound time window for pickup
param upper_pickup {C} >= 0;            # Upper time window for pickup
param lower_delivery {C} >= 0;          # Lowerbound time window for delivery
param upper_delivery {C} >= 0;          # Upper time window for delivery


param cargo {N} >= 1, <= 7;
    #make sure there are two cargoes for each
    check {n in C}: cargo[n] == cargo[n+cargoes];

param port {N} >= 1, <= ports;
    check {n in N}: port[n] == if(n <= cargoes) 
        then origin_port[cargo[n]] 
        else dest_port[cargo[n]];
    
param lower_time {N} >= 0;
    #make sure the correct lower time is set
    check {n in N}: lower_time[n] == if(n <= cargoes) then lower_pickup[cargo[n]] else lower_delivery[cargo[n]];
    

# display {v in V, c in C, npj in {origin_port[c]}, (v,i,npj) in A:
#             can_transport[v,c] && 

param upper_time {N} >= 0;
    check {n in N}: lower_time[n] <= upper_time[n] && 
                    upper_time[n] == if(n <= cargoes) then upper_pickup[cargo[n]] else upper_delivery[cargo[n]];


#port times and costs params
param port_time {PTC} >= 0;      #origin port time (in hours)
param port_cost {PTC} >= 0;     #origin port costs (in �)

#Travel time and cost params
param travel_time {A} >= 0;           #travel time (in hours)
param travel_cost {A} >= 0;           #travel cost (in �)

set NV := {v in V, i in P: (i == dv || i == home_port[v] || exists {n in N: can_transport[v,cargo[n]]} port[n] == i)};
set Av := {v in V, (v,i) in NV, (v,j) in NV: j <> home_port[v] && i <> dv};


var t {V, N} >= 0; #when vessel v is at node p 
var l {V, N} >= 0; #size of cargo for vessel v at node p

var x {P, P, V} binary;  #whether ship v moves  directly  from  node i to  node j.
var y {C} binary;        #whether cargo is transported by the available vessel fleet.

#(1)
minimize Z:
    sum {v in V, i in P, j in N:
        #all nodes we can come from (inc home port)
        (i == home_port[v] || exists {n in N: can_transport[v,cargo[n]]} port[n] == i) && 
        #All port we go to (exclude D(V) as it should not cost anything)
        can_transport[v,cargo[j]]
    } x[i,port[j],v] * (travel_cost[v,i,port[j]] + port_cost[v,j]) +
    sum {c in C} nt_cost[c] * y[c]
;

# (2)
# Each cargo is picked up or handled by spot charter
subject to all_cargo_handled {c in C, i in {port[c]}}:
    sum {v in V, j in P:
            can_transport[v,c] &&
            (j == dv || exists {n in N: can_transport[v,cargo[n]]} port[n] == j)
        }
    x[i,j,v] + y[c] = 1;

#(3)
#all vessels move from home port to any other port (or D(v))
subject to vessels_move_from_home_port {v in V}:
    sum {(v,j) in NV diff {(v,home_port[v])}} x[home_port[v], j, v] = 1;

#(4)
#if we go into a port we go out of it (minus home and destination port)
subject to connected_route {v in V, (v,i) in NV diff {(v,home_port[v]),(v,dv)}}:
    sum {(v,i,j) in Av} x[i,j,v] - sum {(v,j,i) in Av} x[j,i,v] = 0;

#(5)
#all vessels moves to d(v) eventually
subject to arrive {v in V}:
    sum {(v,i) in NV diff {(v,dv)}} x[i,dv,v] == 1;

#(6)
#prev port is i 
#we are at node j (loading port)
#remember how much cargo
#j = origin_port[c]
subject to loading
    {v in V, j in C, i in N:
        can_transport[v,cargo[i]] &&
        can_transport[v,j]
    }:
    l[v,i] + size[j] - l[v,j] <= capacity[v] * (1 - x[port[i],port[j],v]);

#(7)
subject to unloading 
    {v in V, j in C, i in N:
        can_transport[v,cargo[i]] &&
        can_transport[v,j] 
    }:
    l[v,i] - size[j] - l[v,j + cargoes] <= capacity[v] * (1 - x[port[i],port[j+cargoes],v]);

#(8)
#The load onboard should be positive and less than capacity
subject to vessel_capacity {v in V, i in C: can_transport[v,i]}:
    0 <= l[v,i] <= capacity[v];

#(9)
#t_iv when we are starting service
#
#Arrive within the time window
subject to total_travel_time 
        {v in V, i in N, j in N:
                can_transport[v,cargo[i]] &&
                can_transport[v,cargo[j]]
        }:
    t[v,i] + (travel_time[v,port[i],port[j]] + port_time[v,j]) - t[v,j] 
        <= (upper_time[i] + (travel_time[v,port[i],port[j]] + port_time[v,j])) * (1-x[port[i], port[j], v]);

#(10)
#you should visit loading and unloading with the same ship
subject to same_ship_loaded {v in V, c in C, i in {port[c]},npi in {port[c+cargoes]}: 
                can_transport[v, c]
            }:
    sum {(v,i  ,j) in Av} x[i  ,j,v] -
    sum {(v,npi,j) in Av} x[npi,j,v] = 0;

#(11)
#don't unload before you load
subject to load_order 
    {v in V, c in C, i in {port[c]}, npi in {port[c+cargoes]}: 
        can_transport[v,c]
    }:
    t[v,c] + (travel_time[v,i,npi] + port_time[v, c + cargoes]) - t[v,c + cargoes] <= 0;

#(12)
#arrive within the time window
subject to time_window_pickup {v in V, i in N: can_transport[v,cargo[i]]}:
    lower_time[i] <= t[v, i] <= upper_time[i];

#(13?)
#Make sure the start time for each vessel is at least at start time defined
subject to vessel_start_time {v in V, n in N: can_transport[v,cargo[n]]}:
    x[home_port[v], port[n], v] * start_time[v] <= t[v,n];

data "oblig3-A/maa.dat";

solve;

#What vessels are we using freight shipping in
display y;
#Whats our route
display {v in V, i in P, j in P: x[i,j,v]} (i,j,x[i,j,v]);



display {v in V, j in N} (sum {i in P:
        #all nodes we can come from (inc home port)
        (i == home_port[v] || exists {n in N: can_transport[v,cargo[n]]} port[n] == i) && 
        #All port we go to (exclude D(V) as it should not cost anything)
        can_transport[v,cargo[j]]
    } (x[i,port[j],v] * (travel_cost[v,i,port[j]] + port_cost[v,j])), t[v,j],l[v,j]);

display Av;

;
