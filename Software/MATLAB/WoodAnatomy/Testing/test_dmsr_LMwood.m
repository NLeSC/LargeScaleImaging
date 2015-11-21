% test_dmsr_LMwood- testing DMSR detector on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 15 October 2015
% last modification date: 
% modification details: 

%% header message
disp('Testing DMSR detector on LMwood data');

%% parameters
save_flag = 1;
vis_flag = 1;
vis_only = false;
batch =  true;

SE_size_factor = 0.005;
Area_factor_very_large = 0.005;
Area_factor_large = 0.0005;
lambda_factor = 2;
num_levels = 255;
offset = 80;
otsu_only = true;
conn = 4;
weight_all = 0.33;
weight_large = 0.33;
weight_very_large = 0.33;
verbose = 0;
visualize_major = 0;
visualize_minor = 0;
saliency_type = [0 1 0 0];


morphology_parameters = [SE_size_factor Area_factor_very_large ...
    Area_factor_large lambda_factor conn];
weights = [weight_all weight_large weight_very_large];
execution_flags = [verbose visualize_major visualize_minor];
            
%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Stem'};
end

for test_case = test_cases
    disp(['Processing species: ' test_case]); 
    
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
           get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    %% run the detector
    num_images = length(image_filenames);
    
   for i = 1:num_images 
   % for i =1 
        data_filename = char(image_filenames{i});
        result_filename = char(regions_filenames{i});
        %% load                
        image_data_orig = imread(data_filename);        
        if ~ismatrix(image_data_orig)
            image_data_2D = rgb2gray(image_data_orig);
        end
        
        if not (vis_only)
            %% extract
            tic
            
            [num_regions, features, saliency_masks] = dmsr(image_data_2D,[],...
                num_levels, offset,...
                otsu_only, saliency_type, ...
                morphology_parameters, weights, ...
                execution_flags);
            
            toc
            
            %% save
            save_regions(detector, char(features_filenames{i}), ...
                char(regions_filenames{i}), num_regions, features, saliency_masks);
        end
        %% visualize
        
        if vis_flag
            disp('Displaying... ');
            
            type = 1; % distinguish region's types
            
            list_smartregions = [];     % display all regions
            
            scaling = 1;  % no scaling
            line_width = 2; % thickness of the line
            labels = 0; % no region's labels
            
            col_ellipse = [];
            col_label = [];
            step_list_regions = [];
            
            original = 0; % no original region's outline
            
            display_smart_regions(char(image_filenames{i}), detector, ...
                char(features_filenames{i}), [], ...
                char(regions_filenames{i}), type, ...
                list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
                line_width, col_label, original);
        end
        
        [~,name,~] = fileparts(data_filename);
        title(['DMSR elliptical regions for ' num2str(name)]);
       
        
        
        %% cleanup
        close; 
    end
    disp('---------------------------------------------------------------');
end