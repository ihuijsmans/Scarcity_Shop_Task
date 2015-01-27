% Scarcity Games
% Wenwen Xie, edited by Inge Huijsmans
%
% Last editing: 2014-12-17
% Start editing: 2014-11-12
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


%%                          Set seed to date+time                        %%

rng shuffle

%% Scanerstuff

SCANNER = {'Skyra','Dummy','Debugging','Keyboard','buttonbox'}; SCANNER = SCANNER{4};

% setup bitsi stuff for button responses
setup_bits;

%%                       Set some directories                            %%

%WD for Dot Comparison
stimuli_dir_DComp = [cd '\Scarcity Stimuli\Dot Comparison\'];
%WD for Shape Matching
stimuli_dir_SMatch = [cd '\Scarcity Stimuli\Shape Matching\'];
%WD for General images
stimuli_dir_general = [cd '\Scarcity Stimuli\General\'];
%WD for instructions
instruct_dir = [cd '\Instructions\Practice_ST\'];
%Results
results_dir = [cd '\Results\'];


%% Screen stuff

%Skips the 'Welcome to psychtoolbox message' 
olddebuglevel=Screen('Preference', 'VisualDebuglevel', 1);

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
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

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
Screen('TextSize', window, 32)

KbName('UnifyKeyNames');

%%      Counterbalancing BS 

%Set ppnr
ppnr_str = openended(window, 'Participant Nr:', white);
ppnr = str2double(ppnr_str);

%Inform that computer is working
DrawFormattedText(window, 'Generating experiment configurations...\n\nOne moment please.', 'center','center', white);
Screen('Flip',window)

%Set condition
condition_txt = {'Scarcity'};
condition = 1;

%Counterbalance order of games
game_TXT = {'DComp', 'DCount', 'SMatch'};
games = [1,2,3];
c_games = perms(games);
game_order = c_games(mod(ppnr,6)+1,:);


%% General statements

nrtrials = 3;
txt_totaltoken ='Your total tokens: ';
[w_txt_totaltoken, ~] = RectSize(Screen('TextBounds',window,txt_totaltoken));
breaktext = 'The exeperiment is pauzed by the experimenter\n\nPlease wait for the experiment to restart';

%Stimulus durations
pt_dotclouds = 1;
pt_progressbar = 2;
timeout = 6;
instructtime = 5;
readinstructtime = 20;

practice_wintrial = {1,5,7,8};

% Dot Comparison Game
dotbaseRect = [0 0 200 300];
baseRect = [0 0 210 310];
squareXpos = [screenXpixels*0.35, screenXpixels*0.65];
numSquares = 2;
all_rects = nan(2,4);
question_DComp = {'Which rectangle contains more dots?'}; 

%Shape Matching game
question_SMatch = {'Do they match?'};


%% Make dot cloud stimuli for Dot Comparison game 

%Preallocate rectangles
clouds_DComp = cell(2,nrtrials*length(condition));

%Make dotclouds
for h = 1: (nrtrials*length(condition))
    for i = 1:numSquares

        %Make two rectangles on 2 different x positions
        Rect  = CenterRectOnPointd(dotbaseRect, squareXpos(i), yCenter);

        %Make two clouds of 30-40 dots
        numberdots=30+round(rand*10);
        
        %Preallocate cloud
        cloud = nan(2,numberdots);
        
        %Collect dots in variable cloud
        for k = 1:numberdots
            dotXpos = randsample(Rect(1):Rect(3),1);                                 
            dotYpos = randsample(Rect(2):Rect(4),1); 
            cloud(:,k) = [dotXpos,dotYpos];
        end
        clouds_DComp(i,h) = {cloud};
    end
end


%% Dot clouds for dot counting game

clouds_DCount = cell(1,nrtrials*length(condition));

%Save number of dots for Dot Count question
question_DCount = cell(1,nrtrials);

for h = 1: (nrtrials*length(condition))
    
    %Make two clouds of 30-40 dots
    numberdots=30+round(rand*10);
    
    %Preallocate cloud
    cloud = nan(2,numberdots);
    
    for k = 1:numberdots
        dotXpos  = randsample(windowRect(1):windowRect(3),1);
        dotYpos  = randsample(windowRect(2):windowRect(4),1);
        cloud(:,k) = [dotXpos,dotYpos];
    end
    clouds_DCount(h) = {cloud}; 
    question_DCount{h} = num2str(numberdots); 
end

%% Shape matching images

%Read images
listing = dir(stimuli_dir_SMatch);
filenames = char(listing.name);

%Preallocate images
images_SM = zeros(720, 960, 3, 'uint8');

%Read images       
for i = 4:length(filenames)
    if strcmp(filenames(i,:), 'Thumbs.db')
        continue
    end
    images_SM(:,:,:,i-3) = imread([stimuli_dir_SMatch filenames(i,:)]);
end

%Set textures
textures_SM = zeros(1,length(filenames)-4);

%Preallocate textures
for i = 1:length(textures_SM)
    textures_SM(i) = Screen('MakeTexture', window, images_SM(:,:,:,i));
end

textures_SM = shuffle(textures_SM);

%% Create a structure containing WS & BS counterbalancing 

c.condition_txt = condition_txt;
c.condition = condition;
c.c_game = game_order;
c.game_TXT = game_TXT;
c.left = {'Left', 'Less', 'Yes'};
c.right = {'Right', 'More', 'No'};
c.question = {repmat(question_DComp,[1,nrtrials]), question_DCount, repmat(question_SMatch,[1,nrtrials])};
c.tokens = [1, 10];

%% General images

%Read files
listing = dir(stimuli_dir_DComp);
filenames = char(listing.name);

%Preallocate images
progressbars = zeros(220, 150, 3, 'uint8');

%Read images
for i = 4:length(filenames)
    progressbars(:,:,:,i-3) = imread([stimuli_dir_DComp filenames(i,:)]);
end

%Make textures
tokenmin1 = Screen('MakeTexture', window, progressbars(:,:,:,1));
token0 = Screen('MakeTexture', window, progressbars(:,:,:,2));
tokenplus1 = Screen('MakeTexture', window, progressbars(:,:,:,3));
tokenplus10 = Screen('MakeTexture', window, progressbars(:,:,:,4));
tokenplus11 = Screen('MakeTexture', window, progressbars(:,:,:,5));
tokenplus2 = Screen('MakeTexture', window, progressbars(:,:,:,6));
tokenplus8 = Screen('MakeTexture', window, progressbars(:,:,:,7));
tokenplus9 = Screen('MakeTexture', window, progressbars(:,:,:,8));

%Read token reminding images
c.reminder = cell(1,2);
c.reminder{1} = imread([stimuli_dir_general 'zerotoken.jpg']);
c.reminder{2} = imread([stimuli_dir_general 'ninetoken.jpg']);

%Got product check
gotit = imread(strtrim([stimuli_dir_general 'gotit.JPG']));

%Not Got product cross
gotnot = imread(strtrim([stimuli_dir_general 'gotnot.JPG']));

%General images: Token allocation
alloc_token = imread([stimuli_dir_general 'tokenalloc.jpg']);
alloc_token = Screen('MakeTexture', window, alloc_token);
s_alloc_token = imread([stimuli_dir_general 's_token.JPG']);
s_alloc_token = Screen('MakeTexture', window, s_alloc_token);
a_alloc_token = imread([stimuli_dir_general 'a_token.jpg']);
a_alloc_token = Screen('MakeTexture', window, a_alloc_token);

c.alluc_token = {s_alloc_token, a_alloc_token};

%Start brain game
start1 = imread([stimuli_dir_general 'start1.jpg']);
start1 = Screen('MakeTexture', window, start1);

%Play round 2
round2 = imread([stimuli_dir_general 'round2.jpg']);
round2 = Screen('MakeTexture', window, round2);

%Stagegame instructions
instr_DCount1 = imread([stimuli_dir_general 'instr_DCount1.JPG']);
instr_DCount1 = Screen('MakeTexture', window, instr_DCount1);
instr_DComp1 = imread([stimuli_dir_general 'instr_DComp1.JPG']);
instr_DComp1 = Screen('MakeTexture', window, instr_DComp1);
instr_SMatch1 = imread([stimuli_dir_general 'instr_SMatch1.JPG']);
instr_SMatch1 = Screen('MakeTexture', window, instr_SMatch1);

instr_DCount2 = imread([stimuli_dir_general 'instr_DCount2.JPG']);
instr_DCount2 = Screen('MakeTexture', window, instr_DCount2);
instr_DComp2 = imread([stimuli_dir_general 'instr_DComp2.JPG']);
instr_DComp2 = Screen('MakeTexture', window, instr_DComp2);
instr_SMatch2 = imread([stimuli_dir_general 'instr_SMatch2.JPG']);
instr_SMatch2 = Screen('MakeTexture', window, instr_SMatch2);

c.instr_stagegame = {[instr_DComp1, instr_DCount1, instr_SMatch1], [instr_DComp2, instr_DCount2, instr_SMatch2]};

%End
end1 = imread([stimuli_dir_general 'end1.JPG']);
end1 = Screen('MakeTexture', window, end1);

%Final instructions
final_instruct1 = imread([stimuli_dir_general 'final_instruct1.JPG']);
final_instruct1 = Screen('MakeTexture', window, final_instruct1);
final_instruct2 = imread([stimuli_dir_general 'final_instruct2.JPG']);
final_instruct2 = Screen('MakeTexture', window, final_instruct2);

%Switch to other task
s_switchtoken = imread([stimuli_dir_general 's_switchtoken.JPG']);
s_switchtoken = Screen('MakeTexture', window, s_switchtoken);
a_switchtoken = imread([stimuli_dir_general 'a_switchtoken.JPG']);
a_switchtoken = Screen('MakeTexture', window, a_switchtoken);

c.switchtoken = {s_switchtoken, a_switchtoken};

%Return stagegame
return_stagegame = imread([stimuli_dir_general 'return_stagegame.JPG']);
return_stagegame = Screen('MakeTexture', window, return_stagegame);

%Intructions shoptask
inst_shoptask = imread([stimuli_dir_general 'inst_shoptask.JPG']);
inst_shoptask = Screen('MakeTexture', window, inst_shoptask);

%Intructions shoptask
a_end_G1 = imread([stimuli_dir_general 'a_end_G1.JPG']);
a_end_G1 = Screen('MakeTexture', window, a_end_G1);
a_end_G2 = imread([stimuli_dir_general 'a_end_G2.JPG']);
a_end_G2 = Screen('MakeTexture', window, a_end_G2);
a_end_G3 = imread([stimuli_dir_general 'a_end_G3.JPG']);
a_end_G3 = Screen('MakeTexture', window, a_end_G3);

s_end_G1 = imread([stimuli_dir_general 's_end_G1.JPG']);
s_end_G1 = Screen('MakeTexture', window, s_end_G1);
s_end_G2 = imread([stimuli_dir_general 's_end_G2.JPG']);
s_end_G2 = Screen('MakeTexture', window, s_end_G2);
s_end_G3 = imread([stimuli_dir_general 's_end_G3.JPG']);
s_end_G3 = Screen('MakeTexture', window, s_end_G3);

c.end_G1_G3 = {[s_end_G1, s_end_G2, s_end_G3], [a_end_G1, a_end_G2, a_end_G3]};

%Practice images: failing :)
U_end = imread([stimuli_dir_general 'U_end.JPG']);
U_end = Screen('MakeTexture', window, U_end);

U_gameover = imread([stimuli_dir_general 'U_game over.JPG']);
U_gameover = Screen('MakeTexture', window, U_gameover);

%%                       Prepare saving data                             %%

%Prepare data logging
time = datestr(now, 'DD-HH-MM');
filename = [results_dir,  sprintf('Scarcity_Practice_ppnr_%i_time_%s_data.txt', ppnr, time)];
fid = fopen(filename,'a+t');
fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'ppnr','totaltrial', 'blocktrial','block','condition_AS', 'game', 'screenID', 'mainstart', 'flip_onset', 'VBLTimestamp', 'lastFlipTimestamp', 'FlipTimestamp', 'MissedFlip','presenttime', 'response', 'RT', 'tokens');

%Save first timing
mainstart=tic;
t_filename = [results_dir,  sprintf('Scarcity_Practice_ppnr_%i_time_%s_timing.txt', ppnr, time)];
ft_id = fopen(t_filename,'a+t');
fprintf(ft_id, '%s\n', 'mainstart');
fprintf(ft_id, '%s\n', mainstart);


%%               Variables from the inserted experiment                  %%

%Load all vars
vars = ShopTaskPrep_Practice;
vars.reminder = c.reminder;
vars.gotit = gotit;
vars.gotnot = gotnot;

%Prep saving
filename = [results_dir,  sprintf('CD_Practice_ppnr_%i_time_%s_data.txt', ppnr, time)];
fid_newtask = fopen(filename,'a+t');
fprintf(fid_newtask, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'ppnr', 'condition_S/A', 'totaltrial','trial','screenId', 'presenttime', 'lastFlipTimestamp', 'flip_stamp','startbid', 'bid_round', 'bid', 'computerprice', 'gotit','RT', 'condition', 'brand', 'product', 'filename', 'retailprice');

%Prep saving
filename = [results_dir,  sprintf('CD_Practice_ppnr_%i_time_%s_slider.txt', ppnr, time)];
fid_slider = fopen(filename,'a+t');
fprintf(fid_slider, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'trial', 'flip_nr', 'handle_x','response', 'fliptimestamp', 'tmp_bid','RT', 'VBLTimestamp', 'BidFlipTimestamp', 'FlipTimestamp', 'MissedFlip', 'ppnr', 'block','condition_txt', 'total_trial');


%% Start game

%Count & trackers
tottrialcounter = 1;
block = 0;
quit = 0;
screenID  = 1;
nextblock = 0;

%% Instructions
nextkey = 'rightarrow';
backkey = 'leftarrow';

instructions(window, instruct_dir, 1:8, nextkey, backkey);

for k = 1:length(c.condition)   
    
    screenID  = 1.3;

    instr = 1;

    %Set reminder for Shoptask
    reminder = c.reminder{c.condition(k)}; 
   
    while instr
        switch screenID
                
            case 1.3
                %% Start SBG
                Screen('DrawTexture', window, start1, [], [], 0);
                presenttime=instructtime;

                screenID = 1.4;
                
            case 1.4

                %% Allocate tokens
                Screen('DrawTexture', window, alloc_token, [], [], 0);
                presenttime=instructtime;

                screenID = 1.5;

            case 1.5

                %% Assign tokens
                Screen('DrawTexture', window, c.alluc_token{c.condition(k)}, [], [], 0);
                presenttime=instructtime;

                %Break instructions
                instr = 0;
                
                  
        end   

    [VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip] = Screen('Flip', window);
    WaitSecs(presenttime);
    
    end
    
    %To instructions about stage game
    screenID = 1.1;

    tokens = c.tokens(c.condition(k));
    
    for j =1:length(c.c_game)
        
        ending = 0;
        
        if quit == 1
            break
        end
        
        %Reset count & trackers for each block
        run = 1;
        nrtrialcounter = 1;
        
        while run

            switch screenID
                
                %% Instructions
                case 1.1
                    
                    %% Start with stage game instr pt1
                    %Per different game
                    Screen('DrawTexture', window, c.instr_stagegame{1}(c.c_game(j)), [], [], 0);
                    presenttime=instructtime;
                    
                    %Reset trackers for each trial
                    response = 0;
                    RT = 0;
                    screenID = 1.15;
                    
                case 1.15
                    %% Start with stage game instr pt2
                    %Per different game
                    Screen('DrawTexture', window, c.instr_stagegame{2}(c.c_game(j)), [], [], 0);
                    presenttime=readinstructtime;
                    
                    %Reset trackers for each trial
                    response = 0;
                    RT = 0;
                    screenID = 2;
                    
                    
                %% Experiment     
                case 2
                    
                    %% Fixation cross
                    Screen('DrawText',window, '+', xCenter, yCenter, white);

                    %Presenttime fixation cross
                    presenttime=0.5+rand(1);

                    %Reset trackers for each trial
                    response = 0;
                    RT = 0;            
                    
                    %Nextscreen 
                    screenID = 3;

                case 3
                    %% Present game images
                    
                    switch c.game_TXT{c.c_game(j)}
                        case 'DComp'
                            %Draw two rects with dots
                            for i = 1:numSquares
                                Screen('FrameRect', window, white, CenterRectOnPointd(baseRect, squareXpos(i), yCenter), penWidthPixels);
                                Screen('DrawDots', window, clouds_DComp{i,nrtrialcounter}, 6, white, [],2);
                            end
                        case 'DCount'
                            %Draw one dot cloud
                            Screen('DrawDots', window, clouds_DCount{nrtrialcounter}, 6, white, [],2);
                        case 'SMatch'
                            %Draw Shapes
                            Screen('DrawTexture', window, textures_SM(nrtrialcounter), [], [], 0);   
                    end

                    %Present screen
                    presenttime=pt_dotclouds;

                    %Next Screen
                    screenID = 4;

                case 4 
                    %% Ask to select an answer option             
                   
                    %Draw Q + answer options
                    DrawFormattedText(window, c.question{c.c_game(j)}{nrtrialcounter}, 'center', 0.407*hth, white);

                    %Set color of left/right, & nextscreen
                    if response == 0
                        color = {white, white};
                        presenttime = 0;
                    elseif response == ButtonA
                        color = {yellow, white};
                        screenID = 5;
                        presenttime = 1;
                    else
                        color = {white, yellow};
                        screenID = 5;
                        presenttime = 1;
                    end
                 
                    Screen('DrawText', window, c.left{c.c_game(j)}, 0.343*wth, 0.685*hth, color{1});
                    Screen('DrawText', window, c.right{c.c_game(j)}, 0.63*wth, 0.685*hth, color{2});

                case 4.1
                    %% Too slow
                    DrawFormattedText(window, 'Too slow!', 'center', 'center', red);

                    %Present screen
                    presenttime=1;

                    %Make them redo the trial: Fixation cross
                    screenID = 2;

                case 4.2
                    %% Wrong button
                    DrawFormattedText(window, 'Wrong button!', 'center', 'center', red);

                    %Present screen
                    presenttime=1;

                    %Make them redo the trial: Fixation cross
                    screenID = 2;

                case 5
                    %% Ask to select an answer option             
                   
                    %Draw Q + answer options
                    DrawFormattedText(window, c.question{c.c_game(j)}{nrtrialcounter}, 'center', 0.407*hth, white);                 
                    Screen('DrawText', window, c.left{c.c_game(j)}, 0.343*wth, 0.685*hth, color{1});
                    Screen('DrawText', window, c.right{c.c_game(j)}, 0.63*wth, 0.685*hth, color{2});
                    
                    %% Feedback, did they win tokens?
                    switch tottrialcounter
                        case practice_wintrial
                            DrawFormattedText(window, 'You win 1 token!', 'center', 'center', green);
                            tokens = tokens + 1;
                        otherwise
                            DrawFormattedText(window, 'You lose 1 token!', 'center', 'center', red);
                            tokens = tokens - 1;
                    end

                    %Present screen jittered
                    presenttime=1+2*rand(1);

                    %Next screen: Progress bar
                    screenID = 6;   

                case 6
                    %% Present progressbar

                    %Progress
                    txt_nrtokens = num2str(round(tokens));

                   
                    switch tokens
                        case {1 2 8 9 10 11}   
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
                    DrawFormattedText(window,txt_totaltoken, 'center', 0.546*hth, white);
                    DrawFormattedText(window,txt_nrtokens, xCenter +(w_txt_totaltoken/2)+20, 0.546*hth, color);

                    %Present screen
                    presenttime = pt_progressbar;
                    
                    screenID = 2;
                   
                    %Track trialnumbers
                    nrtrialcounter = nrtrialcounter + 1;
                    tottrialcounter = tottrialcounter +1;
                        
                    
                    
                case 999
                    %% Break the experiment in order to continue later
                    
                    %draw it all
                    DrawFormattedText(window,breaktext, 'center', 0.46*hth, white);
                    
                    %Wait for buttonpress
                    presenttime = inf;
                    
                case 888
                    %% Close it all down Pt 1
                    
                    Screen('DrawTexture', window, U_end, [], [], 0);
                    presenttime = instructtime;
                    ending = 1;
                    
                    screenID = 889;
                    
                case 889
                    %% Close it all down Pt 2
                                        
                    Screen('DrawTexture', window, U_gameover, [], [], 0);
                    presenttime = instructtime;
                    
                    screenID = 890;
                    
                case 890
                    
                    DrawFormattedText(window,'You will be redirected to the intruction page', 'center', 'center', white);
                    presenttime = instructtime;
                    
                    screenID = 891;
                   
                    run = 0;                    
                    
            end

            %% Flip it
            [VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip] = Screen('Flip', window);
            flip_onset=toc(mainstart);
            
                        
            %% Wait for response
            if presenttime == 0
                if response == 0
                    while (response == 0) && ((GetSecs - lastFlipTimestamp )<= timeout)

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
                    %Next Block
                    elseif response == ButtonE
                        screenID = 1.1;
                        run = 0;
                        break
                    %Close All
                    elseif response == ButtonD
                        run = 0;                        
                        quit = 1;
                        Screen('CloseAll');                       
                    %Pauze
                    elseif response == ButtonF
                        screenID = 999;
                    %Wrong button
                    else
                        screenID = 4.2;

                    end
                end
            elseif presenttime == inf
                while presenttime
                    %Continue experiment when hitting spacebar
                    [~, keyCode, ~] = KbWait;
                    if  strcmp(KbName(keyCode), 'space')
                        presenttime = 0;
                        %Restart trial
                        screenID = 2;
                        break
                    end
                end
            end
     
            %Hold it on screen
            WaitSecs(presenttime);
            
            if screenID == 891
                run = 0;
                break;
            end
                            
                     
            
            %After nrtrials per stagegame, switch to next stagegame
            if (j == 1 || j == 2) && nrtrials+1 <= nrtrialcounter
                screenID = 1.1;
                run = 0;
                break
            end
            
            %After nrtrials per stagegame, switch to next stagegame
            if j == 3 && nrtrials+1 <= nrtrialcounter && ending == 0
                screenID = 888;
            end
            
            %Save everything all the time
            fprintf(fid, '%i\t%i\t%i\t%i\t%s\t%s\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\n', ppnr, tottrialcounter, nrtrialcounter, j, c.condition_txt{c.condition(k)}, c.game_TXT{c.c_game(j)}, screenID, mainstart, flip_onset, VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip, presenttime, response, RT, tokens); 

            %Check if escape was pressed
            [keyisdown, when, keyCode] = KbCheck;
            if keyCode(KbName('escape'))
                disp('abort key pressed on keyboard... stopping experiment');
                Screen('CloseAll');
                run = 0;
                quit = 1;
            elseif keyCode(KbName('a'))
                screenID = 999;
            elseif keyCode(KbName('b'))
                run = 0;
                break
            end
        end
    end
end

%Instructions Shoptask
instructions(window, instruct_dir, 9:16, nextkey, backkey);

%Practice Shoptask
ShopTask_Practice(window, vars, 1, 1, ppnr, mainstart, 1, fid_newtask, fid_slider, SCANNER);

%Instructions real experiment
instructions(window, instruct_dir, 17:18, nextkey, backkey);
       
Screen('CloseAll');      
