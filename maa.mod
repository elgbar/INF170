reset;
option solver "/home/elg/ampl/cplex";

param ports >= 1; #Number of ports 
param dv = ports + 1;

set V;                          # Set of all vessels            (officially V)
set C;                          # Set of all cargoes            (official)
set P = 1..(ports+1);               # Set of all nodes/ports

# set N_P within {P};             # Set of loading nodes          (official)
# set N_D within {P};             # Set of destination nodes      (official)
# set N_V within {P, V};          
set PTC within {V, C};          # port times and costs
set A within {V, P, P};       # Travel time and cost          (officially A)
param can_transport {V, C} binary;      # if a given vessel can transport a given cargo
    
# set N_P within {n in P} = origin_port[c];
# set N_V {v in V, c in C: origin_port[c] > 0} = origin_port[];

# set N_P within {P} = 

# set N_D_V = N_D inter N_V;
# set N_P_V = N_P inter N_V;

#Vessel params
param home_port {v in V} >= 0, <= ports;          # Home port
param start_time {V} >= 0;              # starting time
param capacity {V} >= 0;                # capacity

#Cargo params
param origin_port {C} >= 0, <= ports;   # Origin port
param dest_port {C} >= 0, <= ports;     # Destination port
param size {C} >= 0;                    # Size
param nt_cost {C} >= 0;                    # Cost of not transporting (math: C)
param lower_pickup {C} >= 0;   # Lowerbound time window for pickup
param upper_pickup {C} >= 0;        # Upper time window for pickup
param lower_delivery {C} >= 0;   # Lowerbound time window for delivery
param upper_delivery {C} >= 0;        # Upper time window for delivery


#port times and costs params
param origin_port_time {PTC} >= 0;      #origin port time (in hours)
param origin_port_costs {PTC} >= 0;     #origin port costs (in �)
param dest_port_time {PTC} >= 0;        #destination port time (in hours) 
param dest_port_cost {PTC} >= 0;        #destination port costs (in �)

#Travel time and cost params
param travel_time {A} >= 0;           #travel time (in hours)
param travel_cost {A} >= 0;           #travel cost (in �)

var t {V, P} integer;                        #when vessel v is at node p 
var l {V, P} integer; #size of cargo for vessel v at node p

var x {P, P, V} binary; #whether ship v moves  directly  from  node i to  node j.
var y {C} binary;       #whether cargo is transported by the available vessel fleet.

#(1)
minimize Z:
    sum {v in V, i in P, j in P: 
        (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == i || origin_port[ca] == i)) && #i should be in N_V and we can go from 
        (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j) || j==dv) #j should be in N_V or be dv
    }
    #it should cost nothing to go to dv
    (if j <> dv then travel_cost[v,i,j] else 0) * x[i,j,v] + sum {c in C} nt_cost[c]*y[c]
;

#O(v) == home_port[v]                   foreach v in V
#D(v) == 40                             foreach v in V (not 100% sure)

# (2)
# Each cargo is picked up or handled by spot charter
subject to all_cargo_handled {c in C}:
    sum {v in V, j in P:
            (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j)) #j should be in N_V
        }
    x[origin_port[c],j,v] + y[c] = 1;

#(3)
#all vessels move from home port to any other port (or D(v))
subject to vessels_move_from_home_port {v in V}:
    sum {j in P: 
            j == dv ||
            (home_port[v] <> j &&
            (exists {ca in C: can_transport[v,ca]} (origin_port[ca] == j || dest_port[ca] == j)))
        }
    x[home_port[v], j, v] = 1;

#(4)
#if we go into a port we go out of it (minus home and destination port)
subject to connected_route  
    {v in V, i in P: 
        i <> home_port[v] &&
        i <> dv &&
        (exists {ca in C: can_transport[v,ca]} (origin_port[ca] == i || dest_port[ca] == i))
    }:
    sum {j in P:
            i <> j && 
            (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j) || j==dv) #j should be in N_V or be dv
        }
    x[i,j,v] -
    sum {j in P:
            i <> j && 
            (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j) || j==dv) #j should be in N_V or be dv
        }
    x[i,j,v] = 0;

#(5)
#all vessels moves to d(v) eventually
#PTC will never contain dv as it is generated after the data
subject to arrive {v in V}:
    sum {i in P:
            dv <> i &&
            exists {ca in C: can_transport[v,ca]} (origin_port[ca] == i || dest_port[ca] == i)
        }
    x[i,dv,v] = 1;

