function [newhandle_x, line_start_x, line_end_x] = likert_draw_NL_NV(window, question, anchors, highlabel, lowlabel, color_line, handle_x, movehandle)
%% Inge Huijsmans 
%
% Start writing 2014-11-6
% Last update 2014-12-14
%
%
% Draws a likert scale, it's according values and anchor labels. Needs to flip in main
% script. Did this to enable movement of a handle. 
%
% Input: active window, question (str), anchors [1,9], high (str) and low (str) value labels,
% color of the line, x-position of the handle (int) and the increment step(int) of the handle.
%
% Returns: new x-position of the handle, and x position of the beginning and
% end of the likertscale.

%Get windowsize
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%Set defaults
line_y = screenYpixels*0.7;
question_y = screenYpixels*0.4;
line_x = screenXpixels/2;
line_width = 4;
line_length = screenXpixels/3;
anchorstep = anchors(2)-anchors(1);
line_start_x = screenXpixels/2-((screenXpixels/3)/2);
line_end_x = screenXpixels/2+((screenXpixels/3)/2);
handle_rect = [0 0 10 30];
red = [255 0 0];

%Move handle
if handle_x <= line_start_x-movehandle
    handle_x = line_start_x;
elseif handle_x >= line_end_x-movehandle
    handle_x = line_end_x;
else
    handle_x = handle_x + movehandle;
end

newhandle_x = handle_x + movehandle;

%Position handle
handle_pos = CenterRectOnPointd(handle_rect, newhandle_x, line_y);
                
%Control for text width of labels
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

%Draw handle
Screen('FillRect', window, red, handle_pos);

%Draw question    
DrawFormattedText(window, question, 'center', question_y, color_line); 

end
