% Run one benchmark simulation with a centralized RL parameter tuner.

scenario = 3;
N = 2040;

param_sim = param_get(1);
param_RL_low = param_RL_get(1);
param_RL_high = param_RL_get(0);

x_norm_cen = calc_x_norm_cen();

x=zeros(75,1);
xx = zeros(size(x,1),N);
u = [0.5;1;1];
uu = zeros(size(u,1),N);
total_comp_time = 0;

% Build one filtered demand realization from the saved base profiles.
base_demands = load('base_demands.mat');

Demands.o1c1 = calc_noisy_demands('o1','c1',base_demands.base_demand_o1c1);
Demands.o1c2 = calc_noisy_demands('o1','c2',base_demands.base_demand_o1c2);
Demands.o2c1 = calc_noisy_demands('o2','c1',base_demands.base_demand_o2c1);
Demands.o2c2 = calc_noisy_demands('o2','c2',base_demands.base_demand_o2c2);
Demands.o3c1 = calc_noisy_demands('o3','c1',base_demands.base_demand_o3c1);
Demands.o3c2 = calc_noisy_demands('o3','c2',base_demands.base_demand_o3c2);



k = 0;
% Warm up the network before enabling feedback control.
for i=1:60
    if mod(k,param_RL_low.M) == 0
        x_prev = x;
    end

    if mod(k,param_RL_high.M) == 0
        dTau_prev = calc_dTau(x,param_sim);
    end  

    x = fun_benchmark_RM_nd(x,u,k,param_sim,scenario, Demands);
    k = k + 1;
end

dTau = calc_dTau(x,param_sim);

% The evaluation runner loads agent_mat before calling this script.
agent = agent_mat.agent;

u_DTA = u(1);
u_PI_ALINEA_1 = u(2);
u_PI_ALINEA_2  = u(3);
k_c = 0;

param_hist = zeros(8,N);
weather_cond = 1;

for i=1:N

    % Switch the traffic model when the weather condition changes.
    if k >= 1060
        weather_cond = 3;
    end
    param_sim = param_get(weather_cond);


    % The agent retunes both controllers once per RL interval.
    if mod(k_c,param_RL_low.M_RL) == 0
        demando1c1 = Demands.o1c1(k+1);
        demando1c2 = Demands.o1c2(k+1);
        demando2c1 = Demands.o2c1(k+1);
        demando2c2 = Demands.o2c2(k+1);
        demando3c1 = Demands.o3c1(k+1);
        demando3c2 = Demands.o3c2(k+1);

        
        agentObs = [[demando1c1,demando1c2]';
                x(64); x(65);
                u(1); dTau; dTau_prev;
                [demando2c1,demando2c2]';
                x(68); x(69); x(33); x_prev(33); u(2);
                [demando3c1,demando3c2]';
                x(72); x(73); x(54); x_prev(54); u(3);weather_cond]./x_norm_cen;
        tic
        rl_params = getAction(agent,agentObs);
        rl_params = rl_params{1}.*param_RL_low.action_scales;
        params_dta.KP = rl_params(1);
        params_dta.KI = rl_params(2);
        params_alinea_1.KP = rl_params(3);
        params_alinea_1.KI = rl_params(4);
        params_alinea_1.rho_c = rl_params(5);
        params_alinea_2.KP = rl_params(6);
        params_alinea_2.KI = rl_params(7);
        params_alinea_2.rho_c = rl_params(8);
        total_comp_time = total_comp_time + toc;
    end

    % Ramp meters and route guidance run at their own control rates.
    if mod(k_c,param_RL_low.M) == 0
        tic
        u_PI_ALINEA_1 = calc_u_alinea(x(33),u_PI_ALINEA_1,params_alinea_1,x_prev(33));
        u_PI_ALINEA_2 = calc_u_alinea(x(54),u_PI_ALINEA_2,params_alinea_2,x_prev(54));
        total_comp_time = total_comp_time + toc;
        x_prev = x;
    end
    if mod(k_c,param_RL_high.M) == 0
        dTau = calc_dTau(x,param_sim);
        tic
        u_DTA = calc_u_dta(u_DTA,params_dta,dTau,dTau_prev);
        total_comp_time = total_comp_time + toc;
        dTau_prev = dTau;
    end

    x = fun_benchmark_RM_nd(x,[u_DTA;u_PI_ALINEA_1;u_PI_ALINEA_2],k,param_sim,scenario, Demands);
    xx(:,i) = x;
    uu(:,i) = [u_DTA;u_PI_ALINEA_1;u_PI_ALINEA_2];
    param_hist(:,i) = rl_params;
    k = k+1;
    k_c = k_c + 1;
end

% Unpack the recorded state and calculate total time spent.
v_1_1_c1 = xx(1,:);
v_1_1_c2 = xx(2,:);
rho_1_1_c1 = xx(3,:);
rho_1_1_c2 = xx(4,:);
rho_1_1_tot = xx(5,:);
q_1_1_c1 = xx(6,:);
q_1_1_c2 = xx(7,:);

