% Scarcity Games Preperation.
% Inge Huijsmans
% 2015-2-27
%
% Counterbalancing and preperation for Scarcity Games

%%                  Start with setting directories                           %%


%WD for Dot Comparison
stimuli_dir_DComp = [cd '/Scarcity Stimuli/Dot Comparison/'];
%WD for Shape Matching
stimuli_dir_SMatch = [cd '/Scarcity Stimuli/Shape Matching/'];
%WD for General images
stimuli_dir_general = [cd '/Scarcity Stimuli/General/'];
%WD for instructions
instruct_dir = [cd '/Instructions/Qs/'];
%WD for instructions
instruct_Finger_Tap_dir = [cd '/Instructions/Finger Tapping/'];

%%                          Counterbalancing BS                          %% 
        
%Set condition
condition_txt = {'Scarcity', 'Abundance'};

if (mod(ppnr,8)+1)<5;
    condition = [1,2];
else
    condition = [2,1];
end

%Counterbalance order of games
game_TXT = {'DComp', 'DCount', 'SMatch'};
games = [1,2,3];
c_games = perms(games);
game_order = c_games(mod(ppnr,6)+1,:);

%%                        Fixed feedback                                 %%

wintrial_1 = {3,5,6,7,11,13,15,16,17,20,23,24,27,28,30};
wintrial_2 = {2,4,7,9,10,11,13,17,18,21,23,25,27,28,29,30};
wintrial_3 = {3,4,8,10,13,14,15,17,21,23,24,27,29,30};

stop_1 = 27;
stop_2 = 25;
stop_3 = 23;


%%                     SG: Visual stimuli                                %%

%Dot comparison
dotbaseRect = [0 0 200 300];
baseRect = [0 0 210 310];
numSquares = 2;
question_DComp = {'Which rectangle contains more dots?'}; 

%Shape Matching
question_SMatch = {'Do they match?'};

% Dot Comparison Game 
squareXpos = [screenXpixels*0.35, screenXpixels*0.65];

%%              Make dot cloud stimuli for Dot Comparison game           %%

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
        c.clouds_DComp(i,h) = {cloud};
    end
end

%%                  Dot clouds for dot counting game                     %%

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
    c.clouds_DCount(h) = {cloud}; 
    question_DCount{h} = num2str(numberdots); 
end

%%                           Shape matching images                       %%

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
    images_SM(:,:,:,i-3) = imread(strtrim([stimuli_dir_SMatch filenames(i,:)]));
end

c.images_SM = images_SM;

%%         Create a structure containing WS & BS counterbalancing        %%

c.condition_txt = condition_txt;
c.condition = condition;
c.c_game = game_order;
c.game_TXT = game_TXT;
c.wintrials = {wintrial_1; wintrial_2; wintrial_3};
c.left = {'Left', 'Less', 'Yes'};
c.right = {'Right', 'More', 'No'};
c.question = {repmat(question_DComp,[1,nrtrials]), question_DCount, repmat(question_SMatch,[1,nrtrials])};
c.stop = [stop_1, stop_2, stop_3];
c.starttoken = {[1,1,3],[10,10,12]};
c.token = {ones(3,30),ones(3,30)*10};

%Create number of tokens in account according to wintrials
for condition = 1:2
    for gamenr = 1:3
        starttoken = c.starttoken{condition}(gamenr);
        for i = 1:nrtrials
            switch i
                case c.wintrials{gamenr,:}
                    starttoken = starttoken + 1;
                otherwise
                    starttoken = starttoken - 1;
            end
            c.token{condition}(gamenr,i) = starttoken;
        end
    end
end

c.tokens = [1, 10];

 %%                          General task images                          %%

%Read token reminding images
c.reminder = cell(1,2);
c.reminder{1} = imread(strtrim([stimuli_dir_general 'zerotoken.JPG']));
c.reminder{2} = imread(strtrim([stimuli_dir_general 'ninetoken.JPG']));



