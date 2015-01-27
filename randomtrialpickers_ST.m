 %% Random Trial Picker
%
% Inge Huijsmans
% 2014-12-18
%
% Demonstrates trialnumbers on screen. Participants can select their trial 
% number by pressing spacebar. Returns their winning trial.

SCANNER = {'Skyra','Dummy','Debugging','Keyboard','buttonbox'}; SCANNER = SCANNER{4};

%setup bitsi stuff for button responses
setup_bits;

%WD for wintrials
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
Screen('TextSize', window, 32);

KbName('UnifyKeyNames');

%% Load trials

ppnr_str = openended(window, 'Participant Nr:', white);
ppnr = str2double(ppnr_str);

trials = load([results_dir sprintf('wintrial_ST_%i.mat', ppnr)]);
trials = trials.trialpicker;
trialnumbers = 1:length(trials);
s_trialnumbers = shuffle(trialnumbers);

%% Pick a trialnumber

lastFlipTimestamp = Screen('Flip',window,0);
choice = 1;

[keyIsDown, ~, ~, ~] = KbCheck;
while keyIsDown
    [keyIsDown, ~, ~, ~] = KbCheck;
end
    
while choice
    i = round(rand*144);
    Screen('DrawText', window, sprintf('%i',i), xCenter, yCenter, white);
    lastFlipTimestamp = Screen('Flip', window, lastFlipTimestamp+0.2);   
    [~, ~, keyCode, ~] = KbCheck;
    answer = lower(KbName(keyCode));
    if strcmp(answer, 'space')
        choice = 0;
        WaitSecs(3); 
    end 
end

%Display winning trial
a = 'ppnr Trialnr gotit(1 = no) retailprice discountprice brand   product';
disp(a);
disp([ppnr, trials(i,:)]);
 

%Save winning trial
win_file = [results_dir, sprintf('WinningTrial_%i.txt', ppnr)];
ft_id = fopen(win_file,'a+t');
fprintf(ft_id, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'ppnr', 'Trialnr', 'gotit', 'retailprice', 'discountprice', 'brand', 'product');
fprintf(ft_id, '%i\t%i\t%.2f\t%.2f\t%s\t%s', ppnr, trials{i,:});

 
KbWait;


Screen('CloseAll'); 





















