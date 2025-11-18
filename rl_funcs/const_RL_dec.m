
%Constructs decentralized MARL components:
%RL Algorithm: DDPG

%1st agent
ObsInfo1 = rlNumericSpec([8 1]);
ObsInfo1.Name = "PI-DTA RL tuner states";
ObsInfo1.Description = ['2x1 mainstream demand, 2x1 mainstream queue,' ...
    '1x1 previous split rate, 1x1 current travel time difference, 1x1 previous travel time difference,1x1 weather condition'];


ActInfo1 = rlNumericSpec([2 1],"UpperLimit", ones(2,1), "LowerLimit", zeros(2,1));
ActInfo1.Name = "PI-DTA Parameters [Kp,Ki]";

%2nd agent
ObsInfo2 = rlNumericSpec([8 1]);
ObsInfo2.Name = "PI-ALINEA RL tuner states";
ObsInfo2.Description = ['2x1 on-ramp demand, 2x1 on-ramp queue,1x1 next link density, 1x1 prev. next link density,1x1 weather condition' ...
    '1x1 previous ramp metering rate'];


ActInfo2 = rlNumericSpec([3 1],"UpperLimit", [1;1;0.5], "LowerLimit", [0;0;0.15]);
ActInfo2.Name = "ALINEA Parameters [KP,KR,operation density]";

%3rd agent
ObsInfo3 = rlNumericSpec([8 1]);
ObsInfo3.Name = "PI-ALINEA RL tuner states";
ObsInfo3.Description = ['2x1 on-ramp demand, 2x1 on-ramp queue,1x1 next link density, 1x1 prev. next link density,1x1 weather condition' ...
    '1x1 previous ramp metering rate'];


ActInfo3 = rlNumericSpec([3 1],"UpperLimit", [1;1;0.5], "LowerLimit", [0;0;0.15]);
ActInfo3.Name = "PI-ALINEA Parameters [KP,KR,operation density]";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1st Agent

statePath = [featureInputLayer(prod(ObsInfo1.Dimension),...
                'Normalization','none','Name','state')
                fullyConnectedLayer(256,'Name', 'fc1_state')];
            
actionPath = [featureInputLayer(prod(ActInfo1.Dimension), ...
    'Normalization','none','Name','action')
    fullyConnectedLayer(128,"Name",'fc_2_action')];


commonPath = [concatenationLayer(1,2,'Name','concat')
              reluLayer('Name','reLu')
              fullyConnectedLayer(256, ...
                'Name','StateValue')
                reluLayer('Name', 'relu_body')
                fullyConnectedLayer(128, 'Name','fc_body')
                reluLayer('Name','relu_body2')
                fullyConnectedLayer(1,'Name','output')];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = addLayers(criticNetwork, commonPath);
criticNetwork = connectLayers(criticNetwork, 'fc1_state','concat/in1');
criticNetwork = connectLayers(criticNetwork, 'fc_2_action','concat/in2');
critic = rlQValueFunction(criticNetwork,ObsInfo1,ActInfo1);


actorNet = [
    featureInputLayer(prod(ObsInfo1.Dimension),'Normalization','none','Name','observation')
    fullyConnectedLayer(256,'Name','ActorFC1')
    reluLayer('Name','ActorRelu1')
    fullyConnectedLayer(256,'Name','ActorFC2')
    reluLayer('Name','ActorRelu2')
%     fullyConnectedLayer(64,'Name','ActorFC3')
%     reluLayer('Name','ActorRelu3')
    fullyConnectedLayer(prod(ActInfo1.Dimension),'Name','ActorFC4')
    tanhLayer('Name','ActorTanh1')
    scalingLayer('Scale',[0.5 0.5]','Bias',[0.5 0.5]')
    ];
actor  = rlContinuousDeterministicActor(actorNet,ObsInfo1,ActInfo1);

%activate GPU training:
%critic.UseDevice = "gpu";
%actor.UseDevice = "gpu";

%consider parametrizing the learning parameters since they depend on
%RL_param.M_RL and RL_param.M
agent1 = rlDDPGAgent(actor,critic);
agent1.AgentOptions.MiniBatchSize=64; %10; %RL horizon
agent1.AgentOptions.ExperienceBufferLength=10000; %100; %Single scenario length, 10*mini batch size
agent1.AgentOptions.TargetSmoothFactor=1e-2;
agent1.AgentOptions.TargetUpdateFrequency=10; %5; %Previously it was 10
agent1.AgentOptions.DiscountFactor=0.99;
agent1.AgentOptions.NumStepsToLookAhead=10; %5; %RL control step
%agent.AgentOptions.LearningFrequency=10; %RL control step, keeps the RL actions optimal by ensuring the agent is stationary during an episode
%agent.AgentOptions.NumWarmStartSteps=512; %Selected as the mini batch size, which is the possible minimum value
agent1.AgentOptions.ActorOptimizerOptions.LearnRate=0.001;
agent1.AgentOptions.ActorOptimizerOptions.GradientThreshold=1;
agent1.AgentOptions.CriticOptimizerOptions.LearnRate=0.001;
agent1.AgentOptions.CriticOptimizerOptions.GradientThreshold=1;
agent1.AgentOptions.NoiseOptions.StandardDeviation=0.30;
agent1.AgentOptions.NoiseOptions.StandardDeviationDecayRate=5e-5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2nd Agent

