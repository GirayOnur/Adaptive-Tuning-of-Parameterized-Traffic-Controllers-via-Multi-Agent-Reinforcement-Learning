

kf = 2040;
scenario = 3;

t = linspace(0,2040,2041).*10./3600;


base_demands = load('base_demands.mat');

Demands.o1c1 = calc_noisy_demands('o1','c1',base_demands.base_demand_o1c1);
Demands.o1c2 = calc_noisy_demands('o1','c2',base_demands.base_demand_o1c2);
Demands.o2c1 = calc_noisy_demands('o2','c1',base_demands.base_demand_o2c1);
Demands.o2c2 = calc_noisy_demands('o2','c2',base_demands.base_demand_o2c2);
Demands.o3c1 = calc_noisy_demands('o3','c1',base_demands.base_demand_o3c1);
Demands.o3c2 = calc_noisy_demands('o3','c2',base_demands.base_demand_o3c2);


demands = Demands.o1c1(62:2102) + Demands.o1c2(62:2102);

plot(t,demands)
title("Vehicle demand vs time")
xlabel('time [h]') 
ylabel('vehicle demand [veh/h]')

hold on

demands = Demands.o2c1(62:2102) + Demands.o2c2(62:2102);

plot(t,demands)