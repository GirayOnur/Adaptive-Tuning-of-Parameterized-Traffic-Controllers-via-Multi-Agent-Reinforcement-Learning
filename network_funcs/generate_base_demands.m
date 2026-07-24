% Generate and save the deterministic demand profiles used by simulations.

N_demand = 2102;
scenario = 3;

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
