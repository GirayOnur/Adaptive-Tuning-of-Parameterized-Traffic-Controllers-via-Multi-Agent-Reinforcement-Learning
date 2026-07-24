% Evaluate the fixed-parameter controllers over 100 demand-noise seeds.

TTS_list = nan(1,100);
cntr = 1;

for rngNum=1:100
    rng(rngNum)
    run run_benchmark_fixed_param_SR_RM.m
    TTS_list(cntr) = sum(TTS);
    cntr = cntr + 1;
end

disp(mean(TTS_list))
disp(std(TTS_list))

save("100_TTS_fix", "TTS_list");
