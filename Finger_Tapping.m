function Finger_Tapping(window, slides, fid, ppnr, mainstart)
%
% This function instructs participants to tap their index finger against
% their thumb twice for 10 seconds, interrupted by a 10 second break.


%% Screen stuff

%Get rid of mouse cursor
HideCursor;

%Other applications compete with windows for resources. These lines make
%sure matlab wins.
prioritylevel=MaxPriority(window); 
Priority(prioritylevel);

%% Make instruction pages textures

instr_slides = zeros(1,length(slides(1,1,1,:)));

for image = 1:length(slides(1,1,1,:))
    instr_slides(1,image) = Screen('MakeTexture', window, slides(:,:,:,image));
end


%%                          Start the loop                               %%    

screenID = 1;
run = 1;
nrtaps = 2;
tapcount = 0;
whenflip = 0;

%Set Timing stuff
LastFlipTimeStamp = Screen('Flip', window, whenflip);
time = toc(mainstart);

%Save first flip
fprintf(fid, '%i\t%i\t%.6f\t%i\t%.6f\n', ppnr, screenID, LastFlipTimeStamp, whenflip, time);

while run
    switch screenID
        case 1
            %% Instructions what
            Screen('DrawTexture', window, instr_slides(1), [], [], 0);
            whenflip = 0.1;
            screenID = 2;
        case 2
            %% Instructions how
            Screen('DrawTexture', window, instr_slides(2), [], [], 0);
            whenflip = 10;
            screenID = 3;
        case 3
            %% Instructions when
            Screen('DrawTexture', window, instr_slides(3), [], [], 0);
            whenflip = 10;
            screenID = 4;
        case 4
            %% Red Dot
            Screen('DrawTexture', window, instr_slides(4), [], [], 0);
            whenflip = 10;
            screenID = 5;
            
            tapcount = tapcount +1;
            
        case 5
            %% 10 second break
            Screen('DrawTexture', window, instr_slides(5), [], [], 0);
            whenflip = 10;
            
            if nrtaps <= tapcount
                screenID = 7;
            else 
                screenID = 6;
            end
            
        case 6
            %% Restart tapping
            Screen('DrawTexture', window, instr_slides(6), [], [], 0);
            whenflip = 10;
            screenID = 4;
        case 7
            %% Finished tapping
            Screen('DrawTexture', window, instr_slides(7), [], [], 0);
            whenflip = 10;
            screenID = 8;
    end
    
    LastFlipTimeStamp = Screen('Flip', window, LastFlipTimeStamp + whenflip);  

    if screenID == 8 
        WaitSecs(9.9);
        run = 0;
    end
    
    time = toc(mainstart);
    fprintf(fid, '%i\t%i\t%.6f\t%i\t%.6f\n', ppnr, screenID, LastFlipTimeStamp, whenflip, time);
    
    
    
end

end
