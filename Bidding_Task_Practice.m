function [trialpicker, manualclose] = Bidding_Task_Practice(window, c, block, trial, ppnr, mainstart, condition_SA, fid, fid_slider, SCANNER)
%% Scarcity Project: Shop Task 
    % Inge Huijsmans 
    %
    % Start writing 2014-10-20
    % Last update 2014-10-28
    %
    % Experiment Design:
    % In this Shop task, participants will place bids on two categories of
    % products, either hedonic of utalitarian products. After the bid has been
    % placed, the computer randomly generates a price per product between 50%
    % and 100% of the retail price. When participants' bid is higher than the
    % price generated, the trial information is saved. At the end of the
    % experiment, one of these trials is selected as bonus for the participants
    % (the food + remaining money)
    % 
    % Participants will complete this task in a 2 (condition:
    % scarcity/abundance) x 2 (product category: utalitarian/hedonic) within
    % subjects design.
    %
    % Last update: changed timeout window. Too slow screen is back
    
    %%                          Set seed to date+time                        %%

    rng shuffle
       
    % setup bitsi stuff for button responses & HR triggers

    setup_bits;
    ShopTaskHRlogs;
    

    %%
    %-------------------------------------------------------------------------%
    %------------------  Experiment Settings, screen parameters --------------%
    %-------------------------------------------------------------------------%

    % Get screen number. Default = 0
    screens = Screen('Screens');

    % Set colors
    black = BlackIndex(screens);
    white = WhiteIndex(screens);
    red = [255 0 0];
    green = [0 255 0];

    %Hide cursor
    HideCursor;

    % Screen size
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    midXpix = screenXpixels/2;
    midYpix = screenYpixels/2.3;

    %Parameters for bidding task
    line_x = screenXpixels/2;
    line_y = screenYpixels*0.7;
    line_length = screenXpixels/3;
    image_rect = [0, 0, (screenYpixels*0.6/2), (screenYpixels*0.6/2)];
    image_loc = CenterRectOnPointd(image_rect, midXpix, midYpix-100);
    checkbox_rect = [0, 0, 70, 70];
    checkbox_loc = CenterRectOnPointd(checkbox_rect, midXpix, line_y-80);
    productselection_rect = [0,0,(screenYpixels*0.7/2), (screenYpixels*0.7/2)];
    productselection_loc = CenterRectOnPointd(productselection_rect, midXpix, midYpix-100);
    confirm_rect = [0 0 60 80];
    confirm_rect_bl = [0 0 50 70];
    line_start_x = screenXpixels/2-((screenXpixels/3)/2);
    line_end_x = screenXpixels/2+((screenXpixels/3)/2);
    
    %Bidding option
    roundfactor = 0.05;
    maxbid = 3;

    %Presentation times
    showselection = 3;
    timeout = 6;
    tooslow = 2;

    %Save movement data per screenflip
    hz = Screen('NominalFrameRate', window);
    
    %Textstuff
    Screen('TextFont', window, 'Calibri');
    Screen('TextSize', window, 24);
    Screen('TextStyle', window, 0); 
    KbName('UnifyKeyNames');
    
    %Break text
    breaktext = 'The exeperiment is pauzed by the experimenter\n\nPlease wait for the experiment to restart';
    
    %Parameters different under pc/linux
    if ispc
        euro = '€';
        speed = 3;
    else
        euro = 'â‚¬';
        speed = 1;
    end

    %%                  Make images textures                             %%

    for image = 1:length(c.trial(1,:))
        c.trial{1,image} = Screen('MakeTexture', window, c.trial{1,image});
    end

    %Got product check
    gotit = Screen('MakeTexture', window, c.gotit);

    %Not Got product cross
    gotnot = Screen('MakeTexture', window, c.gotnot);
    
    %%              Prepare random trial picker                          %%
  
    trialpicker = cell(length(c.trial(1,:,1)), 5);
    
    %%                      Experiment loop                                  %%

    %Counters & trackers
    quit = 0;
    total_trial = 0;
    enter = 1;
    
    %Change when closed manually
    manualclose = 0;
    
    while enter

        if quit == 1
            break
        end
        
        %%                    Set Trial constants                            %%

        %Start experiment loop for each image
        run = 1;

        %Start with first screen
        screenId = 1;

        %Image texture
        image = c.trial{1,trial};

        %Image & trial info 
        %Set price numeric
        n_price = str2double(c.trial{2,trial}{5});

        %Set computer generated price
        computerprice = rand * maxbid; 

        %Reset random handle position on each trial
        handle_x = datasample(line_x-line_length/2:1:line_x+line_length/2,1);
        
        %Set default bid rounded to 0.05 cents
        startbid = maxbid*((handle_x-line_length)/line_length);
        bid_round = select_round(startbid, roundfactor);

        %Condition
        condition = char(c.trial{2,trial}{1}); 

        %Saving info
        brand = char(c.trial{2,trial}{2});
        product = char(c.trial{2,trial}{3});
        filename = char(c.trial{2,trial}{6});
        
        %Reset responses for each trial
        tmp_bid = 0;
        bid = 0;
        RT = 0;
        gotproduct = 0;
        
        %Preallocate slider data
        cursordata = zeros(11, (hz*timeout)+1);

        while run

            %%                  Flip through Screens                     %%

            switch screenId
                
                case 0
                %%                 Resynchronize Scanner                 %%
                    
                    %Send trigger
                    HR = 0;
                    
                    %Restart at fixation cross
                    screenId = 1;

                case 1
                %%                       Screen 1                        %%
                %                     Fixation Cross                      %
                    %Fixation Cross
                    Screen('DrawText', window, '+', screenXpixels/2, screenYpixels/2, white);

                    %Presentation time
                    presenttime = (rand*2)+2;
                    
                    %Set HR trigger
                    HR = c.HR_fixcross{condition_SA};
                    
                    %Next Screen
                    screenId = 2;

                case 2
                %%                     Screen 2                          %%
                %                   Present Image                         %

                    %Image
                    Screen('DrawTexture', window, image, [], image_loc, 0);

                    %Presentation time
                    presenttime = (rand*2)+2;

                    %Set HR trigger
                    HR = c.HR_image{condition_SA};
                    
                    %Next Screen
                    screenId = 3;

                case 3
                %%                         Screen 3                      %%
                %------------------------- Bidding -----------------------%

                %------Default screen------%

                    %Image
                    Screen('DrawTexture', window, image, [], image_loc, 0);

                    %Likert scale
                    likert_draw_NL(window, line_y, sprintf('%s%i', euro, 3)', sprintf('%s%i', euro, 0), white, handle_x, sprintf('%0.2f', bid_round))

                    %Next screen
                    screenId = 4;
                    
                    %%Set HR trigger
                    HR = c.HR_startbid{condition_SA};
                    
                    %Presentation time
                    presenttime = 0;

                case 4
                    %%                     Screen 4                      %%
                    %------  Updating bid according to buttonpress  ------%
    
                    %Participants are too slow unless they press a button
                    screenId = 5;
                    
                    %Wait for release of all buttons
                    [response, ~] = bitsiboxButtons.getResponse(0.001, true);
                    while any(response)
                        [response, ~] = bitsiboxButtons.getResponse(0.001, true);
                    end

                    %While not clicked on confirmation button
                    confirm = 0;
                    flip = 1;
                    firstpress = 0;
                    movehandle = 0;

                    while confirm == 0 && ((GetSecs - lastFlipTimestamp )<= timeout)

                        %Get new slider location
                        [response, keyDownTimestamp] = bitsiboxButtons.getResponse(0.001, true);
                        
                        RT=(keyDownTimestamp-lastFlipTimestamp);

                        switch response
                            case ButtonA
                                firstpress = 1;
                                movehandle = - 1 * speed;
                            case ButtonB
                                firstpress = 1;
                                movehandle =  1 * speed;
                            %Confirm
                            case ButtonC
                                if firstpress
                                    confirm_pos = CenterRectOnPointd(confirm_rect, handle_x, line_y);
                                    confirm_pos_bl = CenterRectOnPointd(confirm_rect_bl, handle_x, line_y);
                                    Screen('FillRect', window, red, confirm_pos);
                                    Screen('FillRect', window, black, confirm_pos_bl);
                                    presenttime = 1;
                                    bid = tmp_bid;
                                    screenId = 6;
                                    confirm = 1;
                                    %Set HR trigger
                                    HR = c.HR_response{condition_SA};
                                    
                                else
                                    continue
                                end
                            %Pauze
                            case ButtonD
                                screenId = 999;
                                break
                            %Next
                            case ButtonE
                                run = 0;
                                enter = 0;
                                break 
                            %Close
                            case ButtonF
                                run = 0;
                                enter = 0;
                                manualclose = 1;
                                display(sprintf('Shoptask: trial:%i',trial));
                                break
                            otherwise
                                movehandle = 0;
                        end

                                             
                        if handle_x <= line_start_x-movehandle
                            handle_x = line_start_x;
                        elseif handle_x >= line_end_x-movehandle
                            handle_x = line_end_x;
                        else
                            handle_x = handle_x + movehandle;
                        end
                        
                        %Update bid
                        tmp_bid = maxbid*((handle_x-line_length)/line_length);
                        bid_round = select_round(tmp_bid, roundfactor);

                        %Update screen
                        %Image
                        Screen('DrawTexture', window, image, [], image_loc, 0);
                        %Likert
                        %Linux
                        likert_draw_NL(window, line_y, sprintf('%s%i', euro, 3), sprintf('%s%i', euro, 0), white, handle_x, sprintf('%0.2f',bid_round));

                        %Flip & wait
                        [VBLTimestamp, BidFlipTimestamp, FlipTimestamp, MissedFlip] = Screen('Flip', window);
                        WaitSecs(presenttime);
                        %if confirm == 1
                             %Send trigger to HR signal for each event
                             %bitsiHR.sendTrigger(HR);                                                              % SEND HR TRIGGER
                        %end

                        %Save cursor data
                        cursordata(:, flip) = [trial, flip, handle_x, response, keyDownTimestamp, tmp_bid, RT, VBLTimestamp, BidFlipTimestamp, FlipTimestamp, MissedFlip];
                        flip = flip+1;

                    end

                    presenttime = 0;

                case 5
                    % ------------------- Screen 5 --------------------- %%
                    %                   Too slow                          %

                    DrawFormattedText(window, 'Too slow!', 'center', 'center', red);

                    %Present screen
                    presenttime=tooslow;
                    
                    %Set HR trigger
                    HR = c.HR_slow{condition_SA};

                    %Make them redo the trial: Fixation cross
                    screenId = 6;
                    
                case 6
                %%                           Screen 6                    %%
                %------------------- Product Selection -------------------%
                                       
                    %Determine if pp's got the product
                    gotproduct = bid >= computerprice;
                    
                    if confirm ~= 0   
                        if gotproduct
                            gotcolor = green;
                            spent = sprintf('\n%s%0.2f', euro, select_round(bid,0.05));
                            gotcheck = gotit;
                        else
                            gotcolor = red;
                            spent = sprintf('\n%s%0.2f', euro, 0);
                            gotcheck = gotnot;
                        end
                    else
                        gotcolor = red;
                        spent = sprintf('\n%s%0.2f', euro, 3);
                        gotcheck = gotnot;
                    end
                        
                    %Draw rectangle + image + checkbox
                    Screen('FillRect', window, gotcolor, productselection_loc);
                    Screen('DrawTexture', window, image , [], image_loc, 0);
                    Screen('DrawTexture', window, gotcheck , [], checkbox_loc, 0);
                    
                    %Presentation time
                    presenttime = (rand*2)+2;
                    
                    %Set HR trigger
                    HR = c.HR_slow{condition_SA};

                    %Next Screen
                    screenId = 7;


                case 7
                %%                       Screen 7                        %%
                %--------------------- Price Payed -----------------------%
                
                    spent_txt = 'You have spent';

                    %Draw rectangle + image + gotcheck
                    Screen('FillRect', window, gotcolor, productselection_loc);
                    Screen('DrawTexture', window, image , [], image_loc, 0);
                    Screen('DrawTexture', window, gotcheck , [], checkbox_loc, 0);
                    %You have spent
                    DrawFormattedText(window, spent_txt, 'center',line_y, white);  
                    Screen('TextSize', window, 60);
                    %Price
                    DrawFormattedText(window, spent, 'center',line_y, white); 
                    Screen('TextSize', window, 24);
                    
                    %Presentation time
                    presenttime = showselection;

                    %To next image
                    trial = trial+1;

                    %nr trials per block
                    total_trial = total_trial+1;
                    
                    %Set HR trigger
                    HR = c.HR_moneyspent{condition_SA};

                    %Reset all image info
                    run = 0;

                    %Back from the start
                    screenId = 1;
                                    
                case 999
                    %% Break the experiment in order to continue later
                    
                    %draw it all
                    DrawFormattedText(window,breaktext, 'center', 0.46*screenYpixels, white);
                    
                    %Set HR trigger
                    HR = 12;
                                       
                    %Wait for buttonpress
                    presenttime = 25;

            end

            %%                       Flip it all                         %%
            
            [VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip] = Screen('Flip', window); 
            flip_stamp = toc(mainstart);
            
            %Send trigger to HR signal for each event
            %bitsiHR.sendTrigger(HR);                                                              % SEND HR TRIGGER
            if presenttime > 20
                while presenttime
                    %Continue experiment when hitting spacebar
                    [response, keydownTimeStamp] = bitsiboxButtons.getResponse(0.001, true);

                    %how long are we waiting?
                    RT = keydownTimeStamp - lastFlipTimestamp;
                    
                    switch response
                        case ButtonD
                            screenId = 0;
                            break
                        case ButtonF
                            run = 0;
                            enter = 0;
                            manualclose = 1;
                            display(sprintf('Shoptask: block:%i\ttrial:%i',block, trial));
                        otherwise
                            continue
                    end
                end
                presenttime = 0;
            end 
            
            WaitSecs(presenttime);
            
            %%                   Write data per Screen                    %%
            
            %Save data of each screen
            fprintf(fid, '%i\t%i\t%i\t%i\t%i\t%i\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.2f\t%.2f\t%.2f\t%.4f\t%i\t%.6f\t%i\t%s\t%s\t%s\t%i\n', ppnr, condition_SA, HR, total_trial, trial, screenId, presenttime, VBLTimestamp, lastFlipTimestamp, FlipTimestamp, MissedFlip, flip_stamp, startbid, bid_round, bid, computerprice, bid >= computerprice, RT, condition, brand, product, filename, n_price);
            
            %Experiment finished
            if length(c.trial(:,:,1)) < trial
                run = 0;
                enter = 0;
            end          
        end
        
        cursordata(12,:) = repmat(ppnr, [1, length(cursordata)]);
        cursordata(13,:) = repmat(condition_SA, [1, length(cursordata)]);
        cursordata(14,:) = repmat(total_trial, [1, length(cursordata)]);
        
        %Save cursor movement on each trial
        fprintf(fid_slider, '%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%i\t%i\t%i\t%i\n',  cursordata);
        
        %Save info for random trial picker
        trialpicker((trial-1),:) = {(trial-1), gotproduct, bid_round, brand, product};
        
    end
    
    %Close bitsi's
    close(bitsiboxScanner);
    close(bitsiboxButtons);
    %close(bitsiHR);                                                              % CLOSE HR TRIGGER
end















