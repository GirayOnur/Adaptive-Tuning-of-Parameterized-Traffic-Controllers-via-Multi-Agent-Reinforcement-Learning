function [initialObservation, initialState] = rlResFuncDec

base_demands = load('base_demands.mat');

Demands.o1c1 = calc_noisy_demands('o1','c1',base_demands.base_demand_o1c1);
Demands.o1c2 = calc_noisy_demands('o1','c2',base_demands.base_demand_o1c2);
Demands.o2c1 = calc_noisy_demands('o2','c1',base_demands.base_demand_o2c1);
Demands.o2c2 = calc_noisy_demands('o2','c2',base_demands.base_demand_o2c2);
Demands.o3c1 = calc_noisy_demands('o3','c1',base_demands.base_demand_o3c1);
Demands.o3c2 = calc_noisy_demands('o3','c2',base_demands.base_demand_o3c2);

weather_cond = 1;
param_sim = param_get(weather_cond);
param_RL_low = param_RL_get(1);
param_RL_high = param_RL_get(0);
scenario = 3;

x=zeros(75,1);

N_init = 60;

u = [0.5;1;1];

k = 0;
for i=1:N_init

    if mod(k,param_RL_low.M) == 0
        x_prev = x;
    end

    if mod(k,param_RL_high.M) == 0
        dTau_prev = calc_dTau(x,param_sim);
    end    
    x = fun_benchmark_RM_nd(x,u,k,param_sim,scenario,Demands);
    k = k + 1;  
end

dTau = calc_dTau(x,param_sim);

xx = x;
uu = u;
kk = k;

x_norm_cen = calc_x_norm_cen();

demando1c1 = Demands.o1c1(kk+1);
demando1c2 = Demands.o1c2(kk+1);
demando2c1 = Demands.o2c1(kk+1);
demando2c2 = Demands.o2c2(kk+1);
demando3c1 = Demands.o3c1(kk+1);
demando3c2 = Demands.o3c2(kk+1);


initialState = [xx; uu; kk; scenario; dTau_prev; x_prev(33); x_prev(54)];

initialObservation = {[[demando1c1,demando1c2]';
                xx(64); xx(65);
                uu(1); dTau; dTau_prev; weather_cond]./[x_norm_cen(1:7);x_norm_cen(22)], ...
                [[demando2c1,demando2c2]';
                xx(68); xx(69); xx(33); x_prev(33); uu(2);weather_cond]./[x_norm_cen(8:14);x_norm_cen(22)] ...
                [[demando3c1,demando3c2]';
                xx(72); xx(73); xx(54); x_prev(54); uu(3); weather_cond]./[x_norm_cen(15:21);x_norm_cen(22)]};

end
