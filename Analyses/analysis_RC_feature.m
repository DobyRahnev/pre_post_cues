%---------------------------------------------
% analysis_RC_feature
% The code performs the feature-based reverse correlation (RC) analyses in
% Bang & Rahnev manuscript entitled "Stimulus expectations alters 
% decision criterion but not sensory signal in perceptual decision making." 
% It also creates all panels of Figure 5.
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
    subject_num
    
    subject = subject+1;
    load(['data/Results_s' num2str(subject_num)]);
    
    stim = [];
    resp = [];
    cue = [];
    stimAngle = [];
    cueBefore = [];
    
    for cueType=1:4
        for j=1:4
            stim(end+1:end+30) = p.data{cueType,j}.stim_orientation;
            resp(end+1:end+30) = p.data{cueType,j}.response;
            cue(end+1:end+30) = p.data{cueType,j}.cue_type;
            stimAngle(end+1:end+30,:) = p.data{cueType,j}.orientationAngle;
            cueBefore(end+1:end+30) = ones(1,30) * p.data{cueType,j}.cue_order;
        end
    end
    
    
    %% Filters: create filters for each type of trial
    filterLeftRight{1} = cue == 1 & cueBefore == 1; %pre cue, left cue
    filterLeftRight{2} = cue == 2 & cueBefore == 1; %pre cue, right cue
    filterLeftRight{3} = cue == 3 & cueBefore == 1; %pre cue, neutral cue
    filterLeftRight{4} = cue == 1 & cueBefore == 2; %post cue, left cue
    filterLeftRight{5} = cue == 2 & cueBefore == 2; %post cue, right cue
    filterLeftRight{6} = cue == 3 & cueBefore == 2; %post cue, neutral cue
    
    filterValidity{1} = cue==stim & cueBefore == 1; %pre cue, valid
    filterValidity{2} = (cue+stim==3) & cueBefore == 1; %pre cue, invalid
    filterValidity{3} = cue==stim & cueBefore == 2; %post cue, valid
    filterValidity{4} = (cue+stim==3) & cueBefore == 2; %post cue, invalid    

    
    %% Reverse correlation - use of stimuli by moving average
    % Select the range of orientations
    window = 10;
    bound = 45 - window/2;
    range = -bound:bound;
    
    % Perform regression for each orientation
    for angle=range
        
        % Find out how many gratings had orientation within the window
        stimInRange = stimAngle > (angle-window/2) & stimAngle < (angle+window/2);
        numStimInRange = sum(stimInRange,2);
        
        % All trials together (actual and optimal)
        betas = glmfit(numStimInRange, resp'-1, 'binomial', 'link', 'logit'); %resp'-1
        usageAllActual(subject,angle+range(end)+1) = betas(2);
        betas = glmfit(numStimInRange, stim'-1, 'binomial', 'link', 'logit');
        usageAllOptimal(subject,angle+range(end)+1) = betas(2);
        
        % Left/Right/Neutral x Pre/Post cues
        for cueType=1:6
            betas = glmfit(numStimInRange(filterLeftRight{cueType}), resp(filterLeftRight{cueType})'-1, 'binomial', 'link', 'logit');
            usage_byCueType(subject,cueType,angle+range(end)+1) = betas(2);
        end
        
        % Valid/Invalid x Pre/Post cues
        for cueType=1:4
            betas = glmfit(numStimInRange(filterValidity{cueType}), resp(filterValidity{cueType})'-1, 'binomial', 'link', 'logit');
            usage_byValidity(subject,cueType,angle+range(end)+1) = betas(2);
        end
    end
    
end

%% Fix extreme values
usage_byCueType(15,3,3) = (usage_byCueType(15,3,2) + usage_byCueType(15,3,4))/2;
usage_byCueType(3,6,73) = (2*usage_byCueType(3,6,72) + 1*usage_byCueType(3,6,75))/3;
usage_byCueType(3,6,74) = (1*usage_byCueType(3,6,72) + 2*usage_byCueType(3,6,75))/3;


%% Stats
% All trials
for sub=subjects
    slope(sub,:) = glmfit([1:length(range)]', usageAllActual(sub,:), 'normal');
end
[~, P_slope_actual_info_use, ~, stats] = ttest(slope(:,2))
[~, P_actualVSoptimal, ~, stats] = ttest(usageAllActual, usageAllOptimal);
valuesOfSignificantDifferenceAfterCorrection = range(P_actualVSoptimal*81<.05)
valuesOfNOSignificantDifferenceBeforeCorrection = range(P_actualVSoptimal>.05)

% Slopes for valid-invalid for pre and post
pre_effect = squeeze(usage_byValidity(:,1,:)-usage_byValidity(:,2,:));
post_effect = squeeze(usage_byValidity(:,3,:)-usage_byValidity(:,4,:));
for sub=subjects
    slope_pre(sub,:) = glmfit([1:length(range)]', pre_effect(sub,:), 'normal');
    slope_post(sub,:) = glmfit([1:length(range)]', post_effect(sub,:), 'normal');
end
[~, P_validity_effect_slope_for_pre, ~, stats] = ttest(slope_pre(:,2))
[~, P_validity_effect_slope_for_post, ~, stats] = ttest(slope_post(:,2))
[~, P_validity_effect_slope_for_pre_VS_post, ~, stats] = ttest(slope_post(:,2), slope_pre(:,2))


%% Plot figures
% FIGURE 5A: All trials together
figure
[l,p] = boundedline(range, mean(usageAllActual)', std(usageAllActual)'/sqrt(length(subjects)), '-b*', ...
    range, mean(usageAllOptimal)', std(usageAllOptimal)'/sqrt(length(subjects)), '-r*', 'alpha');
outlinebounds(l,p);
hold on
plot([range(1),range(end)]', [0,0]', 'k-', 'LineWidth', 2)
legend('actual information usage', 'optimal information usage')
xlabel('Orientation (degrees)')
ylabel('Beta value')

% FIGURE 5B: Left/Right/Neutral x Pre/Post cues
figure
plot(range, squeeze(mean(usage_byCueType)), 'LineWidth',3)
hold on
plot([range(1),range(end)]', [0,0]', 'k-', 'LineWidth', 2)
legend('pre left', 'pre right', 'pre neutral', 'post left', 'post right', 'post neutral')
xlabel('Orientation (degrees)')
ylabel('Beta value')

% FIGURE 5C: Valid/Invalid x Pre/Post cues
figure
plot(range, squeeze(mean(usage_byValidity)), 'LineWidth',3)
hold on
plot([range(1),range(end)]', [0,0]', 'k-', 'LineWidth', 2)
legend('pre valid', 'pre invalid', 'post valid', 'post invalid')
xlabel('Orientation (degrees)')
ylabel('Beta value')

% FIGURE 5D: Difference between valid and invalid cues for pre vs. post
figure
[l,p] = boundedline(range, mean(pre_effect)', std(pre_effect)'/sqrt(length(subjects)), '-b*', ...
    range, mean(post_effect)', std(post_effect)'/sqrt(length(subjects)), '-r*', 'alpha');
outlinebounds(l,p);
hold on
plot([range(1),range(end)], [0,0], 'k-')
legend('pre cue', 'post cue')
xlabel('Orientation (degrees)')
ylabel('Validity effect')