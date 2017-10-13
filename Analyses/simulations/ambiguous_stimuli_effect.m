%ambiguous_stimuli_effect

clear
close all

N = 30000;

% Cues and stimulus
cues = [ones(1,N/3), 2*ones(1,N/3), 3*ones(1,N/3)]; %LRN
stim = repmat([1,2],1,N/2); %LR

% Decide randomly on orientation for N trials X 30 frames/trial
orientationAngle = normrnd(7.5, 22.5, N, 30);
num_outside_range = 1;
while num_outside_range
    ind = find(abs(orientationAngle)>45);
    num_outside_range = length(ind);
    orientationAngle(ind) = normrnd(7.5, 22.5, 1, num_outside_range);
end
orientationAngle(stim==1,:) = -orientationAngle(stim==1,:); %flip for left stimuli

% Adjust perceived stimulus based on the cue
orientationAnglePerceived = orientationAngle;
orientationAnglePerceived(cues==1,:) = orientationAngle(cues==1,:) - 240*normpdf(orientationAngle(cues==1,:),0,6);
orientationAnglePerceived(cues==2,:) = orientationAngle(cues==2,:) + 240*normpdf(orientationAngle(cues==2,:),0,6);

% Make a decision for each trial
resp = (sum(orientationAnglePerceived,2) > 0); %0: left, 1: right

%% Temporal reverse correlation analysis (Predictive/Neutral)
for frame=1:30
    betas = glmfit(orientationAngle(cues<3,frame)/180*pi, resp(cues<3), 'binomial', 'link', 'logit');
    usage(1,frame) = betas(2);
    betas = glmfit(orientationAngle(cues==3,frame)/180*pi, resp(cues==3), 'binomial', 'link', 'logit');
    usage(2,frame) = betas(2);
end
figure
plot(usage', 'LineWidth',4)
legend('predictive cue', 'neutral cue')
title('Temporal reverse correlation')
ylim([1, 2.4])
xlabel('Frame number')
ylabel('Beta value')

%% Feature-based reverse correlation analysis (LRN)
window = 10;
bound = 45 - window/2;
range = -bound:bound;

% Perform regression for each orientation
for angle=range
    
    % Find out how many gratings had orientation within the window
    stimInRange = orientationAngle > (angle-window/2) & orientationAngle < (angle+window/2);
    numStimInRange = sum(stimInRange,2);
    
    for cue=1:3
        betas = glmfit(numStimInRange(cues==cue), resp(cues==cue), 'binomial', 'link', 'logit');
        usage(cue,angle+range(end)+1) = betas(2);
    end
end
figure
plot(range, usage', 'LineWidth',4)
legend('left cue', 'right cue', 'neutral cue')
title('Feature-based reverse correlation')
xlabel('Orientation (degrees)')
ylabel('Beta value')

%% Compute amount of biasing
percentRightResponses_cuesLRN = [mean(resp(cues==1)), mean(resp(cues==2)), mean(resp(cues==3))]