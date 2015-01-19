function [responses] = Qs_demographics(window, ppnr)

%% Screen stuff


% Define black and white
white = 255;

% Open an on screen window
HideCursor;

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%Other applications compete with windows for resources. These lines make
%sure matlab wins.
prioritylevel=MaxPriority(window); 
Priority(prioritylevel);

windowRect = [0,0,screenXpixels, screenYpixels];

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%Textstuff
KbName('UnifyKeyNames');

mainstart = tic;

%%                      Questionnaires


Q1_Buying= 'I often buy things spontaneously';
Q2_Buying= '‘Just do it’ describes the way I buy things';
Q3_Buying= 'I often buy things without thinking';
Q4_Buying= '‘I see it, I buy it’ describes me';
Q5_Buying= '‘Buy now, think about it later’ describes me';
Q6_Buying= 'Sometimes I feel like buying things on the spur-of-the-moment';
Q7_Buying= 'I buy things according to how I feel at the moment';
Q8_Buying= 'I carefully plan most of my purchases';
Q9_Buying= 'Sometimes I am a bit reckless about what I buy';

Questionnaire2 = {Q1_Buying, Q2_Buying, Q3_Buying, Q4_Buying, Q5_Buying, Q6_Buying, Q7_Buying, Q8_Buying, Q9_Buying};

answer_Q2 = cell(9, 6);


%% Go to questionnaires

