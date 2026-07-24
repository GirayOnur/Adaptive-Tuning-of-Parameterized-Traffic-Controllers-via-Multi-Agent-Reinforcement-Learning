% Evaluate one decentralized agent set over 100 demand-noise seeds.

agents_ind_str = 'agents_2025-11-03 11_15_51.mat';
agents_mat = load(agents_ind_str);


TTS_list = nan(1,100);
cntr = 1;

for rngNum=1:100
    rng(rngNum)
    run run_benchmark_RL_dec_SR_RM.m
    TTS_list(cntr) = sum(TTS);
    cntr = cntr + 1;
end

disp(mean(TTS_list))
disp(std(TTS_list))

save("100_TTS_dec", "TTS_list");
