function p = defineParameters(p)

%% Get current time
current_time = clock;
p.text_results = ['Results' num2str(current_time(3)) '_' num2str(current_time(4)) '_' num2str(current_time(5)) '_Subject_' num2str(p.subjectNum)];


%% Open window and do useful stuff
[p.window,p.width,p.height] = openScreen();
Screen('TextFont',p.window, 'Cambria');
Screen('TextSize',p.window, 30);
Screen('FillRect', p.window, 127);
p.wrapat = 80;


%% Define the parameters for the experiment
p.number_runs = 4;
p.number_blocks = 4;
p.trials_per_block = 30;


%% Parameters of the stimulus
p.initialOffsetForStaircase = 40;

%% Set the stimulus details
p.cue_duration = .5;
p.stim_duration = .5;
p.computerRefreshRate = 60;
p.frame_duration = 1/p.computerRefreshRate;
p.frames_per_trial= round(p.stim_duration * p.computerRefreshRate);

%% Determine the size and locations of the gratings
p.stimSize_degrees_outer = 5; %in degrees
p.stimOuter = degrees2pixels(p.stimSize_degrees_outer); %in pixels
p.stimSize_degrees_inner = 1; %in degrees
p.stimInner = degrees2pixels(p.stimSize_degrees_inner); %in pixels
p.cueSize_degrees = .5;
p.cueSize = degrees2pixels(p.cueSize_degrees); %in pixels