%WD for instructions
instruct_dir = [cd '\Instructions\Qs\'];

nextkey = 'rightarrow';
backkey = 'leftarrow';

instructions(window, instruct_dir, 3, nextkey, backkey);

for questionnr = 1:length(Questionnaire2)
    Screen('DrawText',window, '+', xCenter, yCenter, white);
    Screen('Flip',window);
    WaitSecs(0.5);
    likert_draw(window, [1,5], Questionnaire2{questionnr}, 'Strongly agree', 'Strongly disagree', white);
    Screen('Flip',window);
    q_onset = toc(mainstart);
    
    [keyIsDown, ~, ~, ~] = KbCheck;
    while keyIsDown
        [keyIsDown, ~, ~, ~] = KbCheck;
    end
    
    response = 1;
    while response
        [~, ~, keyCode, ~] = KbCheck;
        answer = lower(KbName(keyCode));
        if answer
            switch answer
                case {'1!','2@','3#','4$','5%'}
                    RT = toc(mainstart);
                    response = 0;
                    answer_Q2(questionnr,1) = {questionnr};
                    answer_Q2(questionnr,2) = {answer(1)};
                    answer_Q2(questionnr,3) = Questionnaire2(questionnr);
                    answer_Q2(questionnr,4) = {RT-q_onset};
                    answer_Q2(questionnr,5) = {'Q2'};
                    answer_Q2(questionnr,6) = {ppnr};
                case 'escape'
                    Screen('CloseAll')
                    break
                otherwise
                    continue
            end
        else
            continue
        end
    end
end



%% Questionnaire 3

% Instructions = 'This questionnaire shows six lotteries. For each lottery, you have to decide... 
% whether you would like to accept and play the lottery or if you would like to reject it. In case...
% you accept it, then you have to imagine a coin would be thrown. If it turned up heads than you would lose an amount of money, but if it turned up...
% tails you would win an amount of money. If you reject the lottery, a coin would not be thrown and you would not win or lose any money in that specific lottery...
% Please make your decisions as close as possible to what you would do in a real scenario! Press the LEFT key to accept it and the RIGHT key to reject it.'

Q1_Lottery= 'If the coin turns up heads, then you lose €2; if the coin turns up tails, you win €6.';
Q2_Lottery= 'If the coin turns up heads, then you lose €3; if the coin turns up tails, you win €6.';
Q3_Lottery= 'If the coin turns up heads, then you lose €4; if the coin turns up tails, you win €6.';
Q4_Lottery= 'If the coin turns up heads, then you lose €5; if the coin turns up tails, you win €6.';
Q5_Lottery= 'If the coin turns up heads, then you lose €6; if the coin turns up tails, you win €6.';
Q6_Lottery= 'If the coin turns up heads, then you lose €7; if the coin turns up tails, you win €6.';

Questionnaire3 = {Q1_Lottery, Q2_Lottery, Q3_Lottery, Q4_Lottery, Q5_Lottery, Q6_Lottery};

answer_Q3 = cell(length(Questionnaire3), 6);

instructions(window, instruct_dir, 6, nextkey, backkey);

for questionnr = 1:length(Questionnaire3)
    Screen('DrawText',window, '+', xCenter, yCenter, white);
    Screen('Flip',window);
    WaitSecs(0.5);
    
    likert_draw_NL_NA(window, Questionnaire3{questionnr}, 2, 'Reject', 'Accept', white);
    Screen('Flip',window);
    q_onset = toc(mainstart);
    
    [keyIsDown, ~, ~, ~] = KbCheck;
    while keyIsDown
        [keyIsDown, ~, ~, ~] = KbCheck;
    end
    
    response = 1;
    while response
        [~, ~, keyCode, ~] = KbCheck;
        answer = lower(KbName(keyCode));
        if answer
            switch answer
                case {'leftarrow'}
                    RT = toc(mainstart);
                    response = 0;
                    answer_Q3(questionnr,1) = {questionnr};
                    answer_Q3(questionnr,2) = {'Accept'};
                    answer_Q3(questionnr,3) = Questionnaire3(questionnr);
                    answer_Q3(questionnr,4) = {RT - q_onset};
                    answer_Q3(questionnr,5) = {'Q3'};
                    answer_Q3(questionnr,6) = {ppnr};
                    
                case {'rightarrow'}
                    RT = toc(mainstart);
                    response = 0;
                    answer_Q3(questionnr,1) = {questionnr};
                    answer_Q3(questionnr,2) = {'Reject'};
                    answer_Q3(questionnr,3) = Questionnaire3(questionnr);
                    answer_Q3(questionnr,4) = {RT - q_onset};
                    answer_Q3(questionnr,5) = {'Q3'};
                    answer_Q3(questionnr,6) = {ppnr};
                case 'escape'
                    Screen('CloseAll')
                    break
                otherwise
                    continue
            end
        else
            continue
        end
    end
end
        
%% Questionnaire 1


Q1_SB= 'During the game, did you pay attention to how many tokens\n\nyou had in your account as indicated by the progress bar?';
Q21_SB= 'When you received 1 token to play the Super Brain Task,\n\nto what extent were you confident about your performance during the three Stage games?';
Q22_SB= 'When you received 1 token to play the Super Brain Task,\n\nto what extent did you feel stressed?';
Q23_SB= 'When you received 1 token to play the Super Brain Task,\n\nto what extent did you feel motivated?';
Q24_SB= 'When you received 1 token to play the Super Brain Task,\n\nto what extent did you feel excited?';
Q31_SB= 'When you received 10 tokens to play the Super Brain Task,\n\nto what extent were you confident about your performance during the three Stage games?';
Q32_SB= 'When you received 10 tokens to play the Super Brain Task,\n\nto what extent did you feel stressed?';
Q33_SB= 'When you received 10 tokens to play the Super Brain Task,\n\nto what extent did you feel motivated?';
Q34_SB= 'When you received 10 tokens to play the Super Brain Task,\n\nto what extent did you feel excited?';
Q4_SB= 'Chose one of the options below: When did you care most about your tokens?\n\nA = When I started with 1 token\n\nB = When I started with 10 tokens\n\nC = The same';
Q5_SB= 'To what extent did you want to get the bonus during the experiment?';
Q6_SB= 'When you got 1 token from the computer, did you keep thinking about the number\n\nof tokens in your account when you did the Shop Task, which had no effect on your tokens?';
Q7_SB= 'When you got 10 tokens from the computer, did you keep thinking about tokens in\n\nyour account when you did the Shop Task, which had no effect on your tokens?';
Q8_SB= 'Imagine that this bar shows how your society is set up. At the right extreme are the people who are\n\nthe best off: they have most money, the highest amount of schooling and the jobs that bring the most respect.\n\nAt the left extreme are the people who are the worst off: they have the least money, little or no education, \n\nno jobs or jobs that no one wants or respects. Now think about your family. Please tell us where \n\nyou think your family would be on this scale.';
Q9_SB= 'Chose one of the options below: At the end of each month:\n\nA= I always seem to end up short.\n\nB= I can tell you how much I will have left almost to the cent.\n\nC= I am never sure if I will come out a bit ahead or a bit behind each month.\n\nD= I do not keep track of my money too closely, but I know that I will come out ahead each month.\n\nE= I never think about how much I have in my account because I am sure I always have enough money.';
Q10_SB = 'How old are you?';
Q11_SB = 'What is your gender (f/m)?';
Q12_SB = 'What is your nationality?';
Q13_SB = 'Did you live in The Netherlands all your life?\n\nIf no, how long did you live in The Netherlands (years)?';
Q14_SB = 'What is your occupation?\n\nIf you are a student, please indicate your field of studies';
Q15_SB = 'How often do you do groceries a week?';
Q16_SB = 'Is Albert Heijn your regular supermarket?\n\nIf not, where do you do your daily groceries?';
Q17_SB= 'What is your monthly income? (€)';
Q18_SB= 'What is your weight (kg)?';
Q19_SB= 'What is your height (cm)?';
Q20_SB= 'What was the time of your last meal (hh.mm)?';
Q25_SB= 'Are you trying to lose weight recently (y/n)?';
Q26_SB= 'Do you have any dietary restrictions?';
Q27_SB= 'Do you think you guessed the purpose of this experiment? If so, please specify.';
Q28_SB= 'What is your SONA-ID?';

Questionnaire1A = {Q1_SB, Q21_SB, Q22_SB, Q23_SB, Q24_SB, Q31_SB, Q32_SB, Q33_SB, Q34_SB};
Questionnaire1B = {Q4_SB};
Questionnaire1C = {Q5_SB};
Questionnaire1D = {Q6_SB, Q7_SB};
Questionnaire1E = {Q8_SB};
Questionnaire1F = {Q9_SB, Q10_SB, Q11_SB, Q12_SB, Q13_SB, Q14_SB, Q15_SB, Q16_SB, Q17_SB, Q18_SB, Q19_SB, Q20_SB, Q25_SB, Q26_SB, Q27_SB, Q28_SB};

Questionnaire1 = {Questionnaire1A, Questionnaire1B, Questionnaire1C, Questionnaire1D, Questionnaire1E, Questionnaire1F};

answer_Q1 = cell(22, 6);

q = 1;

for part = 1:length(Questionnaire1)
    switch part
        case {1, 3}
            instructions(window, instruct_dir, 2, nextkey, backkey);
        case 4
            instructions(window, instruct_dir, 3, nextkey, backkey);
        case 5
            instructions(window, instruct_dir, 5, nextkey, backkey);
        case {2, 6}
            %Openended
            instructions(window, instruct_dir, 4, nextkey, backkey);
    end
    for question = 1:length(Questionnaire1{part})
        Screen('DrawText',window, '+', xCenter, yCenter, white);
        Screen('Flip',window);
        WaitSecs(0.5);
        switch part
            case {1, 3}
                likert_draw(window, [1,9], Questionnaire1{part}{question}, 'Very Much', 'Not at all', white);
                answeroptions = {'1!','2@','3#','4$','5%','6^','7&','8*','9('};
            case 4
                likert_draw(window, [1,5], Questionnaire1{part}{question}, 'Always', 'Never', white);
                answeroptions = {'1!','2@','3#','4$','5%'};
            case 5
                handle_x = (screenXpixels/2);
                likert_draw_NL_NV(window, Questionnaire1{part}{question}, [0,10], '10', '0', white, handle_x, 0);
            case {2, 6}
        end
        
        Screen('Flip',window);
        q_onset = toc(mainstart);
        
        if part == 1 || part == 3 || part == 4
            [keyIsDown, ~, ~, ~] = KbCheck;
            while keyIsDown
                [keyIsDown, ~, ~, ~] = KbCheck;
            end

            response = 1;
            while response
                [~, ~, keyCode, ~] = KbCheck;
                answer = lower(KbName(keyCode));
                if answer
                    switch answer
                        case answeroptions
                            RT = toc(mainstart);
                            response = 0;
                            answer_Q1(q,1) = {q};
                            answer_Q1(q,2) = {answer(1)};
                            answer_Q1{q,3} = Questionnaire1{part}{question};
                            answer_Q1(q,4) = {RT - q_onset};
                            answer_Q1(q,5) = {'Q1'};
                            answer_Q1(q,6) = {ppnr};
                        case 'escape'
                            Screen('CloseAll')
                            break
                        otherwise
                            continue
                    end
                else
                    continue
                end
            end
        elseif part == 5
            [keyIsDown, ~, ~, ~] = KbCheck;
            while keyIsDown
                [keyIsDown, ~, ~, ~] = KbCheck;
            end

            confirm = 1;
            while confirm

                [~, ~, keyCode, ~] = KbCheck;
                answer = lower(KbName(keyCode));
                if answer
                    switch answer
                        case 'leftarrow'
                            move = -2;
                        case 'rightarrow'
                            move = 2;
                        case 'return'
                            RT = toc(mainstart);
                            confirm = 0;
                        case 'escape'
                            Screen('CloseAll')
                            break
                        otherwise
                            move = 0;
                            continue
                    end
                else
                    continue
                end

                [handle_x, line_start_x, line_end_x] = likert_draw_NL_NV(window, Questionnaire1{part}{question},[0,10],'0', '10', white, handle_x, move);
                Screen('Flip', window);
            end
            answer_Q1{q,1} = q;
            answer_Q1{q,2} = sprintf('%i,%i,%i', line_start_x, handle_x, line_end_x);
            answer_Q1{q,3} = Questionnaire1{part}{question}; 
            answer_Q1(q,4) = {RT-q_onset};
            answer_Q1(q,5) = {'Q1'};
            answer_Q1(q,6) = {ppnr};
        else
            [feedback, time] = openended(window, Questionnaire1{part}{question}, white);
            answer_Q1{q,1} = q;
            answer_Q1{q,2} = feedback;
            answer_Q1{q,3} = Questionnaire1{part}{question}; 
            answer_Q1(q,4) = {time};
            answer_Q1(q,5) = {'Q1'};
            answer_Q1(q,6) = {ppnr};
        end
        q = q+1;            
    end
end

responses = [answer_Q1; answer_Q2; answer_Q3];

end