#(6)
#prev port is i 
#we are at node j (loading port)
#remember how much cargo
#j = origin_port[c]
subject to load_onboard 
    {v in V, c in C, j in {origin_port[c]}, (v,i,j) in A:
        can_transport[v,c] && 
        (dest_port[c] == i || origin_port[c] == i) #i should be in N_V and we can go from
    }:
    l[v,i] + size[c] - l[v,j] <= capacity[v] * (1 - x[i,j,v]);

#(7)
#j = origin_port[c]
subject to unloading 
    {v in V, c in C, j in {dest_port[c]}, (v,i,j) in A:
        can_transport[v,c] && 
        (dest_port[c] == i || origin_port[c] == i) #i should be in N_V and we can go from
    }:
    l[v,i] - size[c] - l[v,j] <= capacity[v] * (1 - x[i,j,v]);

#(8)
#The load onboard should be positive and less than capacity
subject to vessel_capacity {v in V, (v,c) in PTC}:
    0 <= l[v,origin_port[c]] <= capacity[v];

#(9)
#t_iv when we are starting service
#
#Arrive within the time window
# subject to total_travel_time {v in V, (v,i,j) in A}:
#     t[v,i] + travel_time[v,i,j] - t[v,j] <= (upper_pickup[i] + travel_time[v,i,j]) * (1-x[i,j,v]);

#(10)
#you should visit loading and unloading with the same ship
subject to same_ship_loaded 
    {v in V, i in P: 
        exists {c in C: can_transport[v,c]} (origin_port[c] == i)
    }:
    sum {(v,i,j) in A:
            (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j) || j==dv) #j should be in N_V or be dv
        }
    x[i,j,v] - 

    sum {(v,i,j) in A:
            (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j)) #j should be in N_V or be dv
        }
    x[i,j,v] = 0;

#(11) 
#don't unload before you load
subject to load_order {v in V, c in C, i in {origin_port[c]}, ni in {dest_port[c]}: can_transport[v,c]}:
    t[v,i] + travel_time[v,i,ni] - t[v,ni] <= 0;

#(12)
#arrive within the time window
# subject to time_window {v in V, (v,c) in PTC}:
#     lower_pickup[c] <= t[v,i] <= upper_pickup[c];

# subject to time_window {v in V, (v,c) in PTC}:
#     lower_delivery[c] <= t[v,i] <= lower_delivery[c];

data "oblig3-A/maa.dat";

solve;
# display PTC;
# display N_V;

# display x;
display y;
# display {(v,c) in PTC: home_port[v] <> origin_port[c] && home_port[v] <> dest_port[c]} (home_port[v], origin_port[c], dest_port[c]);

# #N_P
# display {i in P: exists {c in C} origin_port[c] == i};

# #N_D
# display {i in P: exists {c in C} dest_port[c] == i};

# #N_V
display {v in V, i in P: 
            # #inc d(v) and o(v)
            # i == dv ||
            # i == home_port[v] ||

            # #exclude d(v) and o(v)
            # i <> dv &&
            # i <> home_port[v] &&

            # #including d(v) but not o(v)
            # i <> home_port[v] &&
            # (i == dv ||
            (exists {ca in C: can_transport[v,ca]} (origin_port[ca] == i || dest_port[ca] == i))
            # )
        };

# display {v in V, i in P:
#             (exists {ca in C: can_transport[v,ca]} (origin_port[ca] == i || dest_port[ca] == i))
#         };

# #N_P_V - all origin nodes a given vessel can be at
# display {v in V, i in P: exists {c in C: can_transport[v,c]} (origin_port[c] == i)};


# #N_D_V - all destination nodes a given vessel can be at
# display {v in V, i in P: exists {c in C: can_transport[v,c]} (dest_port[c] == i)};

# #A_v - all arch a given vessel can tranverse
# display {v in V, i in P, j in P:
#                 i <> j && 
#                 (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == i || origin_port[ca] == i)) && #i should be in N_V and we can go from 
#                 (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j) || j==dv) #j should be in N_V or be dv
#         } (v, i, j);

#check (3)
# display {v in V, (v,home_port[v],j) in A} (home_port[v],x[home_port[v],j,v]);


#(4?)
# display {v in V, (v,c) in PTC, j in {dest_port[c]}, (v,i,j) in A:
#             (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == i || origin_port[ca] == i))  #i should be in N_V and we can go from 
#             # (exists {ca in C: can_transport[v,ca]} (dest_port[ca] == j || origin_port[ca] == j) ||j==dv) #j should be in N_V or be dv
#         } (v,c,i,j);

# ;
#
