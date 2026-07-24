% Plot reward and initial Q-value histories for one decentralized agent.

agent_ind = 1;
agent_mat = load("agents_2025-11-03 08_15_50.mat");

trainResults = agent_mat.trainResults;

episodeNum = size(trainResults.EpisodeIndex,1);

episodeAx = linspace(1,episodeNum,episodeNum);

plot(episodeAx,trainResults.AverageReward(:,agent_ind),'b')
hold on
plot(episodeAx,trainResults.EpisodeQ0(:,agent_ind),'k')
