function Experiment_main( subId, buttonAccceptIsLeft, RUN )
% subId = 99;
% RUN = 2;
% EXPERIMENTUG Run PsychToolBox-based Ultimatum Game Experiment
%   Inputs:
%       subId       ... subject-ID, defaults to 99
%       isPractice  ... a integer indicating whether to run practice run
%                       (0), or main experiment(1); default: 0
%   Outputs: None
%
%   Notes:
%       * Assert that no two consecutive miniblocks come from the same
%       block IF WANTED
%       * decide whether to use random offers, or use the same offers for
%       all, just randomized...

diary_filename = ['logs/' string_datetime 'dairy.log'];
diary(diary_filename);
% diary on;

SCANNER = {'Octave','Skyra','Dummy','Debugging'}; SCANNER = SCANNER{1};


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% set default values for input values
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ~exist('subId','var')
    subId = 99;
end

disp('subjec id:')
disp(subId)
disp('button accept is left:')
disp(buttonAccceptIsLeft)
disp('Run nr:')
disp(RUN)



% ~~~~~~~~~~~~~~~~~~~~~~~~~
% Create and Load Constants
% ~~~~~~~~~~~~~~~~~~~~~~~~~
if RUN == 1
    % create config for subject
    CreateConfig(subId,buttonAccceptIsLeft); % creates config_subID.mat with subject-specific config
    load (['config_' int2str(subId) '.mat']); % contains all constants used below (in all-caps)
    START_WITH_SLIDE = 3.1; % practice rounds
else % assuming RUN > 1
    % load existing config, with into on trial number
    load (['config_' int2str(subId) '.mat']);
    if cPractice.iTrial > length(cPractice.offers) % if all practice trials done
        if cMain.iTrial > 1
            START_WITH_SLIDE = 5.5; % continue with main
        else % we haven't really started with main part yet
            START_WITH_SLIDE = 5;
        end
        % and update endTrial number so we show only 'nTrialPerRun' in this
        % run
        % make sure endTrial is less then total number of offers
        cMain.endTrial = min(cMain.iTrial + nTrialsPerRun, length(cMain.offers));
    else
        if cPractice.iTrial == 1
            START_WITH_SLIDE = 3.1; % start practice rounds
        else
            START_WITH_SLIDE = 3.2; % show remaining practice rounds
        end
    end
end

% ~~~~~~~~~~~~~~~
% prepare logging
% ~~~~~~~~~~~~~~~
%warn if duplicate sub ID
fileName=['logs/' string_datetime FILE_PREFIX int2str(subId) int2str(RUN) '.log'];
if exist(fileName,'file')
    resp=input(['the file ' fileName ' already exists. do you want to overwrite it? [Type ok for overwrite]'], 's');
    if ~strcmp(resp,'ok') %abort experiment if overwriting was not confirmed
        disp('experiment aborted')
        return
    end
