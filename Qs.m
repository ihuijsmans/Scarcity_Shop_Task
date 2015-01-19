%% Get questionnaire information
% Inge Huijsmans
% 2014-12-17
%
% This is a seperate script to attain demographic information and
% administer questionnares.
%
% Script opens a screen and calls qs_demographic function

%Change WD
SCANNER = {'Skyra','Dummy','Debugging','Keyboard','buttonbox'}; SCANNER = SCANNER{4};

% setup bitsi stuff for button responses
setup_bits;

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

%%      Counterbalancing BS 

%Set ppnr
ppnr_str = openended(window, 'Participant Nr:', white);
ppnr = str2double(ppnr_str);

%% Saving

%Results dir
results_dir = [cd '\Results\'];

%Prepare data logging
time = datestr(now, 'DD-HH-MM');
filename = [results_dir,  sprintf('Demographics_ppnr_%i_time_%s_data.txt', ppnr, time)];
fid = fopen(filename,'a+t');
labels = {'q_nr','response','question', 'RT','Questionnaire','ppnr'};

%Make questionnaires
feedback = Qs_demographics(window, ppnr);
feedback = feedback.';

%Save data
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\n',labels{:});
fprintf(fid,'%i\t%s\t%s\t%i\t%s\t%i\n',feedback{:});

%%                  Finished instructions                                %%

instruct_dir = [cd '\Instructions\Qs\'];
nextkey = 'rightarrow';
backkey = 'leftarrow';

instructions(window, instruct_dir, 8, nextkey, backkey);

Screen('CloseAll')
return