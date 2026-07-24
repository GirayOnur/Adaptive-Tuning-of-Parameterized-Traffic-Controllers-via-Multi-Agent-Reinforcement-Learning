function [nextObs,reward,isDone,nextState] = rlStepFuncCen(action,state)
% Apply one centralized tuning action over a complete RL interval.

param_RL_low = param_RL_get(1);
param_RL_high = param_RL_get(0);

weather_cond = 1;

M_RL = param_RL_low.M_RL;

% Unpack the persistent environment state.
x = state(1:75);
actions_prev = state(76:78);
k = state(79);
scenario = state(80);
dTau_prev = state(81);
rho_prev_1 = state(82); 
rho_prev_2 = state(83);

x_norm_cen = calc_x_norm_cen();

xx = zeros(75,M_RL);
uu = zeros(3,M_RL);

u_DTA = actions_prev(1);
u_PI_ALINEA_1 = actions_prev(2);
u_PI_ALINEA_2  = actions_prev(3);

% Convert normalized agent actions into controller parameters.
action = action.*param_RL_low.action_scales;
params_dta.KP = action(1);
params_dta.KI = action(2);
params_alinea_1.KP = action(3);
params_alinea_1.KI = action(4);
params_alinea_1.rho_c = action(5);
params_alinea_2.KP = action(6);
params_alinea_2.KI = action(7);
params_alinea_2.rho_c = action(8);

% Hold the tuning parameters fixed while the low-level controllers run.
for i=1:M_RL

    if (k >= 1060)
        weather_cond = 3;
    end

    param = param_get(weather_cond);

    if mod(k,param_RL_low.M) == 0
        u_PI_ALINEA_1 = calc_u_alinea(x(33),u_PI_ALINEA_1,params_alinea_1,rho_prev_1);
        u_PI_ALINEA_2 = calc_u_alinea(x(54),u_PI_ALINEA_2,params_alinea_2,rho_prev_2);
        x_prev = x;
    end

    if mod(k,param_RL_high.M) == 0
        dTau = calc_dTau(x,param);
        u_DTA = calc_u_dta(u_DTA,params_dta,dTau,dTau_prev);
        dTau_prev = dTau;
    end    
    u = [u_DTA;u_PI_ALINEA_1;u_PI_ALINEA_2];
    x = fun_benchmark_RM(x,u,k,param,scenario);
    xx(:,i) = x;
    uu(:,i) = [u_DTA;u_PI_ALINEA_1;u_PI_ALINEA_2];
    k = k + 1;
end

dTau = calc_dTau(x,param);
% Build the state and normalized observation for the next agent step.
if k <= 1060
    [demando1c1,demando1c2]  = demando1_1(k-1,scenario);
    [demando2c1,demando2c2]  = demando2_1(k-1,scenario);
    [demando3c1,demando3c2]  = demando3_1(k-1,scenario);
else
    [demando1c1,demando1c2]  = demando1_2(k-1,scenario);
    [demando2c1,demando2c2]  = demando2_2(k-1,scenario);
    [demando3c1,demando3c2]  = demando3_2(k-1,scenario);
end

nextState = [x; u; k; scenario; dTau_prev; x_prev(33); x_prev(54)];


nextObs = [[demando1c1,demando1c2]';
                x(64); x(65);
                u(1); dTau; dTau_prev;
                [demando2c1,demando2c2]';
                x(68); x(69); x(33); x_prev(33); u(2);
                [demando3c1,demando3c2]';
                x(72); x(73); x(54); x_prev(54); u(3); weather_cond]./x_norm_cen;

% Calculate network travel time and a penalty on abrupt control changes.
rho_1_1_c1 = xx(3,:);
rho_1_1_c2 = xx(4,:);

rho_1_2_c1 = xx(10,:);
rho_1_2_c2 = xx(11,:);

rho_1_3_c1 = xx(17,:);
rho_1_3_c2 = xx(18,:);

rho_2_1_c1 = xx(24,:);
rho_2_1_c2 = xx(25,:);

rho_3_1_c1 = xx(31,:);
rho_3_1_c2 = xx(32,:);

rho_3_2_c1 = xx(38,:);
rho_3_2_c2 = xx(39,:);

rho_4_1_c1 = xx(45,:);
rho_4_1_c2 = xx(46,:);

rho_5_1_c1 = xx(52,:);
rho_5_1_c2 = xx(53,:);

rho_5_2_c1 = xx(59,:);
rho_5_2_c2 = xx(60,:);

w_o_1_c1 = xx(64,:);
w_o_1_c2 = xx(65,:);

w_o_2_c1 = xx(68,:);
w_o_2_c2 = xx(69,:);

w_o_3_c1 = xx(72,:);
w_o_3_c2 = xx(73,:);

    u_pen  = sum(sum([param_RL_low.s_cost;param_RL_low.r_cost;param_RL_low.r_cost].*([actions_prev,uu(:,1:end-1)] - uu).^2)); 
    tts = sum(param.T.*((rho_1_1_c1.*param.lambda.l1 + rho_1_2_c1.*param.lambda.l2 + rho_1_3_c1.*param.lambda.l3...
    + rho_2_1_c1.*param.lambda.l4 + rho_3_1_c1.*param.lambda.l5 + rho_3_2_c1.*param.lambda.l6...
    + rho_4_1_c1.*param.lambda.l7 + rho_5_1_c1.*param.lambda.l8 + rho_5_2_c1.*param.lambda.l9).*param.L_m+w_o_1_c1+w_o_2_c1+w_o_3_c1)...
+   param.T.*((rho_1_1_c2.*param.lambda.l1 + rho_1_2_c2.*param.lambda.l2 + rho_1_3_c2.*param.lambda.l3...
    + rho_2_1_c2.*param.lambda.l4 + rho_3_1_c2.*param.lambda.l5 + rho_3_2_c2.*param.lambda.l6...
    + rho_4_1_c2.*param.lambda.l7 + rho_5_1_c2.*param.lambda.l8 + rho_5_2_c2.*param.lambda.l9).*param.L_m+w_o_1_c2+w_o_2_c2+w_o_3_c2));

    % Fixed divisors preserve the reward scale used during training.
    reward = -(tts./15 + u_pen./90)./200;

if k>2039
    isDone=true;
else
    isDone=false;
end

end

