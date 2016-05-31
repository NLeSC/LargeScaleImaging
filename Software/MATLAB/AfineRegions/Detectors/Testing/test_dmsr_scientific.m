% test_dmsr_scientific.m- testing the DMSR detector on Scientific datasets
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 20-11-2015
% last modification date: 
% modification details: 
%**************************************************************************
%% paramaters
interactive = false;
verbose = false;
visualize = false;
visualize_major = false;
visualize_minor = false;
lisa = false;

test_domain = 'AnimalBiometrics';
test_case = 'whales';

if interactive
    %             SE_size_factor = input('Enter the Structuring Element size factor: ');
    %             Area_factor = input('Enter the Connected Component size factor (processing): ');
    %             num_levels = input('Enter the number of gray-levels: ');
else
    %% parameters
    SE_size_factor = 0.01; %0.02;
    Area_factor_very_large = 0.01;
    Area_factor_large = 0.001;
    lambda_factor = 1; %3
    step_size = 1;
    offset = 80;
    otsu_only = true; % false
    conn = 8;
    weight_all = 0.33;
    weight_large = 0.33;
    weight_very_large = 0.33;
    saliency_type = [1 1 1 1];
end

if length(find(saliency_type)) > 2
    detector = 'DMSRA';
else
    detector = 'DMSR';
end

save_flag = 0;
vis_flag = 1;
vis_only = false;

%% image filename
if ispc 
    starting_path = fullfile('C:','Projects');
elseif lisa
     starting_path = fullfile(filesep, 'home','elenar');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'Data', 'Scientific');
results_path = fullfile(project_path, 'Results', 'Scientific');

%test_domain = input('Enter test domain: [AnimalBiometrics|Medical|Forestry]: ','s');

if interactive
    test_images = input('Enter test case: [...]: ','s');
    mask_filename = input('Enter the mask filename (.mat): ', 's');
    test_case = input('Enter test case: [whales|turtles|penguins|newt|other]: ','s');
else
    switch lower(test_domain)
        case 'animalbiometrics'
            domain_path = fullfile(data_path,'AnimalBiometrics');
            domain_results_path = fullfile(results_path,'AnimalBiometrics');

            switch lower(test_case)
                case 'turtles'
                    test_case_name = 'leatherbacks';
                case 'whales'
                    test_case_name = 'humpback_whales';
                case 'newt'
                    test_case_name = 'newt';
                case 'penguins'
                    test_case_name = 'african_penguin';
                case 'other'
                    test_case_name = 'other';  
            end
        case 'medical'
            domain_path = fullfile(data_path,'Medical');
            domain_results_path = fullfile(results_path,'Medical');
            test_case_name = input('Enter test case: [MRI|CT|retina]: ','s');
        case 'forestry'
            domain_path = fullfile(data_path,'Forestry');
            domain_results_path = fullfile(results_path,'Forestry');
            test_case_name = '';
    end
end
 
mask_filename =[];

data_test_path = fullfile(domain_path, test_case_name);
results_domain_path = fullfile(domain_results_path,test_case_name); 
images_list = dir(data_test_path);

disp('**************************** Testing detector *****************');
disp(detector);
%% run for all test cases

    results_path_full = fullfile(results_domain_path, test_case_name);
    [image_filenames, features_filenames, regions_filenames] = ...
        get_filenames_path(detector, data_test_path, results_domain_path);
 
    %% find out the number of test files
    len = length(image_filenames);
    
    %% loop over all test images
    for i = 1 :len
         disp('Test image #: ');disp(i);
        %% load the image & convert to gray-scale if  color
        image_data_or = imread(char(image_filenames{i}));
        if ndims(image_data_or) > 2
            image_data = rgb2gray(image_data_or);
        else
            image_data = image_data_or;
        end
        
        %% load the mask, if any
        ROI = [];
        if ~isempty(mask_filename)
            s = load(ROI_mask_fname);
            s_cell = struct2cell(s);
            for k = 1:size(s_cell)
                field = s_cell{k};
                if islogical(field)
                    ROI = field;
                end
            end
            if isempty(ROI)
                error('ROI_mask_fname does not contain binary mask!');
            end
        end
        
        %% run the DMSR detector
        if not(vis_only)
            
            
            %% run
            tic;
            
            morphology_parameters = [SE_size_factor Area_factor_very_large ...
                Area_factor_large lambda_factor conn];
            weights = [weight_all weight_large weight_very_large];
            execution_flags = [verbose visualize_major visualize_minor];
            
            [num_regions, features, saliency_masks] = dmsr(image_data,ROI,...
                step_size, offset,...
                otsu_only, saliency_type, ...
                morphology_parameters, weights, ...
                execution_flags);
            toc
            % save the features
            disp('Saving ...');
            save_regions(detector, char(features_filenames{i}), char(regions_filenames{i}), num_regions, features, saliency_masks);
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
                char(features_filenames{i}), mask_filename, ...
                char(regions_filenames{i}), type, ...
                list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
                line_width, col_label, original);
        end
       % if batch_structural
            %pause(10);
            %close
       % end
    end
        disp('****************************************************************');
disp('--------------- The End ---------------------------------');