%%                          General task images                          %%

%Read files
listing = dir(stimuli_dir_DComp);
filenames = char(listing.name);

%Preallocate images
progressbars = zeros(220, 150, 3, 'uint8');

%Read images
for i = 4:length(filenames)
    progressbars(:,:,:,i-3) = imread(strtrim([stimuli_dir_DComp filenames(i,:)]));
end

%Make textures
tokenmin1 = Screen('MakeTexture', window, progressbars(:,:,:,1));
token0 = Screen('MakeTexture', window, progressbars(:,:,:,2));
tokenplus1 = Screen('MakeTexture', window, progressbars(:,:,:,3));
tokenplus10 = Screen('MakeTexture', window, progressbars(:,:,:,4));
tokenplus11 = Screen('MakeTexture', window, progressbars(:,:,:,5));
tokenplus12 = Screen('MakeTexture', window, progressbars(:,:,:,6));
tokenplus2 = Screen('MakeTexture', window, progressbars(:,:,:,7));
tokenplus3 = Screen('MakeTexture', window, progressbars(:,:,:,8));
tokenplus8 = Screen('MakeTexture', window, progressbars(:,:,:,9));
tokenplus9 = Screen('MakeTexture', window, progressbars(:,:,:,10));

%Read token reminding images
c.reminder = cell(1,2);
c.reminder{1} = imread(strtrim([stimuli_dir_general 'zerotoken.JPG']));
c.reminder{2} = imread(strtrim([stimuli_dir_general 'ninetoken.JPG']));

%General images: Token allocation
alloc_token = imread(strtrim([stimuli_dir_general 'tokenalloc.JPG']));
c.alloc_token1 = Screen('MakeTexture', window, alloc_token);
s_alloc_token = imread(strtrim([stimuli_dir_general 's_token.JPG']));
s_alloc_token = Screen('MakeTexture', window, s_alloc_token);
a_alloc_token = imread(strtrim([stimuli_dir_general 'a_token.JPG']));
a_alloc_token = Screen('MakeTexture', window, a_alloc_token);

c.alluc_token = {s_alloc_token, a_alloc_token};

%Instruction reminders
start1 = imread(strtrim([stimuli_dir_general 'start1.JPG']));
c.start1 = Screen('MakeTexture', window, start1);

%Stagegame instructions
instr_DCount1 = imread(strtrim([stimuli_dir_general 'instr_DCount1.JPG']));
instr_DCount1 = Screen('MakeTexture', window, instr_DCount1);
instr_DComp1 = imread(strtrim([stimuli_dir_general 'instr_DComp1.JPG']));
instr_DComp1 = Screen('MakeTexture', window, instr_DComp1);
instr_SMatch1 = imread(strtrim([stimuli_dir_general 'instr_SMatch1.JPG']));
instr_SMatch1 = Screen('MakeTexture', window, instr_SMatch1);

instr_DCount2 = imread(strtrim([stimuli_dir_general 'instr_DCount4.JPG']));
instr_DCount2 = Screen('MakeTexture', window, instr_DCount2);
instr_DComp2 = imread(strtrim([stimuli_dir_general 'instr_DComp4.JPG']));
instr_DComp2 = Screen('MakeTexture', window, instr_DComp2);
instr_SMatch2 = imread(strtrim([stimuli_dir_general 'instr_SMatch4.JPG']));
instr_SMatch2 = Screen('MakeTexture', window, instr_SMatch2);

instr_DCount3 = imread(strtrim([stimuli_dir_general 'instr_DCount5.JPG']));
instr_DCount3 = Screen('MakeTexture', window, instr_DCount3);
instr_DComp3 = imread(strtrim([stimuli_dir_general 'instr_DComp5.JPG']));
instr_DComp3 = Screen('MakeTexture', window, instr_DComp3);
instr_SMatch3 = imread(strtrim([stimuli_dir_general 'instr_SMatch5.JPG']));
instr_SMatch3 = Screen('MakeTexture', window, instr_SMatch3);

