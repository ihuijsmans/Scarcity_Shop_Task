function [trialpicker, manualclose] = ShopTask(window, c, block, trial, ppnr, mainstart, reminder, condition_SA, fid, SCANNER)
%% Scarcity Project: Shop Task 
    % Inge Huijsmans 
    %
    % Start writing 2014-10-20
    % Last update 2014-10-28
    %
    % Experiment Design:
    % In this Shop task, participants will be able buy two categories of
    % products, either hedonic of utalitarian products. They will be offered 
    % 75% of the retailprice and get to accept of reject the offer.
    % At the end of the experiment, one of these trials is selected as bonus 
    % for the participants (the food + remaining money)
    % 
    % Participants will complete this task in a 2 (condition:
    % scarcity/abundance) x 2 (product category: utalitarian/hedonic) within
    % subjects design.
    %
    % Last update: changed bidding task to shoptask
    
    %%                          Set seed to date+time                        %%

    rng shuffle
       
    % setup bitsi stuff for button responses & HR trigger  
    setup_bits;
    ShopTaskHRlogs;
    
    %-------------------------------------------------------------------------%
    %------------------  Experiment Settings, screen parameters --------------%
    %-------------------------------------------------------------------------%

    % Get screen number. Default = 0
    screens = Screen('Screens');

    % Set colors
    white = WhiteIndex(screens);
    red = [255 0 0];
    yellow = [255 255 0];

    %Hide cursor
    HideCursor;

    % Screen size
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    midXpix = screenXpixels/2;
    midYpix = screenYpixels/2;

    % Textstuff
    Screen('TextFont', window, 'Calibri');
    Screen('TextSize', window, 42);
    Screen('TextStyle', window, 0); 
    textRect_Y = Screen('TextBounds', window ,' Yes ');
    textRect_N = Screen('TextBounds', window ,' No ');
    KbName('UnifyKeyNames');
    
    % Parameters for bidding task
    discount = 0.5;
    image_rect = [0, 0, (screenYpixels*0.4), (screenYpixels*0.4)];
    if isunix
        textRect_Y(4) = textRect_Y(4) +(textRect_Y(4)/2);
        textRect_N(4) = textRect_N(4) +(textRect_N(4)/2);
        %textRect(4) = textRect(4)*2;
    end
    
    textRect_YES = Screen('TextBounds', window, 'Yes');
    textRect_NO = Screen('TextBounds', window, 'No');
    image_loc = CenterRectOnPointd(image_rect, midXpix, midYpix-textRect_Y(4));
    size_reminder = size(reminder);
    xleftbutton = screenXpixels/3;
    xrightbutton = (screenXpixels/3)*2;
    ybutton = (screenYpixels/5)*4;
    price_loc = (screenYpixels/3)*2;
    
    % Presentation times
    tooslow = 2;
    timeout = 4; 
   
    % Parameters different under pc/linux
    if ispc
        euro = '�';
        reminder_loc = [screenXpixels-(((size_reminder(2)/4)*3)+100),100,screenXpixels-100,((size_reminder(1)/4)*3)+100];
    else
        euro = '€';
        reminder_loc = [screenXpixels-round((size_reminder(2)/8)*5),round((size_reminder(1)/8)),screenXpixels-round(size_reminder(2)/8),round((size_reminder(1)/8)*5)];
    end

    %%                  Make images textures                             %%

    for image = 1:length(c.trial(:,:,block))
        c.trial{1,image,block} = Screen('MakeTexture', window, c.trial{1,image,block});
    end

    %Reminder
    reminder = Screen('MakeTexture', window, reminder);
    
    %%              Prepare random trial picker                          %%
  
    trialpicker = cell(length(c.trial(1,:,1)), 6);
    
    %%                      Experiment loop                                  %%

    %Counters & trackers
    quit = 0;
    enter = 1;
    
    %Change when closed manually
    manualclose = 0;

    try
        while enter

            if quit == 1
                break
            end

            %%                    Set Trial constants                            %%

            %Start experiment loop for each image
            run = 1;

            %Start with first screen
            screenId = 1;
            
            %yes - no, left - right. yesno(1) = left, yesno(2) = right. 
            yesno = c.yesno_LR(:,trial,condition_SA,block);
            
            %Image texture
            image = c.trial{1,trial,block};

            %Image & trial info 
            %Set price numeric
            n_price = str2double(c.trial{2,trial,block}{5});
            discountprice = n_price*discount;
            
            %Condition
            condition = char(c.trial{2,trial,block}{1}); 

            %Saving info
            brand = char(c.trial{2,trial,block}{2});
            product = char(c.trial{2,trial,block}{3});
            filename = char(c.trial{2,trial,block}{6});

            %Reset responses for each trial
            RT = 0;
            gotproduct = 1;

            while run

                if quit == 1
                    break
                end

                %%                  Flip through Screens                     %%

                switch screenId
        
                    case 1
                    %%                       Screen 1                        %%
                    %                     Fixation Cross                      %
                        %Fixation Cross
                        Screen('DrawText', window, '+', screenXpixels/2, screenYpixels/2, white);

                        %Presentation time
                        presenttime = rand+1;

                        %Set HR trigger
                        HR = c.HR_fixcross{condition_SA};

                        %Next Screen
                        screenId = 2;

                    case 2
                    %%                     Screen 2                          %%
                    %                   Present Product                       %

                        %Image
                        Screen('DrawTexture', window, image, [], image_loc, 0);

                        %Presentation time 
                        presenttime = rand+3;

                        %Set HR trigger
                        HR = c.HR_image{condition_SA};

                        %Next Screen
                        screenId = 3;

                    case 3
                    %%                         Screen 3                      %%
                    %                 Present Product + Price                 %

                        %Image
                        Screen('DrawTexture', window, image, [], image_loc, 0);

                        % Draw price
                        DrawFormattedText(window, sprintf('%s%.2f', euro, discountprice), 'center', price_loc, white);
                        
                        %Next screen
                        screenId = 4;

                        %%Set HR trigger
                        HR = c.HR_price{condition_SA};

                        %Presentation time 
                        presenttime = rand +3;

                     case 4
                        % ------------------- Screen 4 --------------------- %%
                        %                      Choice                         %

                        %Image
                        Screen('DrawTexture', window, image, [], image_loc, 0);

                        % Draw price
                        DrawFormattedText(window, sprintf('%s%.2f', euro, discountprice), 'center', price_loc, white);
                         
                        if response
                            % Nextscreen
                            screenId = 1;
                            
                            %Presentation time
                            presenttime = 4 - RT;
                            
                            %Go to next trial
                            trial = trial + 1;
                            run = 0;
                            
                                                 
                            %Color of buttons
                            switch response
                                case ButtonA
                                    color = {yellow, white};
                                    if strcmp(c.yesno{yesno(1)}, c.yesno{1}) 
                                        gotproduct = 2;
                                    end
                                case ButtonB                            
                                    color = {white, yellow};
                                    if strcmp(c.yesno{yesno(2)}, c.yesno{1}) 
                                        gotproduct = 2;
                                    end
                            end
                            
                            %Set HR trigger
                            HR = c.HR_gotnot{condition_SA}(gotproduct);
                        else
                            %Color of buttons & presentation time
                            color = {white, white};
                            presenttime=0;
                            %%Set HR trigger
                            HR = c.HR_yesno{condition_SA};
                        end
                        
                        %Layout unix vs pc
                        if isunix
                            wierdnomovement = 3;
                            yplacement = textRect_Y(4)/3;
                            %xplacement = textRect(3)/1.5;
                        else
                            wierdnomovement = 0;
                            yplacement = textRect_Y(4)/2;
                            %xplacement = textRect(3)/2;
                        end
                        
                        %Layout yes vs bi
                        if strcmp(c.yesno{yesno(2)}, 'No')
                            xplacement_LEFT = textRect_YES(3)/2;
                            xplacement_RIGHT = (textRect_NO(3)/2)+wierdnomovement;
                            textRect_L = CenterRectOnPointd(textRect_Y, xleftbutton, ybutton);
                            textRect_R = CenterRectOnPointd(textRect_N, xrightbutton, ybutton);
                        else
                            xplacement_LEFT = (textRect_NO(3)/2)+wierdnomovement;  
                            xplacement_RIGHT = textRect_YES(3)/2;  
                            textRect_L = CenterRectOnPointd(textRect_N, xleftbutton, ybutton);
                            textRect_R = CenterRectOnPointd(textRect_Y, xrightbutton, ybutton);
                        end
                        
                                                   
                        %Draw Yes-NO
                        Screen('DrawText', window, sprintf('%s', c.yesno{yesno(1)}), xleftbutton-xplacement_LEFT, ybutton - yplacement, color{1});
                        Screen('DrawText', window, sprintf('%s', c.yesno{yesno(2)}), xrightbutton-xplacement_RIGHT, ybutton - yplacement, color{2});
                        
                        %Draw Button rects
                        Screen('FrameRect', window, white, textRect_L,3);
                        Screen('FrameRect', window, white, textRect_R,3);                                   
                        
                    case 5
                        % ------------------- Screen 5 --------------------- %%
                        %                   Too slow                          %

                        DrawFormattedText(window, 'Too slow!', 'center', 'center', red);

                        %Present screen
                        presenttime=tooslow;

                        %Set HR trigger
                        HR = c.HR_wrong{condition_SA};

                        %Make them go to next trial
                        screenId = 1;
                        trial = trial + 1;
                        run = 0;
                        
                    case 6
                        % ------------------- Screen 6 --------------------- %%
                        %                   Wrong button                         %

                        DrawFormattedText(window, 'Wrong button!', 'center', 'center', red);

                        %Present screen
                        presenttime=tooslow;

                        %Set HR trigger
                        HR = c.HR_slow{condition_SA};

                        %Make them go to next trial
                        screenId = 1;
                        trial = trial + 1;
                        run = 0;
                        
                end

                %%                       Flip it all                         %%
               
                Screen('DrawTexture', window, reminder, [], reminder_loc, 0);
                [VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip] = Screen('Flip', window); 
                flip_stamp = toc(mainstart);

                %Send trigger to HR signal for each event
                bitsiHR.sendTrigger(HR);                                                              % SEND HR TRIGGER
                
                response = 0;
                if presenttime == 0
                    while (response == 0 || response == 15) && ((GetSecs - lastFlipTimestamp )<= timeout)
                        [response, keyDownTimestamp] = bitsiboxButtons.getResponse(0.001, true);
                    end

                    RT=(keyDownTimestamp-lastFlipTimestamp);
                    
                    if response == 0                                       %No answer: Too slow
                        screenId = 5;
                    elseif response == ButtonA || response == ButtonB      %Answer
                        screenId = 4;
                    elseif response == ButtonF                             %Quit
                        quit = 1;
                        enter = 0;
                        manualclose = 1;
                        display(sprintf('Shop Task\tppnr: %i\t blocknr: %i\t trialnumber:%i', ppnr, block, trial));
                        bitsiHR.sendTrigger(c.HR_quit{condition_SA});
                        break
                    elseif response == ButtonE                                         %Back to SG
                        enter = 0;
                        quit = 0;
                        break
                    else                                                   %Wrong button
                        screenId = 6;
                    end
                end 

                %Hold it on screen
                WaitSecs(presenttime);
                    
                %%                   Write data per Screen                    %%

                %Save data of each screen
                fprintf(fid, '%i\t%i\t%i\t%i\t%i\t%i\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%i\t%i\t%.6f\t%i\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%.2f\n', ppnr, block, condition_SA, ((block-1)*24)+trial, trial, screenId, presenttime, VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip, flip_stamp, HR, gotproduct, RT, response, c.yesno{yesno(1)}, c.yesno{yesno(2)}, condition, brand, product, filename, n_price, discountprice);
                
                %Experiment finished
                if length(c.trial(:,:,1)) < trial
                    run = 0;
                    enter = 0;
                end          
            end

            %Save info for random trial picker
            trialpicker((trial-1),:) = {((block-1)*length(c.trial(:,:,1)))+(trial-1), gotproduct, n_price, discountprice, brand, product};

        end

        %Close bitsi's
        close_bitsi;
    catch me
        me.message
        me.stack.line
        Screen('CloseAll');
        close_bitsi
    end
end