statePath = [featureInputLayer(prod(ObsInfo2.Dimension),...
                'Normalization','none','Name','state')
                fullyConnectedLayer(256,'Name', 'fc1_state')];
            
actionPath = [featureInputLayer(prod(ActInfo2.Dimension), ...
    'Normalization','none','Name','action')
    fullyConnectedLayer(128,"Name",'fc_2_action')];


commonPath = [concatenationLayer(1,2,'Name','concat')
              reluLayer('Name','reLu')
              fullyConnectedLayer(256, ...
                'Name','StateValue')
                reluLayer('Name', 'relu_body')
                fullyConnectedLayer(128, 'Name','fc_body')
                reluLayer('Name','relu_body2')
                fullyConnectedLayer(1,'Name','output')];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = addLayers(criticNetwork, commonPath);
criticNetwork = connectLayers(criticNetwork, 'fc1_state','concat/in1');
criticNetwork = connectLayers(criticNetwork, 'fc_2_action','concat/in2');
critic = rlQValueFunction(criticNetwork,ObsInfo2,ActInfo2);


actorNet = [
    featureInputLayer(prod(ObsInfo2.Dimension),'Normalization','none','Name','observation')
    fullyConnectedLayer(256,'Name','ActorFC1')
    reluLayer('Name','ActorRelu1')
    fullyConnectedLayer(256,'Name','ActorFC2')
    reluLayer('Name','ActorRelu2')
%     fullyConnectedLayer(64,'Name','ActorFC3')
%     reluLayer('Name','ActorRelu3')
    fullyConnectedLayer(prod(ActInfo2.Dimension),'Name','ActorFC4')
    tanhLayer('Name','ActorTanh1')
    scalingLayer('Scale',[0.5 0.5 0.175]','Bias',[0.5 0.5 0.325]')
    ];
actor  = rlContinuousDeterministicActor(actorNet,ObsInfo2,ActInfo2);

%activate GPU training:
%critic.UseDevice = "gpu";
%actor.UseDevice = "gpu";

%consider parametrizing the learning parameters since they depend on
%RL_param.M_RL and RL_param.M
agent2 = rlDDPGAgent(actor,critic);
agent2.AgentOptions.MiniBatchSize=64; %10; %RL horizon
agent2.AgentOptions.ExperienceBufferLength=10000; %100; %Single scenario length, 10*mini batch size
agent2.AgentOptions.TargetSmoothFactor=1e-2;
agent2.AgentOptions.TargetUpdateFrequency=10; %5; %Previously it was 10
agent2.AgentOptions.DiscountFactor=0.99;
agent2.AgentOptions.NumStepsToLookAhead=10; %5; %RL control step
%agent.AgentOptions.LearningFrequency=10; %RL control step, keeps the RL actions optimal by ensuring the agent is stationary during an episode
%agent.AgentOptions.NumWarmStartSteps=512; %Selected as the mini batch size, which is the possible minimum value
agent2.AgentOptions.ActorOptimizerOptions.LearnRate=0.001;
agent2.AgentOptions.ActorOptimizerOptions.GradientThreshold=1;
agent2.AgentOptions.CriticOptimizerOptions.LearnRate=0.001;
agent2.AgentOptions.CriticOptimizerOptions.GradientThreshold=1;
agent2.AgentOptions.NoiseOptions.StandardDeviation=0.30;
agent2.AgentOptions.NoiseOptions.StandardDeviationDecayRate=5e-5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3rd Agent

statePath = [featureInputLayer(prod(ObsInfo3.Dimension),...
                'Normalization','none','Name','state')
                fullyConnectedLayer(256,'Name', 'fc1_state')];
            
actionPath = [featureInputLayer(prod(ActInfo3.Dimension), ...
    'Normalization','none','Name','action')
    fullyConnectedLayer(128,"Name",'fc_2_action')];


commonPath = [concatenationLayer(1,2,'Name','concat')
              reluLayer('Name','reLu')
              fullyConnectedLayer(256, ...
                'Name','StateValue')
                reluLayer('Name', 'relu_body')
                fullyConnectedLayer(128, 'Name','fc_body')
                reluLayer('Name','relu_body2')
                fullyConnectedLayer(1,'Name','output')];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = addLayers(criticNetwork, commonPath);
