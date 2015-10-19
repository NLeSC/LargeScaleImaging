% test_regionprops_LMwood- testing the DMSR region properties on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 19 October 2015
% last modification date: 
% modification details:

%% header message
disp('Testing DMSR region properties of LMwood data');

%% parameters
verbose = 0;
visualize = 1;

%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

for test_case = {'Argania','Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'}
    disp(['Processing species: ' test_case]);
    
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    %% load the detected DMSR regions
    num_images = length(image_filenames);
    
    for i = 1:num_images
        regions_filename = char(regions_filenames{i});
        
        if verbose
            disp(regions_filename);
        end
        load(regions_filename);
        figure; imshow
        clear saliency_masks
    end
    
end