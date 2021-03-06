% Processes all files in the my_pkgs/datasets folder 
% Stores all information in one struct 
clear; 
% path to folder containing datasets 
path = "/home/josh/TurtlebotTrials";
% create datastore
ds = fileDatastore(fullfile(path),'ReadFcn',@load_real_data,'FileExtensions','.bag');

% create struct array to hold all experiments in the folder
% first results are in last position to initialize the array efficiently 
numFiles = size(ds.Files,1); 
experiments(numFiles) = read(ds); 
fprintf("processed 1/%d\n",numFiles); 

% read each bag file from the folder 
% work backwards because of initialization 
j = 2; 
for i = numFiles-1:-1:1
    experiments(i) = read(ds);     
    fprintf("processed %d/%d\n",j,numFiles); 
    j = j+1; 
end

% save as .mat file 
clearvars -except experiments

save(sprintf("/home/josh/TurtlebotTrials/%s.mat",date))

beep; 