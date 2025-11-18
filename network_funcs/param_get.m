function param = param_get(cond)

param.T = 10/3600;
param.Q_o = 2000;
param.Q_o_main = 8000;
param.rho_max = 180;
param.L_m = 1000/1000;
param.kappa = 40;
param.delta = 0.0122;
param.nu = 60;
param.v_control_max = 200;
param.v_min = 7;
param.w_con = [200,100,100];
param.v_con_min = 20;

switch cond
    case 1
        param.rho_crit = 37.5;
        param.tau = 18/3600;
        
        param.a_m.c_1 = 1.8;
        param.a_m.c_2 = (1.867 - 0.66*param.a_m.c_1)/0.34;
        
        param.v_free.c_1 = 110; 
        param.v_free.c_2 = (102 - 0.66*param.v_free.c_1)/0.34;
        
        param.rho_crit_c_1 = 40;
        param.rho_crit_c_2 = (param.rho_crit - 0.66*param.rho_crit_c_1)/0.34;
    case 2
        param.rho_crit = 29.5;
        param.tau = 19.8/3600;
        
        param.a_m.c_1 = 1.8;
        param.a_m.c_2 = (1.867 - 0.66*param.a_m.c_1)/0.34;
        
        param.v_free.c_1 = 102; 
        param.v_free.c_2 = (92 - 0.66*param.v_free.c_1)/0.34;
        
        param.rho_crit_c_1 = 32;
        param.rho_crit_c_2 = (param.rho_crit - 0.66*param.rho_crit_c_1)/0.34;
    case 3
        param.rho_crit = 21.5;
        param.tau = 21.6/3600;
        
        param.a_m.c_1 = 1.8;
        param.a_m.c_2 = (1.867 - 0.66*param.a_m.c_1)/0.34;
        
        param.v_free.c_1 = 92; 
        param.v_free.c_2 = (81.6 - 0.66*param.v_free.c_1)/0.34;
        
        param.rho_crit_c_1 = 24;
        param.rho_crit_c_2 = (param.rho_crit - 0.66*param.rho_crit_c_1)/0.34;
end


param.lambda.l1 = 4;
param.lambda.l2 = 4;
param.lambda.l3 = 4;
param.lambda.l4 = 2;
param.lambda.l5 = 2;
param.lambda.l6 = 2;
param.lambda.l7 = 2;
param.lambda.l8 = 2;
param.lambda.l9 = 2;

end

