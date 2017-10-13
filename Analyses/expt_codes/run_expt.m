% run_expt

try
    
    % Clear the workspace.
    clear
    
    % Get subject number
    p.subjectNum = input('Enter subject number: ');
    
    % Define the parameters of the experiment
    p = defineParameters(p);
    
    % Determine cue onset (before/after) based on subject number
    if mod(p.subjectNum,2) == 0 %odd subject number
        cue_order = [1 2 1 2]; %baba
    else
        cue_order = [2 1 2 1]; %abab
    end
    
    %% Give training
    %p = training(p);
    p.orientationOffset = 20;
    
    
    % Instructions
    text = ['Great! We are now ready to start the actual experiment! '...
        '\n\nYou will complete 4 runs of 4 blocks each. Each block will consist of 30 trials. You will have '...
        '15-second breaks between blocks, and selt-timed breaks between runs.'...
        '\n\nEstimated Task Duration: 50 minutes'...
        '\n\nPress any key to continue.'];
    DrawFormattedText(p.window, text, 300, 'center', 255, p.wrapat);
    Screen('Flip',p.window);
    WaitSecs(2); % Make sure participant reads instuction by waiting at least 2 seconds
    KbWait;
    
    text = ['Remember to use the cues to help in your decision. The cues are there to help you.'...
        '\n\nRemember also to fix your eyes on the small fixation circle, and not move your eyes around. '...
        '\n\nIf you have any questions about the task, ask the experimenter now.'...
        '\n\nWhen ready, press any key to start the experiment!'];
    DrawFormattedText(p.window, text, 300, 'center', 255, p.wrapat);
    Screen('Flip',p.window);
    WaitSecs(2);
    KbWait;
    
    %%  Start sequence of runs
    p.feedback = 0;
    for run_number=1:p.number_runs
        for block_number=1:p.number_blocks
            
            % Inform participant about the run/block numbers
            text = ['RUN ' num2str(run_number) '  (out of ' num2str(p.number_runs) ')\n\n' ...
                'BLOCK ' num2str(block_number) '  (out of ' num2str(p.number_blocks) ')'];
            DrawFormattedText(p.window, text, 'center', 'center', 255);
            Screen('Flip', p.window);
            WaitSecs(3);
            
            % Display the block of trials and save data in p
            data = one_block(p, p.trials_per_block, cue_order(block_number));
            
            % Save results from block
            p.data{run_number, block_number} = data;
            eval(['save ' p.text_results ' p']);
            
            % End of block instructions
            if run_number < p.number_runs || block_number < p.number_blocks
                if block_number == p.number_blocks % End of a run
                    DrawFormattedText(p.window, 'Take a break. Press any key when ready to continue with the next run.', 'center', 'center', 255, p.wrapat);
                else % End of a block but not a run
                    DrawFormattedText(p.window, 'You have 15 seconds before the next block starts.', 'center', 'center', 255, p.wrapat);
                end
                Screen('Flip', p.window);
                if block_number == p.number_blocks
                    WaitSecs(1);
                    KbWait; % Let participants choose when to continue
                else
                    WaitSecs(10); % Gives a total of 15 seconds break between blocks
                end
            end
        end
    end
    
    % End of experiment
    DrawFormattedText(p.window, 'All done! Please call the experimenter at this time.', 'center', 'center', 255);
    Screen('Flip', p.window);
    WaitSecs(5);
    KbWait;
    
    % Close all windows
    Screen('CloseAll');
    
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end