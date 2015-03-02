function Scarcity_Games_BT(ppnr, block, stagegame, nrtrialcounter, shoptasktrial)
    % Scarcity Games
    % Wenwen Xie, edited by Inge Huijsmans
    %
    % Start editing 2014-11-12
    %
    % In this experiment participants play three games: the Dot Comparison, Dot
    % Counting and Shape Matching game. They play these three games in
    % randomized order. They will play these three games in sequence twice, 
    % once in the 'Abundance' condition, once in the 'Scarcity' condition.
    % The order of these conditions are counterbalanced between parcitipant. 
    % After participants have played a fixed number of trials
    % in each game, the task switches to a different task. This different task
    % can be implemented by a function. 
    %
    % Feedback on each trail of each of the tasks is fixed for all participants. 
    %
    % Last edit:
    %
    % Tried github
    % Tried a little more :p

    %%                            Set seed                                   %%

    rng shuffle
    
    if nargin == 0
        %Just begin experiment
        restart = 0;
        block = 1;
        stagegame = 1;
        nrtrialcounter = 1;
        jumptoshoptask = 0;
        shoptasktrial = 1;
    elseif nargin <5
        %Restart experiment in Scrcity Games
        restart = 1;
        jumptoshoptask = 0;
        shoptasktrial = 1;
    else
        %Restart experiment in ShopTask
        restart = 1;
        jumptoshoptask = 1;
    end
    
    try 
        SCANNER = {'Skyra','Dummy','Debugging','Keyboard','buttonbox'}; SCANNER = SCANNER{4};

        % setup bitsi stuff for button responses
        setup_bits;


        %%                  Start with setting resultsdir                           %%

        %Results
        results_dir = [cd '/Results/'];


        %%                          Screen stuff                                 %%   

        %Skips the 'Welcome to psychtoolbox message' 
        Screen('Preference', 'VisualDebuglevel', 1);

        %At the beginning of each script matlab does synctests. Level 1 and 2
        %prevent those tests. What does 0 do?
        Screen('Preference', 'SkipSyncTests', 0);

        % Get the screen numbers
        screens = Screen('Screens');

        % Draw to the external screen if avaliable
        screenNumber = max(screens);

        % Define black and white
        white = 255;
        black = 0;
        yellow=[255 255 0];
        green = [0 255 0];
        red = [255 0 0];

        % Open an on screen window
        [window, windowRect] = Screen('OpenWindow',screenNumber,black);
        HideCursor;

        % Get the size of the on screen window
        [screenXpixels, ~] = Screen('WindowSize', window);

        %Other applications compete with windows for resources. These lines make
        %sure matlab wins.
        prioritylevel=MaxPriority(window); 
        Priority(prioritylevel);

        % Get the centre coordinate of the window
        [xCenter, yCenter] = RectCenter(windowRect);
        [wth, hth] = Screen('WindowSize', window);

        %Textstuff
        penWidthPixels = 4;
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 32);
        Screen('TextStyle', window, 0);
        KbName('UnifyKeyNames');


        %%                          Set PPNR                         %%   

        %Set ppnr
        if restart == 0
            ppnr_str = openended(window, 'Participant Nr:', white);
            ppnr = str2double(ppnr_str);
        end

        %Inform that computer is working
        DrawFormattedText(window, 'Generating experiment configurations...\n\nOne moment please.', 'center','center', white);
        Screen('Flip',window)

        %%                        General statements                             %%

        nrtrials = 30;                                               %CHANGE NRTRIAL
        txt_totaltoken ='Your total tokens: ';
        breaktext = 'The exeperiment is pauzed by the experimenter\n\nPlease wait for the experiment to restart';

        %Stimulus durations
        pt_dotclouds = 1;
        pt_progressbar = 2;
        timeout = 2;
        instructtime = 5;                                            %CHANGE TIMING
        readinstructtime = 10;                                       %CHANGE TIMING

        % Questionnaire info
        nextkey = 'rightarrow';
        backkey = 'leftarrow';

        %Load all images & trial information
        Scarcity_Games_Prep;

        %%                           Shape matching images                       %%

        %Set textures
        textures_SM = zeros(1,length(filenames)-4);

        %Preallocate textures
        for i = 1:length(textures_SM)
            textures_SM(i) = Screen('MakeTexture', window, c.images_SM(:,:,:,i));
        end

        %%                      Set HR Trigger logs                             %%
        
        ScarcityGamesHRlogs;

        %%                       Prepare saving data                             %%

        %Prepare data logging
        time = datestr(now, 'DD-HH-MM');
        filename = [results_dir,  sprintf('Scarcity_ppnr_%i_time_%s_data.txt', ppnr, time)];
        fid = fopen(filename,'a+t');
        fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'ppnr','totaltrial', 'blocktrial','block','condition_AS', 'game', 'screenID', 'HR Trigger', 'mainstart', 'flip_onset', 'VBLTimestamp', 'lastFlipTimestamp', 'FlipTimestamp', 'MissedFlip','presenttime', 'response', 'RT', 'tokens');

        %Save first timing
        mainstart=tic;
        t_filename = [results_dir,  sprintf('Scarcity_ppnr_%i_time_%s_timing.txt', ppnr, time)];
        ft_id = fopen(t_filename,'a+t');
        fprintf(ft_id, '%s\t%s\t%s\t%s\n', 'mainstart','onset_dummy_pulses', 'onset_first_pulse', 'run');


        %%               Variables from the inserted experiment                  %%

        %Load all vars
        if restart
            load([results_dir, sprintf('ShopTaskPrep_%i.mat',ppnr)]);
        else
            vars = ShopTaskPrep(ppnr);
            save([results_dir, sprintf('ShopTaskPrep_%i.mat',ppnr)], 'vars');
        end

        vars.reminder = c.reminder;
        vars.gotit = gotit;
        vars.gotnot = gotnot;

        %prepare trial picker
        trialpicker = cell(144,6);
        
        %To be able to append to trialpicker
        if ~restart
            save([results_dir sprintf('wintrial_BT_%i.mat', ppnr)], 'trialpicker');   
        end
        
        %Prep saving
        filename = [results_dir,  sprintf('CD_ppnr_%i_time_%s_data.txt', ppnr, time)];
        fid_newtask = fopen(filename,'a+t');
        fprintf(fid_newtask, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t %s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t %s\t%s\t%s\t%s\n', 'ppnr','block', 'condition_S/A', 'totaltrial','trial','screenId', 'presenttime', 'VBLTimestamp', 'lastFlipTimestamp', 'FlipTimestamp', 'MissedFlip', 'flip_stamp','HR Trigger', 'startbid', 'bid_round', 'bid', 'computerprice', 'gotit','RT', 'condition', 'brand', 'product', 'filename', 'retailprice');

        %Prep saving
        filename = [results_dir,  sprintf('CD_ppnr_%i_time_%s_slider.txt', ppnr, time)];
        fid_slider = fopen(filename,'a+t');
        fprintf(fid_slider, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'trial', 'flip_nr', 'handle_x','response', 'fliptimestamp', 'tmp_bid','RT', 'VBLTimestamp', 'BidFlipTimestamp', 'FlipTimestamp', 'MissedFlip', 'ppnr','block', 'condition_txt', 'total_trial');

        %%                      Prep saving Finger Tapping                       %%

        if strcmp(SCANNER, 'Skyra')
            filename = [results_dir,  sprintf('Finger_Tapping_ppnr_%i_time_%s.txt', ppnr, time)];
            fid_FT = fopen(filename,'a+t');
            fprintf(fid_FT, '%s\t%s\t%s\t%s\t%s\n', 'ppnr', 'screenID', 'fliptimestamp','whenflip','toc(mainstart)');
        end
        
    catch me
        me.message
        me.stack.line
        Screen('CloseAll')
        close_bitsi
        return
    end

    
    try 
        %% Start game

        %Count & trackers
        tottrialcounter = 1;
        quit = 0;
        nextblock = 0;
        manualclose = 0;

        %Reminder instructions
        instructions(window, instruct_dir, 9,nextkey, backkey);
        
        while block < (length(c.condition)+1)   
            
            %If we pressed the quit button, break loop
            if quit == 1
                break
            end
            
            %Reset stagegame counter unless we just restarted the experiment
            if restart == 0
                stagegame = 1;
            end
            
            %Start by synchronizing scanner
            screenID  = -2;

            %Set reminder for Shoptask
            reminder = c.reminder{c.condition(block)}; 
            size_reminder = size(reminder);
            reminder = Screen('MakeTexture', window, reminder);
            
            if ispc
                reminder_loc = [screenXpixels-(((size_reminder(2)/4)*3)+100),100,screenXpixels-100,((size_reminder(1)/4)*3)+100];
            else
                reminder_loc = [screenXpixels-round((size_reminder(2)/8)*5),round((size_reminder(1)/8)),screenXpixels-round(size_reminder(2)/8),round((size_reminder(1)/8)*5)];
            end
            
            %Start stagegames 
            while stagegame < (length(c.c_game)+1)    
                
                %If we pressed the quit button, break loop
                if quit == 1
                    break
                end
                
                %Reset trialcounter unless we restarted
                if restart == 0
                    nrtrialcounter = 1;
                end
                
                %Reset nr of tokens according to condition for each block,
                %but not when restarting experiment
                if nrtrialcounter >1
                    tokens = c.token{c.condition(block)}(stagegame,nrtrialcounter-1);
                else
                    tokens = c.token{c.condition(block)}(stagegame,nrtrialcounter)+1;
                end

                %Reset count & trackers for each block
                run = 1;

                %Start trials
                while run

                    switch screenID

                        case -2
                            %% ----------- Synchronize scanner ----------%%
                            
                            %Start with instructions each new game
                            if block == 1 && restart == 0
                                scannr = 1;
                                %Go to finger tapping
                                if strcmp(SCANNER, 'Skyra')
                                    screenID  = -1;
                                else
                                    screenID = 0.3;
                                end
                                    
                            elseif block == 2 && restart == 0
                                scannr = 2;
                                %Self Paced Pauze
                                instructions(window, instruct_dir, 7, nextkey, backkey);
                                %Go to start game
                                screenID = 0.3;
                            else
                                %reset restart logical
                                restart = 0;
                                %new timing
                                scannr = 3;
                                %To fixation cross
                                if jumptoshoptask
                                    screenID = 1.2;
                                else
                                    screenID = 1.1;
                                end
                            end


                            if strcmp(SCANNER,'Debugging')
                                onset_dummy_pulses = wait_for_scanner_start(3,bitsiboxScanner,scannertrigger,true);
                                onset_first_pulse =  wait_for_scanner_start(1 ,bitsiboxScanner,scannertrigger,false);
                            elseif strcmp(SCANNER,'Keyboard')
                                % do nothing
                                % still, do get some timestamps so we don't need to worry about that case further down...
                                onset_dummy_pulses = GetSecs;
                                onset_first_pulse = GetSecs;
                            else % some kind of scanner -- wait for it
                                onset_dummy_pulses = wait_for_scanner(30,bitsiboxScanner,scannertrigger,true);% this might be change to 31
                                onset_first_pulse =  wait_for_scanner(1 ,bitsiboxScanner,scannertrigger,false);
                            end


                            %Save timing
                            fprintf(ft_id, '%.6f\t%.6f\t%.6f\t%i\n', mainstart, onset_dummy_pulses, onset_first_pulse, scannr);

                            %Set all recordings to 0, don't wait with flip
                            presenttime = 0.1;
                            RT = 0;
                            HR = 0;

                        case -1
                            %% Finger Tapping

                            %Start finger tapping script
                            Finger_Tapping(window, images_FT, fid_FT, ppnr, mainstart);

                            %Don't wait with flip
                            screenID = 0.3;
                            presenttime = 0.1;


                            %% Instructions

                        case 0.3
                            %% Start SBG
                            Screen('DrawTexture', window, c.start1, [], [], 0);
                            presenttime=instructtime;

                            %Set constants for data saving
                            RT = 0;

                            %Set HR trigger
                            HR = 3;

                            %Nextscreen
                            screenID = 0.4;

                        case 0.4

                            %% Allocate tokens
                            Screen('DrawTexture', window, c.alloc_token1, [], [], 0);
                            presenttime=instructtime;

                            %Set HR trigger
                            HR = 4;

                            %Nextscreen
                            screenID = 0.5;

                        case 0.5

                            %% Assign tokens
                            Screen('DrawTexture', window, c.alluc_token{c.condition(block)}, [], [], 0);
                            presenttime=instructtime;

                            %Set HR trigger
                            HR = c.HR_token{c.condition(block)};

                            %Start stagegame
                            screenID = 1.1; 

                        %% Instructions for each stagegame    
                        case 1.1

                            %% Start with stage game instr pt1
                            %Per different game
                            Screen('DrawTexture', window, c.instr_stagegame{1}(c.c_game(stagegame)), [], [], 0);
                            presenttime=instructtime;

                            %Reset trackers for each trial
                            RT = 0;

                            %Set HR trigger
                            HR = 5; 

                            %Nextscreen
                            screenID = 1.12;

                        case 1.12
                            %% Start with stage game instr pt2
                            %Button press instructions
                            if ispc
                                Screen('DrawTexture', window, c.instr_stagegame{3}(c.c_game(stagegame)), [], [], 0);
                            else
                                Screen('DrawTexture', window, c.instr_stagegame{2}(c.c_game(stagegame)), [], [], 0);
                            end
                            presenttime=readinstructtime;

                            %Set HR trigger
                            HR = 6; 

                            %Nextscreen
                            screenID = 2;

                        %% Instructions for start & end of Shoptask      
                        case 1.2

                            %% Nr of tokens before switch to shoptask
                            %Per level of scarcity/abundance
                            Screen('DrawTexture', window, c.switchtoken(c.condition(block)), [], [], 0);
                            Screen('DrawTexture', window, reminder, [], reminder_loc, 0);
                            presenttime=readinstructtime;

                            %Set HR trigger
                            HR = c.HR_token_before_shoptask{c.condition(block)};

                            %Nextscreen
                            screenID = 1.3;

                        case 1.3

                            %% Shoptask Instructions
                            %Button press instructions
                            if ispc
                                Screen('DrawTexture', window, inst_shoptask2, [], [], 0);
                            else
                                Screen('DrawTexture', window, inst_shoptask1, [], [], 0);
                            end
                            Screen('DrawTexture', window, reminder, [], reminder_loc, 0);
                            presenttime=readinstructtime;

                            %Set HR trigger
                            HR = 7; 

                            %Nextscreen
                            screenID = 1.4;


                        case 1.4

                            %% Switch back from shoptask to stagegame
                            Screen('DrawTexture', window, c.return_stagegame, [], [], 0);
                            Screen('DrawTexture', window, reminder, [], reminder_loc, 0);

                            presenttime=instructtime;

                            %Reset trackers for each trial
                            RT = 0;

                            %Set HR trigger
                            HR = 8; 

                            %Nextscreen
                            screenID = 2;

                        case 1.5

                            %% Finished round of games
                            Screen('DrawTexture', window, c.end_G1_G3{c.condition(block)}(stagegame), [], [], 0);
                            %Screen('DrawTexture', window, c.endtoken{c.condition(block)}, [], reminder_loc, 0);

                            presenttime=instructtime;

                            %Set HR trigger
                            HR = 9; 

                            if stagegame == 3 && block == 2
                                nextblock = 0;
                                screenID = 888;
                            else
                                screenID = 1.1;
                                nextblock = 1;
                            end


                        %% Experiment     
                        case 2

                            %% Fixation cross
                            Screen('DrawText',window, '+', xCenter, yCenter, white);

                            %Presenttime fixation cross
                            presenttime=0.5+rand(1);

                            %Reset trackers for each trial
                            RT = 0;            

                            %Set HR trigger
                            HR = c.HR_fixcross{c.condition(block)};

                            %Nextscreen 
                            screenID = 3;

                        case 3
                            %% Present game images

                            switch c.game_TXT{c.c_game(stagegame)}
                                case 'DComp'
                                    %Draw two rects with dots
                                    for i = 1:numSquares
                                        Screen('FrameRect', window, white, CenterRectOnPointd(baseRect, squareXpos(i), yCenter), penWidthPixels);
                                        Screen('DrawDots', window, c.clouds_DComp{i,nrtrialcounter}, 6, white, [],2);
                                    end
                                case 'DCount'
                                    %Draw one dot cloud
                                    Screen('DrawDots', window, c.clouds_DCount{nrtrialcounter}, 6, white, [],2);
                                case 'SMatch'
                                    %Draw Shapes
                                    Screen('DrawTexture', window, textures_SM(nrtrialcounter), [], [], 0);   
                            end

                            %Present screen
                            presenttime=pt_dotclouds;

                            %Set HR trigger
                            HR = c.HR_image{c.condition(block)};

                            %Next Screen
                            screenID = 4;

                        case 4 
                            %% Ask to select an answer option             

                            %Draw Q + answer options
                            DrawFormattedText(window, c.question{c.c_game(stagegame)}{nrtrialcounter}, 'center', 0.407*hth, white);

                            %Set color of left/right, & nextscreen
                            if response == 0
                                color = {white, white};
                                %Set HR trigger
                                HR = c.HR_question{c.condition(block)};
                                presenttime = 0;
                            elseif response == ButtonA
                                color = {yellow, white};
                                screenID = 5;
                                %Set HR trigger
                                HR = c.HR_response{c.condition(block)};
                                presenttime = timeout-RT;
                            else
                                color = {white, yellow};
                                screenID = 5;
                                %Set HR trigger
                                HR = c.HR_response{c.condition(block)};
                                presenttime = timeout-RT;
                            end

                            Screen('DrawText', window, c.left{c.c_game(stagegame)}, 0.343*wth, 0.685*hth, color{1});
                            Screen('DrawText', window, c.right{c.c_game(stagegame)}, 0.63*wth, 0.685*hth, color{2});

                        case 4.1
                            %% Too slow
                            DrawFormattedText(window, 'Too slow!', 'center', 'center', red);

                            %Present screen
                            presenttime=1;

                            %Set HR trigger
                            HR = c.HR_slow{c.condition(block)};

                            %Make them redo the trial: Fixation cross
                            screenID = 2;

                        case 4.2
                            %% Wrong button
                            DrawFormattedText(window, 'Wrong button!', 'center', 'center', red);

                            %Present screen
                            presenttime=1;

                            %Set HR trigger
                            HR = c.HR_winlose{c.condition(block)};

                            %Make them redo the trial: Fixation cross
                            screenID = 2;

                        case 5
                            %% Present win/lose            

                            %Draw Q + answer options
                            DrawFormattedText(window, c.question{c.c_game(stagegame)}{nrtrialcounter}, 'center', 0.407*hth, white);                 
                            Screen('DrawText', window, c.left{c.c_game(stagegame)}, 0.343*wth, 0.685*hth, color{1});
                            Screen('DrawText', window, c.right{c.c_game(stagegame)}, 0.63*wth, 0.685*hth, color{2});

                            %% Feedback, did they win tokens?
                            switch nrtrialcounter
                                case c.wintrials{stagegame,:}
                                    DrawFormattedText(window, 'You win 1 token!', 'center', 'center', green);
                                    tokens = tokens + 1;
                                otherwise
                                    DrawFormattedText(window, 'You lose 1 token!', 'center', 'center', red);
                                    tokens = tokens - 1;
                            end

                            %Set HR trigger
                            HR = c.HR_wrongbutton{c.condition(block)};

                            %Present screen jittered
                            presenttime=1+2*rand(1);

                            %Next screen: Progress bar
                            screenID = 6;   

                        case 6
                            %% Present progressbar

                            %Progress
                            txt_nrtokens = num2str(round(tokens));


                            switch tokens
                                case {1 2 3 8 9 10 11 12}     
                                    color = green;
                                    wintoken = eval(sprintf('tokenplus%d',tokens));
                                    Screen('DrawTexture', window, wintoken, [], [0.44*wth 0.17*hth 0.54*wth 0.45*hth], 0);
                                case {0 -1}
                                    color = red;
                                    if tokens == 0
                                        Screen('DrawTexture', window, token0, [], [0.44*wth 0.17*hth 0.54*wth 0.45*hth], 0);
                                    else
                                        Screen('DrawTexture', window, tokenmin1, [], [0.44*wth 0.17*hth 0.54*wth 0.45*hth], 0);
                                    end
                            end

                            %draw it all
                            [x,y] = DrawFormattedText(window,txt_totaltoken, 'center', 0.546*hth, white);
                            DrawFormattedText(window,txt_nrtokens, x, y, color);

                            %Present screen
                            presenttime = pt_progressbar;

                            %Nextscreen
                            screenID = 2;

                            if nrtrialcounter == c.stop(stagegame)
                                screenID = 1.2;
                            end

                            %Set HR trigger
                            HR = 12;

                            %Track trialnumbers
                            nrtrialcounter = nrtrialcounter + 1;
                            tottrialcounter = tottrialcounter +1;

                        case 999
                            %% Break the experiment in order to continue later

                            %draw it all
                            DrawFormattedText(window,breaktext, 'center', 0.46*hth, white);

                            %Set HR trigger
                            HR = 12;

                            %Wait for buttonpress
                            presenttime = inf;

                        case 888
                            %% Close it all down Pt 1

                            Screen('DrawTexture', window, c.end1, [], [], 0);
                            presenttime = instructtime;

                            %Set HR trigger
                            HR = 10; 

                            %Next screen
                            if ispc
                                nextblock = 1; 
                            else
                                screenID = 889;
                            end

                        case 889
                            %% Close it all down Pt 2

                            DrawFormattedText(window,'You are now finished with the main part of this experiment.\n\nThank you for participating!\n\nThe scanner will stop and the experimenter will come get you.', 'center', 'center', white);
                            presenttime = instructtime;

                            %Set HR trigger
                            HR = 11; 

                            %Next screen
                            nextblock = 1;                 

                    end

                    %% Flip it
                    [VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip] = Screen('Flip', window);
                    flip_onset=toc(mainstart);

                    %Send trigger to HR signal for each event
                    bitsiHR.sendTrigger(HR);


                    %% Wait for response
                    response = 0;
                    if presenttime == 0
                        if response == 0
                            while (response == 0 || response == 15) && ((GetSecs - lastFlipTimestamp )<= timeout)

                                %This is buttonbox code?
                                [response, keyDownTimestamp] = bitsiboxButtons.getResponse(0.001, true);

                            end

                            %Calculate RT's
                            RT=(keyDownTimestamp-lastFlipTimestamp); 

                            %Too slow
                            if response == 0
                                screenID = 4.1;
                            %Answer
                            elseif response == ButtonA || response == ButtonB
                                screenID = 4;
                            %Pauze
                            elseif response == ButtonD
                                screenID = 999;
                            %Next Block
                            elseif response == ButtonE
                                screenID = 1.1;
                                stagegame = stagegame + 1;
                                break
                            %Close All
                            elseif response == ButtonF                      
                                quit = 1;
                                display(sprintf('Scarcity Games\tppnr: %i\t block: %i\t stagegame: %i\t trialnumber:%i', ppnr, block, stagegame, nrtrialcounter));
                                HR = HR_quit;
                                break                  
                            %Wrong button
                            else
                                screenID = 4.2;

                            end
                        end
                    elseif presenttime == inf
                        while presenttime
                            %Continue experiment when hitting spacebar
                            [response, keyDownTimestamp] = bitsiboxButtons.getResponse(0.001, true);
                            if  response == ButtonF
                                run = 0;                        
                                quit = 1;
                                display(sprintf('Scarcity Games\tppnr: %i\t block: %i\t stagegame: %i\t trialnumber:%i',ppnr, block, stagegame, nrtrialcounter));
                                break
                            end
                        end
                    end

                    %Hold it on screen
                    WaitSecs(presenttime);

                    %Save everything all the time
                    fprintf(fid, '%i\t%i\t%i\t%i\t%s\t%s\t%.2f\t%i\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%i\t%.6f\t%i\n', ppnr, tottrialcounter, nrtrialcounter, stagegame, c.condition_txt{c.condition(block)}, c.game_TXT{c.c_game(stagegame)}, screenID, HR, mainstart, flip_onset, VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip, presenttime, response, RT, tokens); 

                    %Track if we need to switch to the other task
                    if screenID == 1.4

                        %Close bitsi's for shoptask
                        close_bitsi;
                        
                        %load from saved data
                        load([results_dir sprintf('wintrial_BT_%i.mat', ppnr)]); 
                        
                        %Shoptask
                        [trialpicker_block, manualclose] = Bidding_Task(window, vars, stagegame+((block-1)*3), shoptasktrial, ppnr, mainstart, c.reminder{c.condition(block)}, c.condition(block), fid_newtask, fid_slider, ft_id, SCANNER);
                        trialpicker((((stagegame+((block-1)*3))*24)-23):((stagegame+((block-1)*3))*24),:) = trialpicker_block;
                        
                        %Quick save of wintrials per pp       
                        save([results_dir sprintf('wintrial_BT_%i.mat', ppnr)], 'trialpicker');                        
                        
                        %Reset start point of next shoptask
                        shoptasktrial = 1;

                        if manualclose                       
                            quit = 1;
                            display(sprintf('Scarcity Games\tppnr: %i\t block: %i\t stagegame: %i\t trialnumber:%i', ppnr, block, stagegame, nrtrialcounter));
                            break
                        end

                        %Reopen bitsi
                        setup_bits;

                        %Textstuff                
                        Screen('TextFont', window, 'Ariel');
                        Screen('TextSize', window, 32);
                        Screen('TextStyle', window, 0);
                    end

                    %if button is pressed to skip block
                    if nextblock == 1
                        
                        %Begin at beginning of next block
                        nextblock = 0;
                        
                        %Go to next stagegame                   
                        stagegame = stagegame + 1;
                        break
                    end

                    %Things that need to happen after the flip of the last screen 
                    if nrtrials+1 <= nrtrialcounter
                        if screenID >10
                            continue;
                        else
                            screenID = 1.5;
                        end
                    end       
                end                
            end
            %Go to next block
            block = block + 1;

        end
    catch me
        Screen('CloseAll');
        me.message
        me.stack
        return
    end

    %Close all bitsi's, only not when manually broke out of ST
    if ~manualclose 
        close_bitsi;
    end

    Screen('CloseAll');   
    return
end