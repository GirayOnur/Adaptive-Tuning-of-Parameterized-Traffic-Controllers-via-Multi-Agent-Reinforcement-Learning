% Build and train the centralized DDPG parameter-tuning agent.

% The action contains PI gains and two ALINEA target densities.
ObsInfo = rlNumericSpec([22 1]);
ObsInfo.Name = "RG states, RM1 states, RM2 states";
ObsInfo.Description = ['2x1 mainstream demand, 2x1 mainstream queue,' ...
    '1x1 previous split rate, 1x1 current travel time difference, 1x1 previous travel time difference' ...
    '2x1 on-ramp demand, 2x1 on-ramp queue,1x1 next link density, 1x1 prev. next link density' ...
    '1x1 previous ramp metering rate, weather condition'];

ActInfo = rlNumericSpec([8 1],"UpperLimit", [1;1;1;1;0.5;1;1;0.5], "LowerLimit", [0;0;0;0;0.15;0;0;0.15]);
ActInfo.Name = "Ramp metering rates";
% The critic processes observations and actions on separate input paths.
statePath = [featureInputLayer(prod(ObsInfo.Dimension),...
                'Normalization','none','Name','state')
                fullyConnectedLayer(256,'Name', 'fc1_state')];
            
actionPath = [featureInputLayer(prod(ActInfo.Dimension), ...
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
critic = rlQValueFunction(criticNetwork,ObsInfo,ActInfo);
% The actor maps normalized observations to bounded tuning parameters.
actorNet = [
    featureInputLayer(prod(ObsInfo.Dimension),'Normalization','none','Name','observation')
    fullyConnectedLayer(256,'Name','ActorFC1')
    reluLayer('Name','ActorRelu1')
    fullyConnectedLayer(256,'Name','ActorFC2')
    reluLayer('Name','ActorRelu2')
    fullyConnectedLayer(prod(ActInfo.Dimension),'Name','ActorFC4')
    tanhLayer('Name','ActorTanh1')
    scalingLayer('Scale',[0.5 0.5 0.5 0.5 0.175 0.5 0.5 0.175]','Bias',[0.5 0.5 0.5 0.5 0.325 0.5 0.5 0.325]')
    ];
actor  = rlContinuousDeterministicActor(actorNet,ObsInfo,ActInfo);

% Configure replay, target updates, optimizers, and exploration noise.
agent = rlDDPGAgent(actor,critic);
agent.AgentOptions.MiniBatchSize=64;
agent.AgentOptions.ExperienceBufferLength=10000;
agent.AgentOptions.TargetSmoothFactor=1e-2;
agent.AgentOptions.TargetUpdateFrequency=10;
agent.AgentOptions.DiscountFactor=0.99;
agent.AgentOptions.NumStepsToLookAhead=10;
agent.AgentOptions.ActorOptimizerOptions.LearnRate=0.001;
agent.AgentOptions.ActorOptimizerOptions.GradientThreshold=1;
agent.AgentOptions.CriticOptimizerOptions.LearnRate=0.001;
agent.AgentOptions.CriticOptimizerOptions.GradientThreshold=1;
agent.AgentOptions.NoiseOptions.StandardDeviation=0.30;
agent.AgentOptions.NoiseOptions.StandardDeviationDecayRate=5e-5;


StepHandle = @(Action,Info) rlStepFuncCen(Action, Info);
ResetHandle = @() rlResFuncCen;

env = rlFunctionEnv(ObsInfo,ActInfo,StepHandle,ResetHandle);

% Save periodic checkpoints without opening the training plot.
opt = rlTrainingOptions('MaxEpisodes',5000,...
                                          'MaxStepsPerEpisode',11,'UseParallel',false,...
                                          'SaveAgentCriteria','EpisodeFrequency',...
                                          'SaveAgentValue',500, 'SaveAgentDirectory', pwd + "\runCen\AgentsCen" + num2str(rngNum), 'Plots',"none");

trainResults = train(agent,env,opt);

% Keep the trained policy and its learning history together.
agent_doc_name = 'agent_' + string(datetime('now'), 'yyyy-MM-dd hh_mm_ss') + '.mat';
save(agent_doc_name, "agent","trainResults")

% Close a pool if training created one.
delete(gcp("nocreate"));