c.instr_stagegame = {[instr_DComp1, instr_DCount1, instr_SMatch1], [instr_DComp2, instr_DCount2, instr_SMatch2], [instr_DComp3, instr_DCount3, instr_SMatch3]};

%End
end1 = imread(strtrim([stimuli_dir_general 'end1.JPG']));
c.end1 = Screen('MakeTexture', window, end1);

%Switch to other task
s1_switchtoken = imread(strtrim([stimuli_dir_general 's_switchtoken.JPG']));
s1_switchtoken = Screen('MakeTexture', window, s1_switchtoken);
a1_switchtoken = imread(strtrim([stimuli_dir_general 'a_switchtoken.JPG']));
a1_switchtoken = Screen('MakeTexture', window, a1_switchtoken);

c.switchtoken = [s1_switchtoken, a1_switchtoken];

%Return stagegame
return_stagegame = imread(strtrim([stimuli_dir_general 'return_stagegame.JPG']));
c.return_stagegame = Screen('MakeTexture', window, return_stagegame);

%Intructions shoptask
inst_shoptask1 = imread(strtrim([stimuli_dir_general 'BT_instr1.JPG']));
inst_shoptask1 = Screen('MakeTexture', window, inst_shoptask1);

inst_shoptask2 = imread(strtrim([stimuli_dir_general 'BT_instr2.JPG']));
inst_shoptask2 = Screen('MakeTexture', window, inst_shoptask2);

%Got product check
gotit = imread(strtrim([stimuli_dir_general 'gotit.JPG']));

%Not Got product cross
gotnot = imread(strtrim([stimuli_dir_general 'gotnot.JPG']));

%Go to next round of games
s_endtoken = imread(strtrim([stimuli_dir_general 's_endtoken.JPG']));
s_endtoken = Screen('MakeTexture', window, s_endtoken);
a_endtoken = imread(strtrim([stimuli_dir_general 'a_endtoken.JPG']));
a_endtoken = Screen('MakeTexture', window, a_endtoken);

c.endtoken = {s_endtoken, a_endtoken};

%Intructions shoptask
a_end_G1 = imread(strtrim([stimuli_dir_general 'a_end_G1.JPG']));
a_end_G1 = Screen('MakeTexture', window, a_end_G1);
a_end_G2 = imread(strtrim([stimuli_dir_general 'a_end_G2.JPG']));
a_end_G2 = Screen('MakeTexture', window, a_end_G2);
a_end_G3 = imread(strtrim([stimuli_dir_general 'a_end_G3.JPG']));
a_end_G3 = Screen('MakeTexture', window, a_end_G3);

s_end_G1 = imread(strtrim([stimuli_dir_general 's_end_G1.JPG']));
s_end_G1 = Screen('MakeTexture', window, s_end_G1);
s_end_G2 = imread(strtrim([stimuli_dir_general 's_end_G2.JPG']));
s_end_G2 = Screen('MakeTexture', window, s_end_G2);
s_end_G3 = imread(strtrim([stimuli_dir_general 's_end_G3.JPG']));
s_end_G3 = Screen('MakeTexture', window, s_end_G3);

c.end_G1_G3 = {[s_end_G1, s_end_G2, s_end_G3], [a_end_G1, a_end_G2, a_end_G3]};


%%                       Finger tapping imload                           %%     

%Read images                                                                     
listing = dir(instruct_Finger_Tap_dir);                                          
filenames = char(listing.name);                                                  

%Preallocate images                                                              
images_FT = zeros(720, 960, 3, length(filenames)-3, 'uint8');

%Read images       
for i = 3:length(filenames)
    if strcmp(strtrim(filenames(i,:)), 'Thumbs.db')
        continue
    end
    images_FT(:,:,:,i-2) = imread(strtrim([instruct_Finger_Tap_dir filenames(i,:)]), 'JPG');
end
