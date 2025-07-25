%% Source publication
%Wang J, Tait DS, Brown VJ, Bowman EM. Exacerbation of the credit 
% assignment problem in rats with lesions of the medial prefrontal 
% cortex is revealed by Bayesian analysis of behavior in the pre-solution 
% period of learning. Behav Brain Res. 2019;372. 
% doi:10.1016/j.bbr.2019.112037

%% Bayesian Overview: 
% The likelihoods at each trial are analyzed together with the prior 
% probabilities (using Bayes’ rule) to estimate the posterior probability 
% that the current choice is consistent with each hypothetical response 
% pattern using the equation: 
%Posterior(x) = likelihood(x) * prior(x)

% X         = each hypothetical pattern of behavior
%prior      = prior probability for the specific pattern
%likelihood = strength of evidence (how likely is the behavior you observed
%               under the hypothesized strategy)
%posterior  = how likely is the hypotheized strategy, given the evidence
%               from the current trial
%posterior probabilities are normalized so all posteriors sum to 1 and are
%used as priors for the following trial

%Intialization: at the beginning of each phase, priors and likelihoods are
%reset to a "hypothesis-neutral" value where each strategy is equal
%% Initial data import
clear all

path = uigetdir('/Users/user/');
files = dir(fullfile(path,'**','*.xlsx'));
names = {files.name};
for XX = 1:length(files);
    temp = readtable(fullfile('DataFiles\PostDrink', (num2str(names{XX}))),'ReadVariableNames',true);
    Subjects{XX} = temp;
end

%getBayes function handles data pre-processing (specific for our data input
%structure). 
%Each cell contains a single session's data arranged in columns: phase -
%side selected - dimension 1 selected - dimension 2 selected
%Each row is 1 trial

%input to getBayes: full data file for a single subject (x)
%output from getBayes are formatted single sessions (output) as well as the length
%in number of trials of each session (sz)
%% GetBayes preprocessing and loading after intiial import

for XZ = 1:length(Subjects)
    x = Subjects{1,XZ}; %previous step of unnesting the subject tables from the structure necessary for this step
    [outpt{XZ},sz{XZ},rewards{XZ},dates{XZ}] = getBayes(x); %generates nested cell array: array of subjects.array of individual sessions 
end
%%

%getSigm produces simgoidal likelihood values
%anaBayes calculates Bayesian posteriors (b-value) - this is the
%"probability" that an animal is following a given strategy
%posteriors are reset to 0.5 at the beginning of each phase
%(hypothesis-neutral) and accumulation above 0.6 (adjustable) indicates
%presence of strategy

%inputs to getSigm: subject number (XZ), each session for each subject (outpt), and
%session length (sz)
%outputs from  are session length (could probably replace with sz),
%likelihood values for each trial for spatial (SPlike), shape (SHlike), and
%color (COlike), and the trial number where each phase starts (Phases)