end
[file_log , message] = fopen(fileName,'wt');
if file_log == -1 % ie error
    disp('could not open file. Message:');
    disp(message);
    return
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ==== START PSYCHTOOLBOX ==============
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
try
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % initialize PsychToolBox stuff
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Enable unified mode of KbName, so KbName accepts identical key names on
    % all operating systems (not absolutely necessary, but good practice):
    KbName('UnifyKeyNames');
    
    %funnily enough, the very first call to KbCheck takes itself some
    %time - after this it is in the cache and very fast
    %to make absolutely sure, we thus call it here once for no other
    %reason than to get it cached. This btw. is true for all major
    %functions in Matlab, so calling each of them once before entering the
    %trial loop will make sure that the 1st trial goes smooth wrt. timing.
    KbCheck;
    
    %disable output of keypresses to Matlab. !!!use with care!!!!!!
    %if the program gets stuck you might end up with a dead keyboard
    %if this happens, press CTRL-C to reenable keyboard handling -- it is
    %the only key still recognized.
    %ListenChar(2);
    
    %Set higher DebugLevel, so that you don't get all kinds of messages flashed
    %at you each time you start the experiment:
    olddebuglevel=Screen('Preference', 'VisualDebuglevel', 1);
    
    % make sure to run PTB tests
    Screen('Preference', 'SkipSyncTests', 0)
    
    
    %Choosing the display with the highest display number is
    %a best guess about where you want the stimulus displayed.
    %usually there will be only one screen with id = 0, unless you use a
    %multi-display setup:
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    white = 255;
    black = 0;
    
    %open an (the only) onscreen Window, if you give only two input arguments
    %this will make the full screen white (=default)
    [window,screenRect]=Screen('OpenWindow',screenNumber,COLOR_GREY);
    
    %get the midpoint (mx, my) of this window, x and y
    [xCenter, yCenter] = RectCenter(screenRect);
    
    %get rid of the mouse cursor, we don't have anything to click at anyway
    HideCursor;
    
    %Preparing and displaying the welcome screen
    % We choose a text size of 24 pixels - Well readable on most screens:
    [oldFontName,oldFontNumber]=Screen('TextFont', window, 'Calibri');
    Screen('TextSize', window, 16);
    Screen('TextStyle', window, 0); % use normal font
    
    %     oldEnableFlag = Screen('Preference', 'TextAntiAliasing', [enableFlag=-1 (System
    % setting), 0 = Disable, 1 = Enable, 2 = EnableHighQuality]);
    oldEnableFlag = Screen('Preference', 'TextAntiAliasing', 2);
    
    disp('making textures main');
    % and prepare PTB textures
    cMain.texturePartners = Screen('MakeTexture',window, cMain.imagePartners);
    for i = 1:length(cMain.imageHistograms)
        cMain.textureHistograms{i} = Screen('MakeTexture',window, cMain.imageHistograms{i});
    end
    %     end
    
    disp('making textures practice');
    % moved here because otherwise weird texture bug in BSI cubicle... no
    % other clear way of solving it...
    % and prepare PTB texturess
    cPractice.texturePartners = Screen('MakeTexture',window, cPractice.imagePartners);
    
    for i = 1:length(cPractice.imageHistograms)
        %    cPractice.images{i}
        cPractice.textureHistograms{i} = Screen('MakeTexture',window, cPractice.imageHistograms{i});
    end
    
    
    %% wait for scanner
    setup_bitsi
    if strcmp(SCANNER,'Debugging')
        onset_dummy_pulses = wait_for_scanner(3,bitsiboxScanner,scannertrigger,true);
        onset_first_pulse =  wait_for_scanner(1 ,bitsiboxScanner,scannertrigger,false);
    elseif strcmp(SCANNER,'Octave')
        % do nothing
        % still, do get some timestamps so we don't need to worry about that case further down...
        onset_dummy_pulses = GetSecs;
        onset_first_pulse = GetSecs; 
    else % some kind of scanner -- wait for it
        onset_dummy_pulses = wait_for_scanner(30,bitsiboxScanner,scannertrigger,true);
        onset_first_pulse =  wait_for_scanner(1 ,bitsiboxScanner,scannertrigger,false);
    end
    
    % log scanner onsets
    fprintf(file_log, 'UG subj %i - onset_dummy_pulses: %f \n',subId,  onset_dummy_pulses);
    fprintf(file_log, 'UG subj %i - onset_first_pulse: %f \n',subId, onset_first_pulse);
    
    
    %% start PTB Stuff
    % ~~~~~~~~~~~~~~~~~~~~~~~
    % Start actual Experiment
    % ~~~~~~~~~~~~~~~~~~~~~~~
    tic;
    loopTime = [];
    missedScreens = {};
    
    screenIdFollowing = START_WITH_SLIDE ; % start in 'Welcome' screen (ie screen nr. 1)
    
    lastFlipTimestamp = Screen('Flip',window,0); % just initialize 'lastFlipTimestamp' variable;
    waitTimeNext = 0; % how long the above should be displayed -- we can skip it asap
    run = 1;
    while run
        waitTimePrevious = waitTimeNext;
        screenIdCurrent = screenIdFollowing;
        
        %% Draw Screen, dependent on currently displayed Screen
        switch screenIdFollowing
            
            
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            % ==== Initiate Practice Task ==========
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            case 3.1 % 'Practice' intro
                txtTmp = 'Practice Rounds';
                DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                
                
                % define 'c' for TASK SCREENS
                
                c = cPractice;
                
                % skipping 'real' trials
                %                 c.ScreenAfterDone = 99; % that's the screen the task should go to once the loop is over
                
                c.ScreenAfterDone = 5; % that's the screen the task should go to once the loop is over
                
                %                 waitTimeNext = 0; % wait for key
                waitTimeNext = 4; % in Secs
                screenIdFollowing = 4.1;
                
                
            case 3.2 % intro for run>1
                txtTmp = 'Continuing with practice rounds';
                DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                
                
                % define 'c' for TASK SCREENS
                
                c = cPractice;
                
                % skipping 'real' trials
                %                 c.ScreenAfterDone = 99; % that's the screen the task should go to once the loop is over
                
                c.ScreenAfterDone = 5; % that's the screen the task should go to once the loop is over
                
                %                 waitTimeNext = 0; % wait for key
                waitTimeNext = 4; % in Secs
                screenIdFollowing = 4.1;
                
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                % ==== Initiate Main Task ==========
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                
            case 5 % start real experiment
                txtTmp = [...
                    'This was the practice round.\n\n\n'...
                    'As mentioned earlier, you will be playing for real money now.\n\n'...
                    'At the end of the experiment, we will select one round randomly and pay according to the offer and your decision whether to accept or reject.'...
                    ];
                DrawFormattedText(window,txtTmp,'center','center',white, 50, [], [], 2);
                
                % assuming we got here by finishing practice rounds, we
                % save the array to cPractice
                cPractice = c;
                
                % define 'c' for TASK SCREENS
                c = cMain;
                c.ScreenAfterDone = 6; % that's the screen the task should go to once the loop is over
                
                screenIdFollowing = 4.1;
                waitTimeNext = 4; % in Secs
                
                
            case 5.5 % continue main experimental trials
                txtTmp = [...
                    'Continuing with the experiment'...
                    ];
                DrawFormattedText(window,txtTmp,'center','center',white, 50, [], [], 2);
                
                
                % define 'c' for TASK SCREENS
                c = cMain;
                c.ScreenAfterDone = 6; % that's the screen the task should go to once the loop is over
                
                screenIdFollowing = 4.1;
                waitTimeNext = 4; % in Secs
                
                
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                % ==== Task Screens ================
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            case 4.1
                % Fixation Screen
                FixCross = [xCenter-2,yCenter-25,xCenter+2,yCenter+25;xCenter-25,yCenter-2,xCenter+25,yCenter+2]; % if i want to change fixation cross, 1 for thickness, 40 for length
                Screen('FillRect', window, [white,white,white], FixCross'); % function that makes the screen with the fixation cross, (FillRect, on what, with what color, what to fill)
                
                %                 waitTimeNext = 0; % wait for key
                waitTimeNext = T_FIXATION + jitter();
                
                % show histogram (screenId 4.2) always at beginning of run
                % (i.e screenIdCurrent one of [..] or when MINIBLOCK_LENGTH
                % trials passed without
                if c.iTrial == 1
                    screenIdFollowing = 4.2;
                else
                    previousCondition = c.conditions(c.iTrial-1);
                    currentCondition = c.conditions(c.iTrial);
                    if previousCondition ~= currentCondition % ie changing conditions
                        screenIdFollowing = 4.2;
                    else
                        % if after a full miniblock, it's still the same
                        % condition, show the histrogram anyway.
                        if (c.iTrial > 5) && (currentCondition == c.conditions(c.iTrial-MINIBLOCK_LENGTH))
                            screenIdFollowing = 4.2;
                        else
                            screenIdFollowing = 4.3;
                        end
                    end
                end
                
            case 4.2 % histogram screen
                % put histogram onto screen
                [h w t] = size(c.imageHistograms{c.conditions(c.iTrial)}); % get dimensions of pic
                targetWidth = 400;
                targetHeight = floor(targetWidth / w*h); % calculate pic height by maintaining aspect ration
                xPic = xCenter - 200 ; yPic = yCenter - 30; % define position of pic
                Screen('DrawTexture', window, c.textureHistograms{c.conditions(c.iTrial)} , [0 0 w h], [xPic yPic xPic+targetWidth yPic+targetHeight], 0 , 0);
                % plus 'ylabel' annotation
                xText = xPic - 85 ; yText = yPic + 75; % define position of text, relative to histogram
                oldTextSize = Screen('TextSize', window, 14);
                txtTmp = [...
                    'number\n'...
                    'of offers'...
                    ];
                
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                xText = xPic - 60; yText = yPic; % define position of text, relative to histogram
                txtTmp = [...
                    'High'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                xText = xPic - 60; yText = yPic + 190; % define position of text, relative to histogram
                txtTmp = [...
                    'Low'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                Screen('TextSize', window, oldTextSize);
                
                
                % draw headline
                txtTmp = [...
                    'The next players are from group:'
                    ];
                xText = xPic - 60; yText = yPic - 270 ; % define position of text, relative to histogram
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                % add draw Group name
                oldTextSize = Screen('TextSize', window, 25);
                txtTmp = c.conditionLabels{c.conditions(c.iTrial)};
                xText = xPic + 250; yText = yText - 7;% yText is the same as previous text
                DrawFormattedText(window, txtTmp, xText, yText, c.conditionColors{c.conditions(c.iTrial)}, [], [], [], 2);
                Screen('TextSize', window, oldTextSize);
                
                % add text highlighting mean of distro
                currentMean = c.conditionMeans(c.conditions(c.iTrial));
                x1 = xCenter - 170; % x-position of 1euro bar
                dX = 33; % x-position step between bars
                % add line & text
                xFrom = x1 + (currentMean -1 ) * dX;
                yFrom = yPic - 10;
                xTo = xCenter; yTo = yFrom - 50;
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                
                % add text
                
                xText = xTo - 200; yText = yTo - 50; % define position of text
                txtTmp =[ ...
                    'From this group, the average offer was around ' int2str(currentMean) ' '...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                waitTimeNext = T_HISTO;
                screenIdFollowing = 4.3;
                
            case 4.3 % 'Offer' Screen
                txtTmp =[ 'Player          is offering you\n' ...
                    '\n\n\n out of 20  '...
                    ];
                xText = xCenter; yText = yCenter - 320; % define position of text
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                xText = xCenter + 60; yText = yCenter - 320;
                txtTmp = [ int2str(c.partners(c.iTrial)) ];
                DrawFormattedText(window, txtTmp, xText, yText, c.conditionColors{c.conditions(c.iTrial)}, [], [], [], 2);
                
                oldTextSize = Screen('TextSize', window, 35);
                
                xText = xCenter; yText = yCenter - 260; % define position of text
                txtTmp = [int2str(c.offers(c.iTrial)) '  '];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                Screen('TextSize', window, oldTextSize);
                
                txtTmp = 'Do you want to ACCEPT or REJECT this offer?';
                xText = xCenter - 200; yText = yCenter + 250; % define position of text
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                if c.buttonAcceptIsLeft(c.iTrial)
                    txtTmpLeft = 'press LEFT to ACCEPT';
                    txtTmpRight = 'press RIGHT to REJECT';
                else
                    txtTmpLeft = 'press LEFT to REJECT';
                    txtTmpRight = 'press RIGHT to ACCEPT';
                end
                xText = xCenter - 420; yText = yCenter + 320;
                DrawFormattedText(window, txtTmpLeft, xText, yText, white, [], [], [], 2);
                xText = xCenter + 200; yText = yCenter + 320;
                DrawFormattedText(window, txtTmpRight, xText, yText, white, [], [], [], 2);
                
                % pick image according to current condition
                [h w t] = size(c.imagePartners); % get dimensions of pic
                targetWidth = 150;
                targetHeight = floor(targetWidth / w*h); % calculate pic height by maintaining aspect ration
                xPic = xCenter - 250 ; yPic = yCenter - 320; % define position of pic
                Screen('DrawTexture', window, c.texturePartners, [0 0 w h], [xPic yPic xPic+targetWidth yPic+targetHeight], 0 , 0);
                
                % put histogram onto screen
                [h w t] = size(c.imageHistograms{c.conditions(c.iTrial)}); % get dimensions of pic
                targetWidth = 400;
                targetHeight = floor(targetWidth / w*h); % calculate pic height by maintaining aspect ration
                xPic = xCenter - 150; yPic = yCenter ; % define position of pic
                Screen('DrawTexture', window, c.textureHistograms{c.conditions(c.iTrial)} , [0 0 w h], [xPic yPic xPic+targetWidth yPic+targetHeight], 0 , 0);
                % plus 'ylabel' annotation
                xText = xPic - 85 ; yText = yPic + 75; % define position of text, relative to histogram
                oldTextSize = Screen('TextSize', window, 14);
                txtTmp = [...
                    'number\n'...
                    'of offers'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                xText = xPic - 60; yText = yPic; % define position of text, relative to histogram
                txtTmp = [...
                    'High'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                xText = xPic - 60; yText = yPic + 190; % define position of text, relative to histogram
                txtTmp = [...
                    'Low'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                Screen('TextSize', window, oldTextSize);
                
                % add "current offer" marker to histo
                x1 = xPic + 35; % x-position of 1euro bar
                dX = 33; % x-position step between bars
                xMarker = x1 + (c.offers(c.iTrial) - 1)*dX; % position marker as function of offer
                xText = xMarker - 30; % let the text go a bit over the marker..
                yText = yPic - 120;
                txtTmp = 'current offer';
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                % add arrow
                xFrom = xMarker; xTo = xMarker;
                yFrom = yText + 40;
                yTo = yFrom + markerLength(c.offers(c.iTrial),c.conditionLabels{c.conditions(c.iTrial)}); % grab this from dedicated list
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                xFrom = xMarker; xTo = xMarker + 10; % go 10px right
                yFrom = yTo; % bottom end of previous line
                yTo = yFrom - 10; % go 10px up
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                xFrom = xMarker; xTo = xMarker - 10; % go 10px left
                yTo = yFrom - 10; % go 10px up % keep yFrom the same
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                
                screenIdFollowing = 4.35;
                waitTimeNext = - T_OFFER; % using negative waitTime to wait for key but to wait only for abs(waitTime) seconds
                
                % make sure to ignore any remaining things in the buffer
                clearResponses(bitsiboxButtons);
                
            case 4.35 % 'Offer' Screen -- after button pressed
                txtTmp =[ 'Player          is offering you\n' ...
                    '\n\n\n out of 20  '...
                    ];
                xText = xCenter; yText = yCenter - 320; % define position of text
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                xText = xCenter + 60; yText = yCenter - 320;
                txtTmp = [ int2str(c.partners(c.iTrial)) ];
                DrawFormattedText(window, txtTmp, xText, yText, c.conditionColors{c.conditions(c.iTrial)}, [], [], [], 2);
                
                oldTextSize = Screen('TextSize', window, 35);
                
                xText = xCenter; yText = yCenter - 260; % define position of text
                txtTmp = [int2str(c.offers(c.iTrial)) '  '];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                Screen('TextSize', window, oldTextSize);
                
                txtTmp = 'Do you want to ACCEPT or REJECT this offer?';
                xText = xCenter - 200; yText = yCenter + 250; % define position of text
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                if c.buttonAcceptIsLeft(c.iTrial)
                    txtTmpLeft = 'press LEFT to ACCEPT';
                    txtTmpRight = 'press RIGHT to REJECT';
                    
                else
                    txtTmpLeft = 'press LEFT to REJECT';
                    txtTmpRight = 'press RIGHT to ACCEPT';
                end
                
                if c.accepted(c.iTrial) == 1 && c.buttonAcceptIsLeft(c.iTrial)
                    color_left=highlighted;
                    color_right=white;
                elseif c.accepted(c.iTrial) == 1 && not(c.buttonAcceptIsLeft(c.iTrial))
                    color_left = white;
                    color_right = highlighted;
                elseif c.accepted(c.iTrial) == 0 && c.buttonAcceptIsLeft(c.iTrial)
                    color_left = white;
                    color_right = highlighted;
                elseif c.accepted(c.iTrial) == 0 && not(c.buttonAcceptIsLeft(c.iTrial))
                    color_left=highlighted;
                    color_right=white;
                else % whether accepcted nor rejected
                    color_left = white;
                    color_right = white;
                end
                xText = xCenter - 420; yText = yCenter + 320;
                DrawFormattedText(window, txtTmpLeft, xText, yText, color_left, [], [], [], 2);
                xText = xCenter + 200; yText = yCenter + 320;
                DrawFormattedText(window, txtTmpRight, xText, yText, color_right, [], [], [], 2);
                
                % pick image according to current condition
                [h w t] = size(c.imagePartners); % get dimensions of pic
                targetWidth = 150;
                targetHeight = floor(targetWidth / w*h); % calculate pic height by maintaining aspect ration
                xPic = xCenter - 250 ; yPic = yCenter - 320; % define position of pic
                Screen('DrawTexture', window, c.texturePartners, [0 0 w h], [xPic yPic xPic+targetWidth yPic+targetHeight], 0 , 0);
                
                % put histogram onto screen
                [h w t] = size(c.imageHistograms{c.conditions(c.iTrial)}); % get dimensions of pic
                targetWidth = 400;
                targetHeight = floor(targetWidth / w*h); % calculate pic height by maintaining aspect ration
                xPic = xCenter - 150; yPic = yCenter ; % define position of pic
                Screen('DrawTexture', window, c.textureHistograms{c.conditions(c.iTrial)} , [0 0 w h], [xPic yPic xPic+targetWidth yPic+targetHeight], 0 , 0);
                % plus 'ylabel' annotation
                xText = xPic - 85 ; yText = yPic + 75; % define position of text, relative to histogram
                oldTextSize = Screen('TextSize', window, 14);
                txtTmp = [...
                    'number\n'...
                    'of offers'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                xText = xPic - 60; yText = yPic; % define position of text, relative to histogram
                txtTmp = [...
                    'High'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                xText = xPic - 60; yText = yPic + 190; % define position of text, relative to histogram
                txtTmp = [...
                    'Low'...
                    ];
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                Screen('TextSize', window, oldTextSize);
                
                % add "current offer" marker to histo
                x1 = xPic + 35; % x-position of 1euro bar
                dX = 33; % x-position step between bars
                xMarker = x1 + (c.offers(c.iTrial) - 1)*dX; % position marker as function of offer
                xText = xMarker - 30; % let the text go a bit over the marker..
                yText = yPic - 120;
                txtTmp = 'current offer';
                DrawFormattedText(window, txtTmp, xText, yText, white, [], [], [], 2);
                
                % add arrow
                xFrom = xMarker; xTo = xMarker;
                yFrom = yText + 40;
                yTo = yFrom + markerLength(c.offers(c.iTrial),c.conditionLabels{c.conditions(c.iTrial)}); % grab this from dedicated list
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                xFrom = xMarker; xTo = xMarker + 10; % go 10px right
                yFrom = yTo; % bottom end of previous line
                yTo = yFrom - 10; % go 10px up
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                xFrom = xMarker; xTo = xMarker - 10; % go 10px left
                yTo = yFrom - 10; % go 10px up % keep yFrom the same
                Screen('DrawLine', window, white, xFrom, yFrom, xTo, yTo, 3);
                
                screenIdFollowing = 4.4;
                waitTimeNext = -waitTimePrevious - c.RT{c.iTrial} ; % waitTimePrevious is negative
                
                
            case 4.4 % 'Feedback' Screen
                
                % pick feedback txt based on decision
                % (accept/reject/unknown)
                switch c.accepted(c.iTrial)
                    case 0 % ie reject
                        txtTmp = ['You rejected this offer.\n\n' ...
                            'You and Player          get nothing'];
                        DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                        
                        xText = xCenter - 4; yText = yCenter + 17;
                        txtTmp = int2str(c.partners(c.iTrial));
                        DrawFormattedText(window,txtTmp, xText, yText , c.conditionColors{c.conditions(c.iTrial)}, [], [], [], 2);
                    case 1 % ie accepted
                        txtTmp = ['You accepted this offer.\n\n' ...
                            'You get ' num2str(c.offers(c.iTrial)) '  \n'...
                            '       gets ' num2str(20-c.offers(c.iTrial)) '  '];
                        DrawFormattedText(window, txtTmp, 'center', 'center', white, [], [], [], 2);
                        txtTmp = num2str(c.partners(c.iTrial));
                        xText = xCenter - 62; yText = yCenter + 33;
                        DrawFormattedText(window, txtTmp, xText, yText, c.conditionColors{c.conditions(c.iTrial)}, [], [], [], 2);
                    case KEY_NONE
                        txtTmp = [...
                            'Too Slow!\n\n' ...
                            'Make your decision faster'];
                        DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                        waitTimeNext = 0; % wait for participant after error
                    otherwise % ie wrong button
                        % txtTmp = [ 'Feedback Screen \n\n keyCode: ' int2str(answerKey) '\n\n KbName:  ' KbName(answerKey) ];
                        txtTmp = [...
                            'Wrong button!\n\n' ...
                            'Please use the indicated keys only.'];
                        DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                end
                waitTimeNext = T_FEEDBACK;
                
                c.iTrial = c.iTrial + 1; % procede to next trial
                % Check whether out of trials for current run
                if c.iTrial > c.endTrial
                    if isfield(c,'ScreenAfterDone') % if 'ScreenAfterDone' is provided, use it
                        screenIdFollowing = c.ScreenAfterDone;
                    else
                        screenIdFollowing = 99; % else exit w/ goodbye
                    end
                else
                    screenIdFollowing = 4.1; % if still trials left, go to fixation cross
                end
                
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                % ==== Outro Screens ===============
                % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                
            case 6 % 'Out' screen
                txtTmp = ['Thank you!\n\n'...
                    'You have finished this part.'];
                DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                
                screenIdFollowing = 90;
                
                waitTimeNext = 4; % wait for key
                
            case 90 % 'Stopping scanner' screen
                disp('reached stopping scanner screen');
                if strcmp(SCANNER,'Octave')
                    txtTmp = ['Call the experimenter to proceed.'];    
                    waitTimeNext = 6; % wait for key
                else
                    txtTmp = ['We are going to stop scanning in a few moments'];
                    waitTimeNext = 25; % wait for key
                end
                DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                screenIdFollowing = 777;
                
            case 777; % stopping screen
                run = 0;
            
            otherwise
                txtTmp = ['ERROR ... not setting "screenIdFollowing" properly... \n\n\n ' ...
                    'STOPPING THE EXPERIMENT \n\n'...
                    'PLEASE INFORM THE EXPERIMENTER OF THE ERROR NOW'];
                DrawFormattedText(window,txtTmp,'center','center',white, [], [], [], 2);
                
                waitTimeNext = 0; % wait for key
                run = 0;
        end
        
        %         % just for debugging
        %         counter = counter + 1;
        %         Screen('DrawText',window,int2str(counter) , 0, 0, white  );
        
        % inform PTB that no more drawing will happen till Screen('Flip')-call
        % we now can do other matlab stuff
        Screen('DrawingFinished',window);
        
        %% set 'whenFlip' variable -- indicates when to flip to the next screen
        slack = 0.005;
        if waitTimePrevious > 0
            whenFlip = lastFlipTimestamp + waitTimePrevious - slack;
        else
            whenFlip = 0; % as soon as possible
        end
        
        %% Prepare stuff for listening to Keyboard
        % prepare before flipping screens (should have still time here, but
        % we want to do as little calculations as possible once measuring
        % reaction times)
        if waitTimeNext == 0 % self-paced option. Will wait till participant presses a button
            timeout = inf; % waitTime == 0 inidicates that we want to wait for a key, no matter what
        elseif waitTimeNext < 0 % display screen for abs(waitTimeNext), but listen to user imput. jump to next screen if button pressed earlier (makes highlighting of option possible)
            timeout = abs(waitTimeNext);
        else % positive waitTimeNext --> just wait that time -- no user input needed
            timeout = NaN; % just to be sure we cannot use it accidentally...
        end
        keyIsDown = 0; % will be used for measuring reaction times
        endRT = 0; keyCode = []; % reset these to assure correct RT calculation
        
        %% Flip Screen
        % from the help of Screen('Flip'):
        % Flip (optionally) returns a high-precision estimate of the system
        % time (in seconds) when the actual flip has happened in the return
        % argument 'VBLTimestamp'. An estimate of Stimulus-onset time is
        % returned in 'StimulusOnsetTime'. Beampos is the position of the
        % monitor scanning beam when the time measurement was taken (useful
        % for correctness tests). FlipTimestamp is a timestamp taken at the
        % end of Flip's execution. Use the difference between FlipTimestamp
        % and VBLTimestamp to get an estimate of how long Flips execution
        % takes. This is useful to get a feeling for the timing error if
        % you try to sync script execution to the retrace, e.g., for
        % triggering acquisition devices like EEG, fMRI, or for starting
        % playback of a sound. "Missed" indicates if the requested
        % presentation deadline for your stimulus has been missed. A
        % negative value means that dead- lines have been satisfied.
        % Positive values indicate a deadline-miss. The automatic detection
        % of deadline-miss is not fool-proof - it can report false
        % positives and also false negatives, although it should work
        % fairly well with most experimental setups. If you are picky about
        % timing, please use the provided timestamps or additional methods
        % to exercise your own tests.
        loopTime(end+1) = toc; % how long does it take to get here from the previous loop (after waiting for key/timeout)
        [VBLTimestamp lastFlipTimestamp FlipTimestamp Missed]=Screen('Flip', window, whenFlip);
        %         if Missed > 0 %% re-enable if clause for Not-self-paced
        %         experiment
        missedScreens{end+1} = [screenIdCurrent, VBLTimestamp lastFlipTimestamp FlipTimestamp Missed];
        %         end
        
        %% Listen for Keyboard input
        if timeout > 0
            %--------------------------------------------
            %- measure reaction time as good as possible
            
            response = 0;
            % check every millisecond for key being pressed -- only if
            % timeout not reached
            while (response == 0) && ((GetSecs - lastFlipTimestamp )<= timeout)
                [response, keyDownTimestamp] = getResponse(bitsiboxButtons,0.001, true);
            end
            
            %--------------------------------------------
            %- Post-process Keyboard press
            % calculate reaction time
            RT=(keyDownTimestamp-lastFlipTimestamp);
            % only if currently on offer screen, process key-responses
            if screenIdCurrent==4.3
                c.RT{c.iTrial} = RT; % save reaction time
                c.timeStampsChoice{c.iTrial} = VBLTimestamp; % just a time-stamp, so that I can relate the missed{} to c.RT{}
                c.answerKey{c.iTrial} = response;
                switch response
                    case ButtonA % left-most button
                        % if left-most button was meant to be accept, and
                        % it was pressed, then both are 1; if left was
                        % pressed, but right button was accept, then the
                        % offer was reject, ie c.accept == 0;
                        c.accepted(c.iTrial) = c.buttonAcceptIsLeft(c.iTrial);
                        
                    case ButtonB % second button from left
                        % see details above
                        c.accepted(c.iTrial) = ~c.buttonAcceptIsLeft(c.iTrial);
                    case 0 % ie no response, because too slow
                        c.accepted(c.iTrial) = KEY_NONE;
                        % if too slow, we don't have time to show a
                        % "highlighted" offer screen. Thus, go to feedback
                        % next
                        screenIdFollowing = 4.4;
                    otherwise
                        c.accepted(c.iTrial) = KEY_WRONG; % if several presssed, treat as wrong key pressed
                end
            end
            %             KbWait([],1); %wait for all keys to be released
        end
        
        % when we start a trial (i.e. fixation cross screen), send trigger
        % to ButtonBitisbox. --> saved to Eyetracker/Heart-rate monitoring 
        if screenIdCurrent == 4.1 % fixation screen id
            sendTrigger(bitsiboxButtons,120) % something else than one of the defined button-responses
        end
        
        
        % log timestamps, response, etc.
        fprintf(file_log, 'UG subj %i - Trial %i - VBLTimestamp screen %f : %f \n',subId, c.iTrial, screenIdCurrent, VBLTimestamp);
        fprintf(file_log, 'UG subj %i - Trial %i - lastFlipTimestamp screen %f : %f \n',subId, c.iTrial, screenIdCurrent, lastFlipTimestamp);
        fprintf(file_log, 'UG subj %i - Trial %i - FlipTimestamp screen %f : %f\n',subId, c.iTrial, screenIdCurrent, FlipTimestamp);
        fprintf(file_log, 'UG subj %i - Trial %i - Missed screen %f : %f\n',subId, c.iTrial, screenIdCurrent, Missed);
        %if timeout > 0 % ie listened for response
        if screenIdCurrent==4.3
            fprintf(file_log, 'UG subj %i - Trial %i - condition  %i\n',subId, c.iTrial, c.conditions(c.iTrial));
            fprintf(file_log, 'UG subj %i - Trial %i - Reaction time  %f\n',subId, c.iTrial, RT);
            fprintf(file_log, 'UG subj %i - Trial %i - Response/Button pressed  %i\n',subId, c.iTrial, response);
            fprintf(file_log, 'UG subj %i - Trial %i - Offer  %i\n',subId, c.iTrial, c.offers(c.iTrial));
            fprintf(file_log, 'UG subj %i - Trial %i - Accepted  %i\n',subId, c.iTrial, c.accepted(c.iTrial));
        end
        
        % check whether escape button on keyboard is being pressed, if so,
        % stop experiment.
        [keyisdown, when, keyCode] = KbCheck;
        if keyCode(KbName('escape'))
            disp('abort key pressed on keyboard... stopping experiment')
            run = 0;
        end
        
        tic; % toc is just before Screen Flip -- measure how long it takes to draw stuff...
        
    end
    
    % wait w/ blank screen for the end
    
    
    % ~~~~~~~~~~~~
    % clean up PTB
    % ~~~~~~~~~~~~
%     KbWait();
    %clean up before exit
    ShowCursor;
    Screen('CloseAll');
    %ListenChar(0);
    %return to olddebuglevel
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    %clc
    WaitSecs(1);
    
catch
    % save workspace before throwing error
    filename = ['workspace_' int2str(subId)];
    save('-v7',filename)
    disp('error caught');
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll'); %or sca
    % ListenChar(0);
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    %output the error message
    psychrethrow(psychlasterror);
end

% no matter how reaching this point, we want to update the cMain/cPractice
% with current state of c
switch c.id
    case 'practice'
        disp('saving cPractice')
        cPractice = c;
    case 'main'
        disp('saving cMain')
        cMain = c;
end

% save to config file
filename = ['config_' int2str(subId) '.mat'];
save('-v7',filename)

%% release bitsi-boxes
close_bitsi

diary off

end % ExperimentUG
% 

