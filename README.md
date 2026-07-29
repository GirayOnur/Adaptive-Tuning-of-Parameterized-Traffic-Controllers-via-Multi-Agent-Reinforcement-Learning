# Adaptive Tuning of Parameterized Traffic Controllers via Multi-Agent Reinforcement Learning

This repository contains the MATLAB code for training and evaluating reinforcement learning agents that tune route guidance and ramp metering controllers in a freeway network. It includes decentralized multi-agent and centralized DDPG approaches, benchmark experiments, and pretrained agents.

## Requirements

- MATLAB
- Reinforcement Learning Toolbox
- Deep Learning Toolbox

## Getting started

Clone the repository and open MATLAB in the project folder. Add all folders to the MATLAB path:

```matlab
addpath(genpath(pwd));
```

To train the decentralized multi-agent controller:

```matlab
rngNum = 1;
N_demand = 2102;
run("rl_training_codes/train_multi_agent_RL.m")
```

To train the centralized controller:

```matlab
rngNum = 1;
N_demand = 2102;
run("rl_training_codes/train_single_agent_RL.m")
```

Pretrained agents are included in `10_multi_agent_frameworks` and `10_single_agent_frameworks`.

## Repository structure

- `rl_training_codes`: training entry points
- `rl_funcs`: agent definitions and environment functions
- `network_funcs`: traffic model and controller functions
- `experiments`: evaluation and benchmark scripts
- `misc`: plotting and analysis scripts
- `10_multi_agent_frameworks`: pretrained multi-agent models
- `10_single_agent_frameworks`: pretrained single-agent models
