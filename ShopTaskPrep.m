function [vars] = ShopTaskPrep(ppnr)
%
%This function creates all variables needed for the main experiment Shoptask.
%

%%                      Set working dirs                                 %%

%Stimulus direcotry
stimdir = [pwd '/Food Stimuli/'];

%%                            Prepare Stimuli                            %%

    
%Read all filenames
listing = dir(stimdir);
filenames = char(listing.name);

%first three entries are non informative
filenames(1:3,:) = [];

% Read filename to retrieve stimulus information, make two seperate vars
% for condition
stiminfo = cell(length(filenames)/2,6,2);

%Keep track of rownrs
u_count = 1;
h_count = 1;

for j = 1:length(filenames)

    % Split the filename
    stimdata = textscan(filenames(j,:), '%s', 'delimiter', ['_', '.']);
    
    %Add price with a dot and full filename
    stimdata{1}(5) = {strtrim(strrep(stimdata{1}(4), ',', '.'))};
    stimdata{1}(6) = {strtrim(filenames(j,:))};

    % Column information of stiminfo (two vars): 
    % col 1 = utalitarian/hedonic, col 2 = brand, col 3 = product, 
    % col 4 = price, col 5 = price, col 6 = filename      
    if strcmp(stimdata{1}{1}, 'u')       
        stiminfo(u_count,:,1) = stimdata{1}; 
        u_count = u_count+1;
    else
        stiminfo(h_count,:,2) = stimdata{1}; 
        h_count = h_count+1;
    end   
end


%%                                Read images                            %%

% Read images and add to variable
images = zeros(708, 708, 3, length(filenames)/2, 2, 'uint8');


for j = 1:2
    for i = 1:(length(filenames)/2)

        % Read image from stiminfo
        tmpimg = imread([stimdir char(stiminfo(i,6,j))], 'jpg');

        % Store in new variable
        images(:,:,:,i,j) = tmpimg; 
    end
    
    % Make them uint8, somehow does not work otherwise
    images(:,:,:,:,j) = uint8(images(:,:,:,:,j));   
end


%% Make textures of images

% Make Textures
h_imagetextures = cell(2,length(filenames)/2);
u_imagetextures = cell(2,length(filenames)/2);

for j = 1:2
    for i = 1:length(filenames)/2
        if j == 1
            u_imagetextures(1,i) = {images(:,:,:,i,j)};
            u_imagetextures(2,i) = {stiminfo(i,:,j)};
        else
            h_imagetextures(1,i) = {images(:,:,:,i,j)};
            h_imagetextures(2,i) = {stiminfo(i,:,j)};
        end
    end
end

%Shuffle order for images + information
h_order = randperm(length(h_imagetextures));
u_order = randperm(length(u_imagetextures));

u_imagetextures = u_imagetextures(:,u_order);
h_imagetextures = h_imagetextures(:,h_order);


%%                    Randomization/Counterbalancing                     %%

% Between subjects counterbalancing (ppnr)
images_HU = mod(ppnr,4)+1;

%Divide imagetextures in parts
c.h_im_pt1 = h_imagetextures(:,1:length(h_imagetextures)/2);
c.h_im_pt2 = h_imagetextures(:,(length(h_imagetextures)/2)+1:length(h_imagetextures));
c.u_im_pt1 = u_imagetextures(:,1:length(u_imagetextures)/2);
c.u_im_pt2 = u_imagetextures(:,(length(u_imagetextures)/2)+1:length(u_imagetextures));

%For in the experiment
h = {c.h_im_pt1,c.h_im_pt2};
u = {c.u_im_pt1,c.u_im_pt2};

%For documentation
h_txt = {'h1', 'h2'};
u_txt = {'u2','u1'};

%Counterbalancing matrix, each column is a randomized order
condition_runs = [CombVec(h, u);fliplr(CombVec(h, u))];
condition_runs_txt = [CombVec(h_txt, u_txt);fliplr(CombVec(h_txt, u_txt))];

%Set condition according to participant nr row 1+2 = block 1, 3+4 = block 2
c.runs = condition_runs(:,images_HU);
c.runs_txt = condition_runs_txt(:,images_HU);

%% Within subjects counterbalancing (within blocks)

%Set zeros en ones for h (=1) en u (=0)
h_u_block = [zeros(1,(length(h_imagetextures)/3)/2)+1, zeros(1,(length(h_imagetextures)/3)/2)]; 

%Preallocate images
c.order = zeros(1,(length(h_imagetextures)/3),6);


%Per condition abund/scarc
for i = 1:2:4                             
       
    %Set image sets per block 
    hedonic = c.runs{i};
    utilitarian = c.runs{i+1};
    
    %Per Game (1,2,3)
    for j = 1:3       
        
        if i == 1
            m = 0;
        else 
            m = 3;
        end
        
        %shuffle order of hedonic/utilitarin
        s_h_u_block = Shuffle(h_u_block);      
        
        %Save if its hedonic/utilitarian
        c.order(:,:,j+m) = s_h_u_block;
              
        for trial = 1:length(s_h_u_block)
   
            if s_h_u_block(trial) == 1
                %include a hedonic trial
                c.trial(:,trial,j+m) = hedonic(:,end);
                %delete it from the list
                hedonic = hedonic(:,1:end-1);
            else
                %include an utilitrian trial
                c.trial(:,trial,j+m) = utilitarian(:,end);
                %delete it from the list
                utilitarian = utilitarian(:,1:end-1);
            end
        end
        
    end
end

%Set HR trigger logs
ShopTaskHRlogs;

vars = c;

end
