function instructions(window, instruct_dir, slidenrs, nextkey, backkey)
%Inge Huijsmans
%Written on
%11-3-2014
%
%Last update: 4-11, corrected while operator.
%
%This function displays intructions in the form of .jpg pictures (made by
%powerpoint).
%
%Save images in wd\Instructions\Slide.jpg
%
%Input:
%Window = window screen
%slidenrs = which slides do you want to present
%Nextkey = key with which participants go to the following screen
%Backkey = key with which participants go to the previous screen

%Set counter
goback = 0;
exit = KbName('escape');
nextkey = KbName(nextkey);
backkey = KbName(backkey);

%Images
tmpim = zeros(720, 960, 'uint8');

%First wait for release of all keys
[keyIsDown,~,~] = KbCheck;
while keyIsDown
    [keyIsDown,~,~] = KbCheck;
end


while goback < length(slidenrs)  
    %Read image
    if ispc
        tmpim = imread([instruct_dir, sprintf('\\Slide%d', slidenrs(goback+1)), '.jpg']);
    else
        tmpim = imread([instruct_dir, sprintf('Slide%d', slidenrs(goback+1)), '.JPG']);
    end
    %Set image
    imageTexture = Screen('MakeTexture', window, tmpim);
    %Print on screen
    Screen('DrawTexture', window, imageTexture, [], [], 0); 
    % FLIPIT :)
    Screen('Flip', window);
    WaitSecs(0.01);

    %Wait for keypresses
    while ~keyIsDown
        [keyIsDown,~, keyCode] = KbCheck;
        answer = keyCode;
    end
    
    while keyIsDown
        [keyIsDown,~, keyCode] = KbCheck;
    end
    %Wait for key release
%     while keyIsDown
%         [keyIsDown,~, keyCode] = KbCheck;
%         answer = keyCode;
%     end
    if find(answer) == nextkey
        goback = goback+1;
    elseif find(answer) == backkey
        if goback >= 1  
            goback = goback-1;
        else
            continue
        end
    elseif find(answer) == exit
        Screen('CloseAll')
        break
    end

end
