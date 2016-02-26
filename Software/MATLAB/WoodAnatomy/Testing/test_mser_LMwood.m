% test_mser_LMwood- testing build-in MSER detector on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2015
% last modification date: 30 Sept 2015
% modification details: adapted to new dataset, displaying only elliptical
% regions

%% header message
disp('Testing MATLAB MSER detector on LMwood data');

%% constants
minArea =20;
maxArea= 40000;
regionAreaRange = [minArea maxArea];
%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'MSER_MATLAB';

for test_case = {'Argania','Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'}
    disp(['Processing species: ' test_case]); 
    
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames, ...
    regions_props_filenames, ~] = ...
           get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    %% runt he detector
    num_images = length(image_filenames);
    
    for i = 1:num_images 
        data_filename = char(image_filenames{i});
        result_filename = char(regions_filenames{i});
        %% load                
        image_data_orig = imread(data_filename);        
        if ~ismatrix(image_data_orig)
            image_data_2D = rgb2gray(image_data_orig);
        end
        
        %% extract
        tic
        MSERregions = detectMSERFeatures(image_data_2D, 'RegionAreaRange',regionAreaRange);
        toc
        
        %% save
        save(result_filename,'MSERregions');
        
        %% visualize
        f = figure; imshow(image_data_2D); hold on;
        plot(MSERregions);
        [pathstr,name,ext] = fileparts(data_filename); 
        title(['MSER (MATLAB) elliptical regions for ' num2str(name)]);
        hold off;
        
        %% cleanup
        close(f); clear MSERregions;
    end
    disp('---------------------------------------------------------------');
end