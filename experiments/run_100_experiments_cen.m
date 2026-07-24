% Evaluate one centralized agent over 100 demand-noise seeds.

agent_ind_str = 'agent_2025-11-04 05_27_55.mat';
agent_mat = load(agent_ind_str);

TTS_list = nan(1,100);
cntr = 1;


for rngNum=1:100
    rng(rngNum)
    run run_benchmark_RL_cen_SR_RM.m
    TTS_list(cntr) = sum(TTS);
    cntr = cntr + 1;
end


disp(mean(TTS_list))
disp(std(TTS_list))

save("100_TTS_cen", "TTS_list");
