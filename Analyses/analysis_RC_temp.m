%---------------------------------------------
% analysis_RC_temp
% The code performs the temporal reverse correlation (RC) analyses in
% Bang & Rahnev manuscript entitled "Stimulus expectation alters 
% decision criterion but not sensory signal in perceptual decision making." 
% It also creates all panels of Figure 4.
%
% Written by Doby Rahnev. Last update: 10/13/2017
%---------------------------------------------

clc
close all
clear

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Select subjects
subjects = 1:30;
subject = 0;

% Loop over all subjects
for subject_num=subjects  
    subject = subject+1;
    load(['data/Results_s' num2str(subject_num)]);
    
    stim = [];
    resp = [];
    cue = [];
    stimAngle = [];
    cueBefore = [];
    
    for i=1:4
        for frame=1:4
            stim(end+1:end+30) = p.data{i,frame}.stim_orientation;
            resp(end+1:end+30) = p.data{i,frame}.response;
            cue(end+1:end+30) = p.data{i,frame}.cue_type;
            stimAngle(end+1:end+30,:) = p.data{i,frame}.orientationAngle /180 * pi; % in radians
            cueBefore(end+1:end+30) = ones(1,30) * p.data{i,frame}.cue_order;
        end
    end
    
    
    %% Filters: create filters for each type of trial
    filterPred{1} = cue < 3 & cueBefore == 1; %pre, predictive
    filterPred{2} = cue == 3 & cueBefore == 1; %pre, neutral
    filterPred{3} = cue < 3 & cueBefore == 2; %post, predictive
    filterPred{4} = cue == 3 & cueBefore == 2; %post, neutral
    
    filterValidity{1} = cue==stim & cueBefore == 1; %pre cue, valid
    filterValidity{2} = (cue+stim==3) & cueBefore == 1; %pre cue, invalid
    filterValidity{3} = cue==stim & cueBefore == 2; %post cue, valid
    filterValidity{4} = (cue+stim==3) & cueBefore == 2; %post cue, invalid    

    
    %% Temporal Reverse Correlation (RC) analysis
    % All trials
    for frame=1:30
        
        % All trials together (actual and optimal)
        betas = glmfit(stimAngle(:,frame), resp'-1, 'binomial', 'link', 'probit');
        usageAllActual(subject,frame) = betas(2,:);
        betas = glmfit(stimAngle(:,frame), stim'-1, 'binomial', 'link', 'probit');
        usageAllOptimal(subject,frame) = betas(2,:);
        
        % Predictive/Neutral x Pre/Post cues
        for cueType=1:4
            betas = glmfit(stimAngle(filterPred{cueType},frame), resp(filterPred{cueType})'-1, 'binomial', 'link', 'logit');
            usage_byPredictiveness(subject,cueType,frame) = betas(2);
        end
    end    
end

%% Stats
% Last two frames
average_beta_first_28_trials = mean(mean(usageAllActual(:,1:28)))
betas_29th_and_30th_trials = mean(usageAllActual(:,[29,30]))
[~, P_trial29_vs_trials1_28, ~, stats] = ttest(usageAllActual(:,29), mean(usageAllActual(:,1:28),2))
[~, P_trial30_vs_trials1_28, ~, stats] = ttest(usageAllActual(:,30), mean(usageAllActual(:,1:28),2))

% Optimality
[~, P_actual_VS_optimal, ~, stats] = ttest(usageAllActual, usageAllOptimal)

% Neutral vs. Predictive cues
meanUsage = mean(usage_byPredictiveness,3);
meanUsage_neutral = mean((meanUsage(:,2)+meanUsage(:,4))/2)
meanUsage_predictive = mean((meanUsage(:,1)+meanUsage(:,3))/2)
[~, P_pred_vs_neutr, ~, stats] = ttest(meanUsage(:,2)+meanUsage(:,4), meanUsage(:,1)+meanUsage(:,3))


%% Apply smoothing
for frame=1:30
    endFrame = frame + 1; 
    if endFrame > 30; endFrame = 30; end % Fix end frame for last frame
    
    % Apply smoothing
    usageAllActualSmooth(:,frame) = mean(usageAllActual(:,frame:endFrame),2);
    usageAllOptimalSmooth(:,frame) = mean(usageAllOptimal(:,frame:endFrame),2);
    for cueType=1:4
        usage_byPredictivenessSmooth(:,cueType,frame) = mean(usage_byPredictiveness(:,cueType,frame:endFrame),3);
    end
end


%% Plot figures
% FIGURE 4A: All trials together
figure
[l,p] = boundedline(1:30, mean(usageAllActualSmooth)', std(usageAllActualSmooth)'/sqrt(length(subjects)), '-b*', ...
    1:30, mean(usageAllOptimalSmooth)', std(usageAllOptimalSmooth)'/sqrt(length(subjects)), '-r*', 'alpha');
outlinebounds(l,p);
legend('actual information usage', 'optimal information usage')
xlabel('Frame number')
ylabel('Beta value')

% FIGURE 4B: Predictive/Neutral x Pre/Post cues
figure
plot(1:30, squeeze(mean(usage_byPredictivenessSmooth)), 'LineWidth',3)
legend('pre predictive', 'pre neutral', 'post predictive', 'post neutral')
xlabel('Frame number')
ylabel('Beta value')