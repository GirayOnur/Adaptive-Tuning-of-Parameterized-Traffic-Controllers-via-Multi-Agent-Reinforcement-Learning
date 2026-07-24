% Plot the exploration-noise decay over a complete training run.

tot_episode = 5000;
step_per_episode = 11;
tot_sampling_step = tot_episode*step_per_episode;

StandardDeviationDecayRate = 3e-5;
StandardDeviation = 0.30;

stddev_list = [];
for i=1:tot_sampling_step
    StandardDeviation = StandardDeviation.*(1 - StandardDeviationDecayRate);
    stddev_list(end+1) = StandardDeviation;
end

disp(StandardDeviation)

plot(stddev_list)
