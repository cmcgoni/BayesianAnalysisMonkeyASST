Bayesian analysis for strategy detection in monkey attentional set shifting task
Overview:
This code was written to apply Bayesian inference to monkey attentional set shifting to detect latent strategies underlying stimulus selection and task performance. 
The general premise is to assess whether an animal is selecting choices that are consistent with a hypothesized strategy. The algorithm is set up to accumulate consecutive trials consistent with a given strategy and translate this consistent behavior into a readout of confidence that the given strategy is being used currently. 

Our approach is modeled after Wang et al., 2019, an approach echoed in De Falco et al., 2021. These approaches have been used with mice and rat attentional set shifting tasks, respectively.

The Bayesian equations have been optimized to capture features of the monkey task, namely to allow evidence accumulation toward a strategy to align with the performance metric of trials to criterion. In brief, the likelihood function (which functions as the learning rate) is defined by a sigmoidal function that: 1) allows for a small number (1-3) of consistent choices to be made in a row before significant evidence accumulation occurs; 2) plateaus at the same number of consecutive trials that would be required to pass a given phase of the task (trials to criterion).

Core files:
BayesianAnalysis contains the main script for this analysis. It is built on four separate functions:
getBayes - contains preprocessing work to produce a matrix with the identity of selected stimulus features (side, shape, and color in this case) by trials
getSigm - produces sigmoidal likelihood functions, calculated based on the number of consecutive trials where the same stimulus feature was selected
anaBayes - combines these likelihood values with priors to produce Bayesian posterior values on a trial-by-trial basis
pltBayes - plotting function

Functions marked with "shuffle" were used to generate control data where the temporal order of trials was randomized through a bootstrapping process