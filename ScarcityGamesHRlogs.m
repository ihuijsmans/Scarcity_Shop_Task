%% HR Logfiles
%
% Set all events for heart rate trigger
%
% Inge Huijsmans 2014-12-18


%Instruction screen logs
HR_scan = 0;
HR_Instructions_Pt1 = 1;
HR_Instructions_Pt2 = 2;
HR_start_SBG = 3;
HR_allocate_tokens = 4;
HR_Instructions_stageG_Pt1 = 5;
HR_Instructions_stageG_Pt2 = 6;
HR_Instructions_ST = 7;
HR_return_stageG = 8;
HR_end_stageG = 9;
HR_close_Pt1 = 10;
HR_close_Pt2 = 11;
HR_pauze = 12;
HR_quit = 13; %manual quit

%Scarcity first
c.HR_token = {13,14};
c.HR_token_before_shoptask = {15,16};

%Trial logs (scarcity first)
c.HR_fixcross = {31,51};
c.HR_image = {32,52};
c.HR_question = {33,53};
c.HR_response = {34,54};
c.HR_winlose = {35,55};
c.HR_progressbar = {36,56};
c.HR_slow = {37,57};
c.HR_wrongbutton = {38,58};