criticNetwork = connectLayers(criticNetwork, 'fc1_state','concat/in1');
criticNetwork = connectLayers(criticNetwork, 'fc_2_action','concat/in2');
critic = rlQValueFunction(criticNetwork,ObsInfo3,ActInfo3);


actorNet = [
    featureInputLayer(prod(ObsInfo3.Dimension),'Normalization','none','Name','observation')
    fullyConnectedLayer(256,'Name','ActorFC1')
    reluLayer('Name','ActorRelu1')
    fullyConnectedLayer(256,'Name','ActorFC2')
    reluLayer('Name','ActorRelu2')
%     fullyConnectedLayer(64,'Name','ActorFC3')
%     reluLayer('Name','ActorRelu3')
    fullyConnectedLayer(prod(ActInfo3.Dimension),'Name','ActorFC4')
    tanhLayer('Name','ActorTanh1')
    scalingLayer('Scale',[0.5 0.5 0.175]','Bias',[0.5 0.5 0.325]')
    ];
actor  = rlContinuousDeterministicActor(actorNet,ObsInfo3,ActInfo3);

%activate GPU training:
%critic.UseDevice = "gpu";
%actor.UseDevice = "gpu";

%consider parametrizing the learning parameters since they depend on
%RL_param.M_RL and RL_param.M
agent3 = rlDDPGAgent(actor,critic);
agent3.AgentOptions.MiniBatchSize=64; %10; %RL horizon
agent3.AgentOptions.ExperienceBufferLength=10000; %100; %Single scenario length, 10*mini batch size
agent3.AgentOptions.TargetSmoothFactor=1e-2;
agent3.AgentOptions.TargetUpdateFrequency=10; %5; %Previously it was 10
agent3.AgentOptions.DiscountFactor=0.99;
agent3.AgentOptions.NumStepsToLookAhead=10; %5; %RL control step
%agent.AgentOptions.LearningFrequency=10; %RL control step, keeps the RL actions optimal by ensuring the agent is stationary during an episode
%agent.AgentOptions.NumWarmStartSteps=512; %Selected as the mini batch size, which is the possible minimum value
agent3.AgentOptions.ActorOptimizerOptions.LearnRate=0.001;
agent3.AgentOptions.ActorOptimizerOptions.GradientThreshold=1;
agent3.AgentOptions.CriticOptimizerOptions.LearnRate=0.001;
agent3.AgentOptions.CriticOptimizerOptions.GradientThreshold=1;
agent3.AgentOptions.NoiseOptions.StandardDeviation=0.30;
agent3.AgentOptions.NoiseOptions.StandardDeviationDecayRate=5e-5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ObsInfo = {ObsInfo1,ObsInfo2,ObsInfo3};
ActInfo = {ActInfo1,ActInfo2,ActInfo3};


StepHandle = @(Action,Info) rlStepFuncDec(Action, Info);
ResetHandle = @() rlResFuncDec;

env = rlMultiAgentFunctionEnv(ObsInfo,ActInfo,StepHandle,ResetHandle);

%activate parallel pools using GPUs
%availableGPUs = gpuDeviceCount("available");
%parpool("Processes",availableGPUs);


% opt = rlTrainingOptions('MaxEpisodes',3500,... %previously it was 3000 episodes
%                                          'MaxStepsPerEpisode',150,'UseParallel',true,... %previously maxsteps was 150 for 900 sim steps
%                                          'SaveAgentCriteria','EpisodeFrequency',...
%                                          'SaveAgentValue',50, 'SaveAgentDirectory', pwd + "\run\Agents", 'Plots',"none");
%                                          'MaxStepsPerEpisode',150,'UseParallel',false,'SaveAgentCriteria','AverageReward','SaveAgentValue',-1300);%,...
%                                          'StopTrainingCriteria','AverageReward',...
%                                          'StopTrainingValue',-1200,...
%                                          'UseParallel',false,...
%                                          'SaveAgentCriteria','AverageReward',...
%                                          'SaveAgentValue',-1200);

opt = rlMultiAgentTrainingOptions(...
    AgentGroups="auto",...
    LearningStrategy="decentralized",...
    MaxEpisodes=5000,...
    MaxStepsPerEpisode=11,...
    SaveAgentCriteria="EpisodeFrequency",...
    SaveAgentValue=500, SaveAgentDirectory = pwd + "\runDec\AgentsDec" + num2str(rngNum),...
    Plots= "none");

%opt.ParallelizationOptions.Mode = "async";

%%%%%%%%%%%

trainResults = train([agent1,agent2,agent3],env,opt);

agent_doc_name = 'agents_' + string(datetime('now'), 'yyyy-MM-dd hh_mm_ss') + '.mat';
save(agent_doc_name, "agent1","agent2","agent3","trainResults")

%terminate parallel pools
delete(gcp("nocreate"));