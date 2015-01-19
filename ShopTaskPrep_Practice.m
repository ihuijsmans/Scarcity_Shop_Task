function [vars] = ShopTaskPrep_Practice
%
%This function creates all variables needed for the practice trials of the
% Shoptask.
%

%%                      Set working dirs                                 %%

%Stimulus direcotry
stimdir = [pwd '\Practice Food Stimuli\'];

%%                            Prepare Stimuli                            %%

%Read all filenames
listing = dir(stimdir);
filenames = char(listing.name);

%first three entries are non informative
filenames(1:3,:) = [];

% Read filename to retrieve stimulus information, make two seperate vars
% for condition
stiminfo = cell(length(filenames(:,1))/2,6,2);

%Keep track of rownrs
u_count = 1;
h_count = 1;

for j = 1:length(filenames(:,1))

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
    for i = 1:(length(filenames(:,1))/2)

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
h_imagetextures = cell(2,length(filenames(:,1))/2);
u_imagetextures = cell(2,length(filenames(:,1))/2);

for j = 1:2
    for i = 1:length(filenames(:,1))/2
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

c.order = shuffle([zeros(1,length(h_imagetextures))+1, zeros(1,length(h_imagetextures))]); 

for trial = 1:length(c.order)

    if c.order(trial) == 1
        %include a hedonic trial
        c.trial(:,trial) = h_imagetextures(:,end);
        %delete it from the list
        h_imagetextures = h_imagetextures(:,1:end-1);
    else
        %include an utilitrian trial
        c.trial(:,trial) = u_imagetextures(:,end);
        %delete it from the list
        u_imagetextures = u_imagetextures(:,1:end-1);
    end
end

vars = c;

end
