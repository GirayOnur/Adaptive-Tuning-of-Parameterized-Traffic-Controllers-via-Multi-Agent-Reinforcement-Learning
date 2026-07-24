% Prepare the network state and train the centralized DDPG agent.

rng(rngNum)

scenario = 3;
N = 2040;

base_demand_o1c1 = nan(1,N_demand);
base_demand_o1c2 = nan(1,N_demand);
base_demand_o2c1 = nan(1,N_demand);
base_demand_o2c2 = nan(1,N_demand);
base_demand_o3c1 = nan(1,N_demand);
base_demand_o3c2 = nan(1,N_demand);

for k = 1:N_demand
    [base_demand_o1c1(1,k),base_demand_o1c2(1,k)] = demando1(k-2, scenario);
    [base_demand_o2c1(1,k),base_demand_o2c2(1,k)] = demando2(k-2, scenario);
    [base_demand_o3c1(1,k),base_demand_o3c2(1,k)] = demando3(k-2, scenario);
end

save("base_demands",'base_demand_o1c1', 'base_demand_o1c2', 'base_demand_o2c1','base_demand_o2c2',...
    'base_demand_o3c1', 'base_demand_o3c2');

% Warm up the network and save a common initial state.
weather_cond = 1;
param_sim = param_get(weather_cond);
param_RL_low = param_RL_get(1);
param_RL_high = param_RL_get(0);

x=zeros(75,1);

N_init = 60;
xx_init = zeros(size(x,1),N_init);


xx = zeros(size(x,1),N);

u = [0.5;1;1];
uu = zeros(size(u,1),N);

k = 0;
for i=1:N_init

    if mod(k,param_RL_low.M) == 0
        x_prev = x;
    end

    if mod(k,param_RL_high.M) == 0
        dTau_prev = calc_dTau(x,param_sim);
    end    
    x = fun_benchmark_RM(x,u,k,param_sim,scenario);
    xx_init(:,i) = x;
    k = k + 1;  
end

dTau = calc_dTau(x,param_sim);

save("net_init", 'x', 'x_prev', 'u', 'scenario','k', 'x_prev','dTau', 'dTau_prev','weather_cond');
% Build the centralized environment and start training.
run const_RL_cen.m
