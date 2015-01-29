function likert_draw_NL_NA(window, question, anchorstep, highlabel, lowlabel, color_line)
%% Inge Huijsmans 
%
% Start writing 2014-11-6
% Last update 2014-11-6
%
% 2014-11-11
% Includes anchor labels
% 2014-11-25
% Excludes anchor labels
%
% Draws a likert scale, it's according values and anchor labels. Needs to flip in main
% script. Did this to enable movement of a handle. 

%Get size
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%Set defaults
line_y = screenYpixels*0.7;
question_y = screenYpixels*0.4;
line_x = screenXpixels/2;
line_width = 4;
line_length = screenXpixels/3;
line_start_x = screenXpixels/2-((screenXpixels/3)/2);
    
%Control for text width
[hl_width, hl_height] = RectSize(Screen('TextBounds',window,highlabel));
[ll_width, ll_height] = RectSize(Screen('TextBounds',window,lowlabel));

%Preallocate for anchor x position
anchorXpos = zeros(2,anchorstep);

%Create x pos of anchors
for i = (1:2:anchorstep*2)
    anchorXpos(:,i) = [line_start_x+(((i-1)/2)*(line_length/(anchorstep-1))); line_y*0.99];
    anchorXpos(:,i+1) = [line_start_x+(((i-1)/2)*(line_length/(anchorstep-1))); line_y*1.01];
end

%%                                 draw it all                           %%

%Line
Screen('DrawLine',window, color_line,line_x-line_length/2,line_y,line_x+line_length/2,line_y,line_width);             

%Anchor lines
Screen('DrawLines', window, anchorXpos,line_width,color_line);                                                       

%Draw anchor labels
Screen('DrawText', window, highlabel, (line_x + (line_length/2))-(hl_width/2), line_y-(hl_height*2), color_line);
Screen('DrawText', window, lowlabel, (line_x - (line_length/2))-(ll_width/2), line_y-(ll_height*2), color_line);

%Draw question    
DrawFormattedText(window, question, 'center', question_y, color_line);     

end
