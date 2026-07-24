function RL_param = param_RL_get(is_low_level)
% Return controller timing, reward weights, and action scales.

if is_low_level == 1
    RL_param.Np = 10;
    RL_param.Nc = 10;
    RL_param.M = 6;
else
    RL_param.Np = 2;
    RL_param.Nc = 2;
    RL_param.M = 30;
end

RL_param.M_RL = 180;

RL_param.r_cost= 0.4;
RL_param.s_cost = 0.4;

RL_param.action_scales = [0.5;0.1;0.1;0.05;100;0.1;0.05;100];

end
