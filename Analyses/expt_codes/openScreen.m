function [window,width,height] = openScreen(windowPtrOrScreenNumber)

%-------------------------------------------------------------------------
% Opens a new screen using windowPtrOrScreenNumber.
% If no input is provided, screen is opened on max(Screen('Screens')).
%
% Performs some common commands to do at experiment startup.
% - sets highest priority level
% - hides cursor
% - unifies key names
% - resets the rand function
% - initializes some MEX files
%-------------------------------------------------------------------------

%% Open window
if ~exist('windowPtrOrScreenNumber','var') || isempty(windowPtrOrScreenNumber)
    windowPtrOrScreenNumber = max(Screen('Screens'));
end
[window,wRect] = Screen('OpenWindow', windowPtrOrScreenNumber);

% Get screen dimensions
width = wRect(3);
height = wRect(4);


%% Do other useful startup stuff
% Set highest priority level
priorityLevel=MaxPriority(window);
Priority(priorityLevel);

% Hide the cursor
%HideCursor;

% Unify keynames
KbName('UnifyKeyNames');

% Reset the rand function
rand('twister',sum(10*clock));

% Initialize some commonly used mex files (these files take a bit of time 
% to load the first time around)
GetSecs;
WaitSecs(.001);
if IsOSX
    d=PsychHID('Devices');
    keyboardNumber = 0;

    for n = 1:length(d)
        if strcmp(d(n).usageName,'Keyboard');
            keyboardNumber=n;
            break
        end
    end
    KbCheck(keyboardNumber);
else
    KbCheck;
end