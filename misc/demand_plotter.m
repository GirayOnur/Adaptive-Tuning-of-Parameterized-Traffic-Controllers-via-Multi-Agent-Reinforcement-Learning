% Plot the smoothed base demands used by the benchmark.

kf = 2040;
scenario = 3;

t = linspace(0,2040,2041).*10./3600;


base_demands = load('base_demands.mat');

Demands.o1c1 = base_demands.base_demand_o1c1;
Demands.o1c2 = base_demands.base_demand_o1c2;
Demands.o2c1 = base_demands.base_demand_o2c1;
Demands.o2c2 = base_demands.base_demand_o2c2;
Demands.o3c1 = base_demands.base_demand_o3c1;
Demands.o3c2 = base_demands.base_demand_o3c2;

[b,a] = butter(1,0.1);

demands = filtfilt(b,a,Demands.o1c1(62:2102));

plot(t,demands, 'Color', "#1171BE","LineWidth",2)
xlabel('Time [h]')
ylabel('Demand [veh/h]')
legend
hold on

demands = filtfilt(b,a,Demands.o2c1(62:2102));

plot(t,demands,'Color', "#3BAA32","LineWidth",2)



demands = filtfilt(b,a,Demands.o1c2(62:2102));

plot(t,demands,"LineWidth",2)

demands = filtfilt(b,a,Demands.o2c2(62:2102));

plot(t,demands,"LineWidth",2)
xlim([0 5.667])


xlabel('Time [h]')
ylabel('Demand [veh/h]')
legend
hold on

leg = legend('$O_{0,\mathrm{c}_1}$','$O_{1,\mathrm{c}_1},O_{2,\mathrm{c}_1}$','$O_{0,\mathrm{c}_2}$','$O_{1,\mathrm{c}_2},O_{2,\mathrm{c}_2}$');
set(leg,'Interpreter','latex');
set(leg,'FontSize',12);