%inputs to anaBayes: all of the above (likelihood, phases, and total
%session length
%outputs from anaBayes: normalized posteriors, or b-values, for spatial
%(normSP), shape (normSH), and color (normCO) strategies'
%% Win-stay/shift work
% 
% test = cell2table(outpt{1,1}{1,1});        
% sess_win = categorical(test.Var5);
% spatial = categorical(test.Var2);
% %index win variable for "correct" trials
% 
%     for p = 1:(length(sess_win) - 1)
%         if sess_win(p) == "correct"
%             winstay(p) = spatial(p) == spatial(p+1);
%         end
%     end
%     for p = 1:(length(sess_win) - 1)
%         if sess_win(p) == "correct"
%             winlose(p) = spatial(p) ~= spatial(p+1);
%         end
%     end
%% Calculate sigmoidal likelihood and bayesian posteriors
% clear all;
% load ("ASSTpostdrink.mat");
load ("ASSTdata.mat");
% Note that we don't have post-drinking data for monkeys 14.3 and 17.11.
% "Stand in" data is being used, which is just copied data from the 14.2
% and 17.10 in order to keep matlab-assigned numbers consistent

for XZ = 1:length(outpt)
    [Sessionlength{XZ}, SPlike{XZ}, SPalike{XZ}, SHlike{XZ}, COlike{XZ}, Phases{XZ},trialsperphase{XZ}] = getSigm(outpt,sz,XZ,dates); %%%%%Put all four in competition together like in mouse%%%%%
    [normSP{XZ},normSPa{XZ}, normSH{XZ},normCO{XZ},propSP{XZ},propSPa{XZ},propSH{XZ},propCO{XZ},propNS{XZ}] = anaBayes(XZ, Sessionlength, SPlike, SPalike, SHlike, COlike, Phases,dates);
end

%inputs to pltBayes: posterior values (norm_), the trial number where each
%phase starts, and the number of sessions you wish to graph from each
%subject (numsess)
%% Animal classification
sex = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 1 1 0 0 0 0 1 1 0 0]; %0 = male; 1 = female
performance = [0 1 1 0 0 1 0 1 0 0 0 0 0 1 1 1 0 0 1 1 1 1 1 0 1 0 0 0 0 0 0 0 1 1 1 0 1 0 1 0 1 0 1 1 1 1 0 1]; %0 = HP, 1 = LP
drink = [4 NaN 3 1 2 3 NaN 4 2 4 NaN 3 1 4 1 1 1 2 2 4 2 1 3 2 2 3 4 1 1 3 2 3 3 2 1 1 1 1 3 1 1 1 4 4 1 4 1 4]; %1 = LD, 2 = BD, 3 = HD, 4 = VHD, NaN = control animal
%% Calculate average stage reached
for XX = 1:length(outpt)
    elementCounts = cellfun(@numel, Phases{1,XX}(1,end-9:end));  % Count elements in each cell; only using last ten sessions for pre-drinking data to avoid effects of training rate

    averageElements{XX} = mean(elementCounts);  % Calculate average
end
%% Calculate average stage by animal category

for i = 1:length(outpt)
    if drink(i) == 1
        temp(i) = averageElements{i}
    else
        temp(i) = NaN
    end
end
test = mean(temp, "omitnan")
%% Shuffled data work
for XZ = 1:length(outpt)
    [ShSpatial{XZ}, ShAltern{XZ}, ShShape{XZ}, ShColor{XZ}] = getSigm_shuffled(outpt,XZ,Phases, trialsperphase,Sessionlength);
    [ShSpPost{XZ}, ShSpaPost{XZ}, ShShPost{XZ}, ShCoPost{XZ},ci{XZ}] = anaBayes_shuffled(XZ, Sessionlength, ShSpatial, ShAltern, ShShape, ShColor, Phases);
end

%% Plotting function

for XZ = 1:length(outpt);
    %separate loops for graphing and analysis
    numsess = 1; %change this number to graph a different number of sessions
    session = 4; 
%   pltBayes_shuffled(normSP,normSH,normCO,Phases,XZ,numsess,ci);
    [strat{XZ}] = pltBayes(normSP,normSPa, normSH,normCO,Phases,XZ,numsess,sz,session,propSP,propSPa,propSH,propCO);
end
%% 
for i = 1:length(strat)
    figure(i);
    qqplot(strat{1,i});
end
%Need to find summary statistic for how normal a distribution is (like
%degree to which)
%%%%Just have bars showing the periods when the animals are using a
%%%%strategy instead of the noisiness of the trial by trial data

%% Shuffled plot function - plotting upper CI vs our 0.6 threshold
figure
hold on
for XZ = 1:length(Subjects)
    for i = 1:3;
        plot(ci{1,XZ}{1,i},'color',[.7 .7 .7]);
    end
end
yline(0.6,'-','color','r','LineWidth',3);
xlabel('trial');
ylabel('b-value');
ylim([0 1]);
%% Shuffle plot
plot(f,'displayname','shuffled');
hold on
plot(normCO{1,3}{1,2},'displayname','color');
plot(normSH{1,3}{1,2},'displayname','shape');
plot(normSP{1,3}{1,2},'displayname','spatial');
plot(normSPa{1,3}{1,2},'displayname','alternation');
hold off