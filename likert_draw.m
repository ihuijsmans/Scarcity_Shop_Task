function likert_draw(window, anchors, question, highlabel, lowlabel, color_line)
%% Inge Huijsmans 
%
% Start writing 2014-11-6
% Last update 2014-11-6
%
% 2014-11-11
% Includes anchor labels
%
% Draws a likert scale, it's according values and anchor labels. Needs to flip in main
% script. Did this to enable movement of a handle. 

%Check range
if anchors(1) == 0
    anchors(2) = anchors(2) + 1;
end

%Get size
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%Set defaults
question_y = screenYpixels*0.4;
line_x = screenXpixels/2;
line_width = 4;
line_length = screenXpixels/3;
line_y = screenYpixels*0.7;
anchorstep = line_length/(anchors(2)-1);
line_start_x = screenXpixels/2-((screenXpixels/3)/2);

Screen('TextSize', window, 20); 

%Control for text width
txt_width = RectWidth(Screen('TextBounds',window,num2str(anchors(2))));
[hl_width, hl_height] = RectSize(Screen('TextBounds',window,highlabel));
[ll_width, ll_height] = RectSize(Screen('TextBounds',window,lowlabel));

%Preallocate for anchor x position
anchorXpos = zeros(2,anchors(2)*2);

%Create x pos of anchors
for i = (1:2:(anchors(2)*2))
    anchorXpos(:,i) = [line_start_x+(anchorstep*((i-1)/2)); line_y*0.99];
    anchorXpos(:,i+1) = [line_start_x+(anchorstep*((i-1)/2)); line_y*1.01];
end

%%                                 draw it all                           %%

%Line
Screen('DrawLine',window, color_line,line_x-line_length/2,line_y,line_x+line_length/2,line_y,line_width);             

%Anchor lines
Screen('DrawLines', window, anchorXpos,line_width,color_line);                                                       

%Draw anchor values
for i = 1:anchors(2)
    if anchors(1) == 0
        j = i-1;
    else
        j=i;
    end
    Screen('DrawText', window, num2str(j), (anchorXpos(1,i*2)-txt_width/2), line_y+txt_width, color_line);  
end

%Draw anchor labels
Screen('DrawText', window, highlabel, (line_x + (line_length/2))-(hl_width/2), line_y+(hl_height*1.5), color_line);
Screen('DrawText', window, lowlabel, (line_x - (line_length/2))-(ll_width/2), line_y+(ll_height*1.5), color_line);

%Draw question    
DrawFormattedText(window, question, 'center', question_y, color_line);                                               

end
