%---------------------------------------------
% analysis_behav
% The code performs the behavioral analyses on criterion c and sensitivity
% d' in Bang & Rahnev manuscript entitled "Stimulus expectation alters 
% decision criterion but not sensory signal in perceptual decision making." 
% It also creates all panels of Figure 3.
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

for subject_num=subjects
    
    subject = subject+1;
    load(['data/Results_s' num2str(subject_num)]);
    
    correct = [];
    stim = [];
    resp = [];
    cue = [];
    stimAngle = [];
    cueBefore = [];
    rt = [];
    
    for i=1:4
        for j=1:4
            correct(end+1:end+30) = p.data{i,j}.correct;
            stim(end+1:end+30) = p.data{i,j}.stim_orientation;
            resp(end+1:end+30) = p.data{i,j}.response;
            cue(end+1:end+30) = p.data{i,j}.cue_type;
            stimAngle(end+1:end+30,:) = p.data{i,j}.orientationAngle;
            cueBefore(end+1:end+30) = ones(1,30) * p.data{i,j}.cue_order;
            rt(end+1:end+30) = p.data{i,j}.rt;
        end
    end
    
    % Create filters
    for cueNum=1:2
        for cueType=1:3 %LRN
            filter_LRN{cueNum,cueType} = cueBefore==cueNum & cue==cueType; %filter{1/2,1:3} -> pre/post cue, L/R/N
        end
    end
    filter_half{1} = repmat([1,0],1,240); %alternating trials
    filter_half{2} = repmat([0,1],1,240);
    
    % Compute d' and c
    for cueNum=1:2
        for cueType=1:3 %LRN
            [d_LRN(subject,cueNum,cueType), c_LRN(subject,cueNum,cueType), beta(subject,cueNum,cueType)] = ...
                data_analysis_acc(stim(filter_LRN{cueNum,cueType}), correct(filter_LRN{cueNum,cueType}));
            
            % Separate analyses for each half of alternating trials
            for half=1:2
                [~, c_LRN_half(subject,cueNum,cueType,half)] = data_analysis_acc(...
                    stim(filter_LRN{cueNum,cueType} & filter_half{half}), ...
                    correct(filter_LRN{cueNum,cueType} & filter_half{half}));
            end
        end
    end
end

%% Criterion stats
% Compare each condition with 0
display('----- left cues -------')
c_left_cues_pre = mean(c_LRN(:,1,1))
[~, P, ~, stats] = ttest(c_LRN(:,1,1))
c_left_cues_post = mean(c_LRN(:,2,1))
[~, P, ~, stats] = ttest(c_LRN(:,2,1))
display('----- right cues -------')
c_right_cues_pre = mean(c_LRN(:,1,2))
[~, P, ~, stats] = ttest(c_LRN(:,1,2))
c_right_cues_post = mean(c_LRN(:,2,2))
[~, P, ~, stats] = ttest(c_LRN(:,2,2))
display('----- neutral cues -------')
c_neutral_cues_pre = mean(c_LRN(:,1,3))
[~, P, ~, stats] = ttest(c_LRN(:,1,3))
c_neutral_cues_post = mean(c_LRN(:,2,3))
[~, P, ~, stats] = ttest(c_LRN(:,2,3))

% Compare pre and post cues
display('----- compare pre and post cues for each cue type -------')
[~, P_left_cues, ~, stats] = ttest(c_LRN(:,1,1), c_LRN(:,2,1))
[~, P_right_cues, ~, stats] = ttest(c_LRN(:,1,2), c_LRN(:,2,2))
[~, P_neutral_cues, ~, stats] = ttest(c_LRN(:,1,3), c_LRN(:,2,3))
[~, P_criterion_effect, ~, stats] = ttest(c_LRN(:,1,1)-c_LRN(:,1,2), c_LRN(:,2,1)-c_LRN(:,2,2))

% Compare to optimality
display('----- compare pre and post cues to optimality -------')
optimalShift = mean(log(2)./mean(d_LRN(:,:,3),2)) - mean(log(1/2)./mean(d_LRN(:,:,3),2))
[~, P_optimalVSpost, ~, stats] = ttest(c_LRN(:,2,1) - c_LRN(:,2,2), optimalShift)
[~, P_optimalVSpre, ~, stats] = ttest(c_LRN(:,1,1) - c_LRN(:,1,2), optimalShift)


%% Inter-subject correlations
display('----- Inter-subject correlation between pre and post cue effects on the criterion -------')
[r_crit_effect, p] = corr(c_LRN(:,1,1)-c_LRN(:,1,2), c_LRN(:,2,1)-c_LRN(:,2,2))
reliability_preCues = corr(c_LRN_half(:,1,1,1)-c_LRN_half(:,1,2,1), c_LRN_half(:,1,1,2)-c_LRN_half(:,1,2,2))
reliability_postCues = corr(c_LRN_half(:,2,1,1)-c_LRN_half(:,2,2,1), c_LRN_half(:,2,1,2)-c_LRN_half(:,2,2,2))
corrected_reliability_preCues = 2*reliability_preCues / (1+reliability_preCues)
corrected_reliability_postCues = 2*reliability_postCues / (1+reliability_postCues)
max_crit_effect = sqrt(corrected_reliability_preCues*corrected_reliability_postCues)


%% d' stats
display('----- d'' effects -------')
[~, P_left_cues, ~, stats] = ttest(d_LRN(:,1,1), d_LRN(:,2,1))
[~, P_right_cues, ~, stats] = ttest(d_LRN(:,1,2), d_LRN(:,2,2))
[~, P_neutral_cues, ~, stats] = ttest(d_LRN(:,1,3), d_LRN(:,2,3))

[~, P_interaction_effect, ~, stats] = ttest(d_LRN(:,1,1)-d_LRN(:,1,2), d_LRN(:,2,1)-d_LRN(:,2,2))
[r_dprime_effect,p] = corr(d_LRN(:,1,1)+d_LRN(:,1,2)-2*d_LRN(:,1,3), d_LRN(:,2,1)+d_LRN(:,2,2)-2*d_LRN(:,2,3))


%% Plot figures
plot_6bars(c_LRN, 'Criterion c')
plot_individualData(c_LRN(:,1,1)-c_LRN(:,1,2), c_LRN(:,2,1)-c_LRN(:,2,2), [-.5, 2.5], 'Criterion')
plot_6bars(d_LRN, 'd''')
plot_individualData(d_LRN(:,1,1)+d_LRN(:,1,2)-2*d_LRN(:,1,3), d_LRN(:,2,1)+d_LRN(:,2,2)-2*d_LRN(:,2,3), [-2.5, 2.5], 'd''')