
agents_list = {'agents_2025-11-03 08_15_50.mat' ...
              'agents_2025-11-03 09_40_44.mat' ...
              'agents_2025-11-03 11_15_51.mat' ...
              'agents_2025-11-04 01_48_24.mat' ...
              'agents_2025-11-04 03_00_06.mat' ...
              'agents_2025-11-04 04_11_20.mat' ...
              'agents_2025-11-04 05_21_49.mat' ...
              'agents_2025-11-04 06_32_18.mat' ...
              'agents_2025-11-04 07_43_03.mat' ...
              'agents_2025-11-04 12_37_03.mat' ...
              };



TTS_list = nan(1,100); %10 is size of the agent_list
cntr = 1;

for ii=1:10
    for rngNum=1:10
    rng(rngNum)
        agents_ind_cell = agents_list(ii);
        agents_ind_str = agents_ind_cell{1};
        agents_mat = load(agents_ind_str);
        run run_benchmark_RL_dec_SR_RM.m
        TTS_list(cntr) = sum(TTS);
        cntr = cntr + 1;
    end
end

disp(mean(TTS_list))
disp(std(TTS_list))


save("10_TTS_dec", "TTS_list");