v_1_2_c1 = xx(8,:);
v_1_2_c2 = xx(9,:);
rho_1_2_c1 = xx(10,:);
rho_1_2_c2 = xx(11,:);
rho_1_2_tot = xx(12,:);
q_1_2_c1 = xx(13,:);
q_1_2_c2 = xx(14,:);

v_1_3_c1 = xx(15,:);
v_1_3_c2 = xx(16,:);
rho_1_3_c1 = xx(17,:);
rho_1_3_c2 = xx(18,:);
rho_1_3_tot = xx(19,:);
q_1_3_c1 = xx(20,:);
q_1_3_c2 = xx(21,:);

v_2_1_c1 = xx(22,:);
v_2_1_c2 = xx(23,:);
rho_2_1_c1 = xx(24,:);
rho_2_1_c2 = xx(25,:);
rho_2_1_tot = xx(26,:);
q_2_1_c1 = xx(27,:);
q_2_1_c2 = xx(28,:);

v_3_1_c1 = xx(29,:);
v_3_1_c2 = xx(30,:);
rho_3_1_c1 = xx(31,:);
rho_3_1_c2 = xx(32,:);
rho_3_1_tot = xx(33,:);
q_3_1_c1 = xx(34,:);
q_3_1_c2 = xx(35,:);

v_3_2_c1 = xx(36,:);
v_3_2_c2 = xx(37,:);
rho_3_2_c1 = xx(38,:);
rho_3_2_c2 = xx(39,:);
rho_3_2_tot = xx(40,:);
q_3_2_c1 = xx(41,:);
q_3_2_c2 = xx(42,:);

v_4_1_c1 = xx(43,:);
v_4_1_c2 = xx(44,:);
rho_4_1_c1 = xx(45,:);
rho_4_1_c2 = xx(46,:);
rho_4_1_tot = xx(47,:);
q_4_1_c1 = xx(48,:);
q_4_1_c2 = xx(49,:);

v_5_1_c1 = xx(50,:);
v_5_1_c2 = xx(51,:);
rho_5_1_c1 = xx(52,:);
rho_5_1_c2 = xx(53,:);
rho_5_1_tot = xx(54,:);
q_5_1_c1 = xx(55,:);
q_5_1_c2 = xx(56,:);

v_5_2_c1 = xx(57,:);
v_5_2_c2 = xx(58,:);
rho_5_2_c1 = xx(59,:);
rho_5_2_c2 = xx(60,:);
rho_5_2_tot = xx(61,:);
q_5_2_c1 = xx(62,:);
q_5_2_c2 = xx(63,:);

w_o_1_c1 = xx(64,:);
w_o_1_c2 = xx(65,:);
q_o_1_c1 = xx(66,:);
q_o_1_c2 = xx(67,:);

w_o_2_c1 = xx(68,:);
w_o_2_c2 = xx(69,:);
q_o_2_c1 = xx(70,:);
q_o_2_c2 = xx(71,:);

w_o_3_c1 = xx(72,:);
w_o_3_c2 = xx(73,:);
q_o_3_c1 = xx(74,:);
q_o_3_c2 = xx(75,:);

TTS=param_sim.T.*((rho_1_1_c1.*param_sim.lambda.l1 + rho_1_2_c1.*param_sim.lambda.l2 + rho_1_3_c1.*param_sim.lambda.l3...
    + rho_2_1_c1.*param_sim.lambda.l4 + rho_3_1_c1.*param_sim.lambda.l5 + rho_3_2_c1.*param_sim.lambda.l6...
    + rho_4_1_c1.*param_sim.lambda.l7 + rho_5_1_c1.*param_sim.lambda.l8 + rho_5_2_c1.*param_sim.lambda.l9).*param_sim.L_m+w_o_1_c1+w_o_2_c1+w_o_3_c1)...
+   param_sim.T.*((rho_1_1_c2.*param_sim.lambda.l1 + rho_1_2_c2.*param_sim.lambda.l2 + rho_1_3_c2.*param_sim.lambda.l3...
    + rho_2_1_c2.*param_sim.lambda.l4 + rho_3_1_c2.*param_sim.lambda.l5 + rho_3_2_c2.*param_sim.lambda.l6...
    + rho_4_1_c2.*param_sim.lambda.l7 + rho_5_1_c2.*param_sim.lambda.l8 + rho_5_2_c2.*param_sim.lambda.l9).*param_sim.L_m+w_o_1_c2+w_o_2_c2+w_o_3_c2);

Rho=[rho_5_2_tot;rho_5_1_tot;rho_4_1_tot;rho_3_2_tot;rho_3_1_tot;rho_2_1_tot;rho_1_3_tot;rho_1_2_tot;rho_1_1_tot];
