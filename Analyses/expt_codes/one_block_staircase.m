function data = one_block_staircase(p)

% Staircase parameters
num_correct = 0;
step = 8;
numberReversals = 0;
direction = -1; %going down (1 for going up)
offset = p.initialOffsetForStaircase;

% Define keyboard input keys
one = KbName('1!');
two = KbName('2@');
nine = KbName('9(');

% Dimensions of annulus
radius = p.stimOuter;
radius2 = p.stimInner;

% Display 1 second of fixation in the beginning of the block
Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
Screen('Flip', p.window);
time = GetSecs + 1;

% Start the sequence of trials
for trial=1:1000
    
    % Randomize cue type (left/right/neutral)
    cue_type(trial) = 3; %neutral %CUE IS ALWAYS NEUTRAL!!!
    
    % Determine the stimulus
    if cue_type(trial) == 1 %CCW cue
        %left/CCW
        if rand <= 2/3 %make the orientation CCW
            stim_orientation(trial)= 1; %CCW
        else %make the stimulus CW
            stim_orientation(trial)= 2; %CW
        end
    elseif cue_type(trial) == 2 %CW cue
        %right/CW
        if rand <= 2/3 %make the stimulus CW
            stim_orientation(trial)= 2; %CW
        else %make the stimulus CCW
            stim_orientation(trial)= 1; %CCW
        end
    else %neutral cue
        if rand <= .5 %make the stimulus CCW
            stim_orientation(trial)= 1; %CCW
        else %make the stimulus CW
            stim_orientation(trial)= 2; %CW
        end
    end
    
    
    %% Pre-cue
    if cue_order == 1 %'before'
        Screen('FillOval',p.window,131,[p.width/2-radius2,p.height/2-radius2,p.width/2+radius2,p.height/2+radius2] );%encircles cue
        if cue_type(trial) == 1 %left cue
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2-p.cueSize, p.width/2-p.cueSize, p.height/2, 4);
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2+p.cueSize-1, p.width/2-p.cueSize-1, p.height/2, 4);
        elseif cue_type(trial) == 2 %right cue
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2-p.cueSize, p.width/2+p.cueSize, p.height/2, 4);
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2+p.cueSize, p.width/2+p.cueSize, p.height/2, 4);
        else %neutral cue
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2-p.cueSize, p.width/2, p.height/2+p.cueSize, 4);
        end
    else % Display noncue
        Screen('FillOval',p.window,131,[p.width/2-radius2,p.height/2-radius2,p.width/2+radius2,p.height/2+radius2] );%encircles cue
        Screen('DrawLine', p.window, 255, p.width/2-p.cueSize, p.height/2, p.width/2+p.cueSize, p.height/2, 4);
    end
    presentation_time(trial,1) = Screen('Flip', p.window, time);
    time = time + p.cue_duration;
    
    % Fixation
    Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
    presentation_time(trial,2) = Screen('Flip', p.window, time);
    time = time + p.cue_duration;
    
    
    %% Stimulus
    for frame = 1:p.frames_per_trial
        
        %Choose orientation
        while 1
            orientationAngle(trial,frame) = 22.5*randn + (2*stim_orientation(trial)-3) * offset;
            if abs(orientationAngle(trial,frame)) < 45
                break;
            end
        end
        
        % Create the Gabor patch
        gaborPatch = makeGaborPatch(2*radius, [], 1, 0);
        gaborTexture = Screen('MakeTexture', p.window, gaborPatch);
        
        % Present the stimuli
        Screen('DrawTexture', p.window, gaborTexture, [], [], 90 + orientationAngle(trial,frame));
        Screen('FillOval',p.window,127,[p.width/2-radius2,p.height/2-radius2,p.width/2+radius2,p.height/2+radius2] );
        Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
        
        %Change frame 30 times during 500 ms
        presentation_time_stim(trial,frame) = Screen('Flip', p.window, time);
        time = time + p.frame_duration;
    end
    
    % Fixation (after stimulus)
    Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
    presentation_time(trial,3) = Screen('Flip', p.window, time);
    time = time + p.cue_duration;
    
    %% Post-cue
    if cue_order == 2 %'after'
        Screen('FillOval',p.window,131,[p.width/2-radius2,p.height/2-radius2,p.width/2+radius2,p.height/2+radius2] );%encircles cue
        if cue_type(trial) == 1 %left cue
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2-p.cueSize, p.width/2-p.cueSize, p.height/2, 4);
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2+p.cueSize, p.width/2-p.cueSize, p.height/2, 4);
        elseif cue_type(trial) == 2 %right cue
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2-p.cueSize, p.width/2+p.cueSize, p.height/2, 4);
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2+p.cueSize, p.width/2+p.cueSize, p.height/2, 4);
        else %neutral cue
            Screen('DrawLine', p.window, 255, p.width/2, p.height/2-p.cueSize, p.width/2, p.height/2+p.cueSize, 4);
        end
    else % Display noncue
        Screen('FillOval',p.window,131,[p.width/2-radius2,p.height/2-radius2,p.width/2+radius2,p.height/2+radius2] );%encircles cue
        Screen('DrawLine', p.window, 255, p.width/2-p.cueSize, p.height/2, p.width/2+p.cueSize, p.height/2, 4);
    end
    presentation_time(trial,4) = Screen('Flip', p.window, time);
    time = time + p.cue_duration;
    
    
    %% Collect participant responses
    % Display question
    DrawFormattedText(p.window,'LEFT           RIGHT', 'center', p.height/2, 255);
    DrawFormattedText(p.window, '    ', 'center', p.height/2, 255);
    DrawFormattedText(p.window, '1                   2', 'center', p.height/2+50, 255);
    presentation_time(trial,5) = Screen('Flip', p.window, time);
     
    % Get contrast response
    while 1
        [keyIsDown,secs,keyCode]=KbCheck;
        if keyIsDown
            if keyCode(one) %CCW
                answer = 1;
                break;
            elseif keyCode(two) %CW
                answer = 2;
                break;
            elseif keyCode(nine)
                answer = bbb;
            end
        end
    end %end while
    
    % Calc RT for first response
    rt(trial) = secs - presentation_time(trial,5);

    
    %% Give feedback and save data    
    % Compute if answer is correct
    if stim_orientation(trial) == answer
        correct = 1;
    else
        correct = 0;
    end
    
    % Give feedback, if needed
    if p.feedback == 1
        if correct
            DrawFormattedText (p.window, 'CORRECT', 'center', 'center', [0 255 0]);
        else
            DrawFormattedText (p.window, 'WRONG', 'center', 'center', [255 0 0]);
        end
        Screen('Flip', p.window);
        WaitSecs(.5); %Present feedback for 500 ms
        
        % Get secs here if providing feedback/interval between trials
        secs = GetSecs;
    end
    
    % Present 1 second of fixation between trials
    Screen('FillOval', p.window, 255, [p.width/2-2,p.height/2-2,p.width/2+2,p.height/2+2]);
    Screen('Flip', p.window);
    time = secs + 1;
    
    % Save data from current trial
    data.response(trial) = answer;
    data.correct(trial) = correct;
    
    
    %% Update staircase
    if stim_orientation(trial) == answer
        if num_correct == 0
            num_correct = 1;
        else %num_correct == 1
            
            % Update the reversal count
            if direction == 1
                % REVERSAL!!!
                direction = -1;
                numberReversals = numberReversals + 1;
                offsetAtReversal(numberReversals) = offset;
                if numberReversals < 3
                    step = step / 2;
                end
            end
            
            % Update the offset
            offset = offset - step;
            if offset < 0
                offset = 0;
            end
            
            % Update the number of previously correct trials (0 or 1)
            num_correct = 0;
        end
    else
        
        % Update the reversal count
        if direction == -1
            % REVERSAL!!!
            direction = 1;
            numberReversals = numberReversals + 1;
            offsetAtReversal(numberReversals) = offset;
            if numberReversals < 3
                step = step / 2;
            end
        end
        
        % Update the offset
        offset = offset + step;
    end
    
    
    % Determine whether to end the staircase
    if numberReversals >= 10
        orientationOffset = mean(offsetAtReversal(5:10));
        break;
    end
    
    data.step_history(trial) = step;
    data.num_correct(trial) = num_correct;
    data.direction(trial) = direction;
    data.numberReversals(trial) = numberReversals;
    data.offset(trial) = offset;
end

% Save global block parameters
data.cue_type = cue_type;
data.stim_orientation = stim_orientation;
data.presentation_time = presentation_time;
data.presentation_time_stim = presentation_time_stim;
data.orientationAngle = orientationAngle;
data.rt = rt;
data.offsetAtReversal = offsetAtReversal;
data.orientationOffset = orientationOffset;