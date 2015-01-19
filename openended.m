function [feedback, time] = openended(win, question, color)
%Inge Huijsmans
%Written on 3-11-2014
%
%Last update: 4-11, changed line 24, window-> win.
%
%This function gives the ability for participants to answer open ended
%questions on screen. The participants can change their input as usual and
%confirm input by hitting return.

%Feedback = confirmed string input after return
%Window = desired window to display question
%Question = question displayed on screen

mainstart = tic;

% Screen size
[~, screenYpixels] = Screen('WindowSize', win);

%Define feedback
feedback = '';

%Question & response on screen
DrawFormattedText(win, question, 'center', screenYpixels/3,color);
DrawFormattedText(win, [feedback '_'], 'center', (screenYpixels/3)*2,color);
Screen('Flip', win);

%Wait for keypresses
[~, input] = KbStrokeWait;
input = lower(KbName(input));


%While enter has not been pressed, process input
while ~strcmp(input,'return')
    
    if strcmp(input, 'backspace')
        feedback = feedback(1:end-1);
    elseif strcmp(input, 'space')
        feedback = [feedback ' '];
    elseif strcmp(input, 'escape')
        Screen('CloseAll');
    else
        if iscell(input)
            feedback = [feedback input{1}];
        else
            feedback = [feedback input(1)];
        end
    end
        
    %Update input on screen    
    DrawFormattedText(win, question, 'center', screenYpixels/3,color);
    DrawFormattedText(win, [feedback '_'], 'center', (screenYpixels/3)*2,color);
    Screen('Flip', win);
    
    %Ask for new input
    [~, input] = KbStrokeWait;
    input = lower(KbName(input));
end

time = toc(mainstart);
end

