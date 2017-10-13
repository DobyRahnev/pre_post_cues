%---------------------------------------------
% model_figure6
% The code simulates the model of how the cues affects subjects' choices in
% Bang & Rahnev manuscript entitled "Stimulus expectations alters 
% decision criterion but not sensory signal in perceptual decision making." 
% It also creates panels B-D of Figure 6.
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

% Select subjects(subjects excluded due to too many extreme beta values:
% S3, S6, S7, S15)
subjects = [1,2,4,5,8:14,16:30];
subject = 0;

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
    
    
    %% Create model responses
    criteria = [4, -4, 0, 6, -6, 0]; %left pre, right pre, neutral pre; left post, right post, neutral post
    condition = 3*(cueBefore-1) + cue; %conditions 1-6 as above
    resp_model = 1 + (mean(stimAngle,2)' > criteria(condition));

    
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
        
        % Left/Right/Neutral x Pre/Post cues
        for cueType=1:6
            betas = glmfit(numStimInRange(filterLeftRight{cueType}), resp_model(filterLeftRight{cueType})'-1, 'binomial', 'link', 'logit');
            usage_byCueType(subject,cueType,angle+range(end)+1) = betas(2);
        end
        
        % Valid/Invalid x Pre/Post cues
        for cueType=1:4
            betas = glmfit(numStimInRange(filterValidity{cueType}), resp_model(filterValidity{cueType})'-1, 'binomial', 'link', 'logit');
            usage_byValidity(subject,cueType,angle+range(end)+1) = betas(2);
        end
    end
    
end

%% Fix extreme values
usage_byCueType(2,4,6) = (2*usage_byCueType(2,4,5) + 1*usage_byCueType(2,4,8))/3;
usage_byCueType(2,4,7) = (1*usage_byCueType(2,4,5) + 2*usage_byCueType(2,4,8))/3;
usage_byCueType(8,5,9) = (2*usage_byCueType(8,5,8) + 1*usage_byCueType(8,5,11))/3;
usage_byCueType(8,5,10) = (1*usage_byCueType(8,5,8) + 2*usage_byCueType(8,5,11))/3;
usage_byCueType(9,5,10) = (usage_byCueType(9,5,9) + usage_byCueType(9,5,11))/2;
usage_byCueType(12,5,78) = (2*usage_byCueType(12,5,77) + 1*usage_byCueType(12,5,80))/3;
usage_byCueType(12,5,79) = (1*usage_byCueType(12,5,77) + 2*usage_byCueType(12,5,80))/3;
usage_byCueType(14,4,1) = usage_byCueType(14,4,2);
usage_byCueType(24,5,70) = (usage_byCueType(24,5,69) + usage_byCueType(24,5,71))/2;
usage_byCueType(25,5,63) = (usage_byCueType(25,5,62) + usage_byCueType(25,5,64))/2;


%% Plot figures
% FIGURE 6B: Left/Right/Neutral x Pre/Post cues
figure
plot(range, squeeze(mean(usage_byCueType)), 'LineWidth',3)
hold on
plot([range(1),range(end)]', [0,0]', 'k-', 'LineWidth', 2)
legend('pre left', 'pre right', 'pre neutral', 'post left', 'post right', 'post neutral')
xlabel('Orientation (degrees)')
ylabel('Beta value')

% FIGURE 6C: Valid/Invalid x Pre/Post cues
figure
plot(range, squeeze(mean(usage_byValidity)), 'LineWidth',3)
hold on
plot([range(1),range(end)]', [0,0]', 'k-', 'LineWidth', 2)
legend('pre valid', 'pre invalid', 'post valid', 'post invalid')
xlabel('Orientation (degrees)')
ylabel('Beta value')

% FIGURE 6D: Difference between valid and invalid cues for pre vs. post
pre_effect = squeeze(usage_byValidity(:,1,:)-usage_byValidity(:,2,:));
post_effect = squeeze(usage_byValidity(:,3,:)-usage_byValidity(:,4,:));
figure
[l,p] = boundedline(range, mean(pre_effect)', std(pre_effect)'/sqrt(length(subjects)), '-b*', ...
    range, mean(post_effect)', std(post_effect)'/sqrt(length(subjects)), '-r*', 'alpha');
outlinebounds(l,p);
hold on
plot([range(1),range(end)], [0,0], 'k-')
legend('pre cue', 'post cue')
xlabel('Orientation (degrees)')
ylabel('Validity effect')