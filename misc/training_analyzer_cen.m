% Plot reward and initial Q-value histories for a centralized agent.

agent_mat = load("agent_2025-11-04 03_10_49.mat");

trainResults = agent_mat.trainResults;

episodeNum = size(trainResults.EpisodeIndex,1);

episodeAx = linspace(1,episodeNum,episodeNum);

plot(episodeAx,trainResults.AverageReward,'b')
hold on
plot(episodeAx,trainResults.EpisodeQ0,'k')
