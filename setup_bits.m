% This script sets up the Bitsi boxes - on for the button boxes, one for the scanner-triggers
% It assumes that there is a SCANNER variable
% SCANNER = {'Skyra','Dummy','Debugging','Keyboard'}; SCANNER = SCANNER{3};

switch SCANNER
    case 'Skyra'
        
        %Set WD
        cd '/home_local/meduser/Desktop/data/users/inghui/Scarcity Tasks Inge/Main_Experiment/';
        
        %Set trigger
        scannertrigger = 97;

        %Set output/input comports
        bitsiboxScanner = Bitsi('/dev/ttyS2');
        bitsiboxButtons = Bitsi('');
        bitsiHR = Bitsi('/dev/ttyS1');
        
        % Right hand -- button down
        ButtonA = 11; % left
        ButtonB = 12; % right
        ButtonC = 13; % confirm
        ButtonD = KbName('a'); % pauze
        ButtonE = KbName('b'); % next
        ButtonF = KbName('Escape'); % close
        ButtonG = KbName('space');

        
    case 'Dummy'
        
        %Set WD
        cd '/home_local/meduser/Desktop/data/users/inghui/Scarcity Tasks Inge/Main_Experiment/';
        
        %Set trigger
        scannertrigger = 97;
        
        %Set output/input comports
        bitsiboxScanner = Bitsi('/dev/ttyS2');
        bitsiboxButtons = Bitsi('');
        bitsiHR = Bitsi('/dev/ttyS1');
     
        % Right hand -- button down
        ButtonA = 11; % left
        ButtonB = 12; % right
        ButtonC = 13; % confirm
        ButtonD = KbName('a'); % pauze
        ButtonE = KbName('b'); % next
        ButtonF = KbName('Escape'); % close
        ButtonG = KbName('space');

    
        
    case {'Debugging', 'Keyboard'}
        
        %Set WD
        cd 'M:\Scarcity\Main_Experiment\';
                
        %Set trigger
        scannertrigger = KbName('a'); %key "a"
        
        %Set comports to KB 
        bitsiboxScanner = Bitsi('');
        bitsiboxButtons = Bitsi('');
        bitsiHR = Bitsi('');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Note: Edit any of letters below, to use the ones you want
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ButtonA = KbName('leftarrow'); % left
        ButtonB = KbName('rightarrow'); % right
        ButtonC = KbName('return'); % confirm
        ButtonD = KbName('a'); % pauze
        ButtonE = KbName('b'); % next
        ButtonF = KbName('Escape'); % close

     case 'buttonbox'
        scannertrigger = KbName('a');
        bitsiboxScanner = Bitsi('');
        bitsiboxButtons = Bitsi('COM1');
     
        % Right hand -- button down
        ButtonA = 97; % index finger
        ButtonB = 98; % middle finger
        ButtonC = 99; % ring finger
        ButtonD = 100; % pinky finger
        ButtonA_up = 65;
        ButtonB_up = 66;
        ButtonC_up = 67;
        ButtonD_up = 68;    
        
    otherwise
        disp('Missing proper value for "SCANNER" variable. Cannot set up Bitsi-boxes properly..');
end