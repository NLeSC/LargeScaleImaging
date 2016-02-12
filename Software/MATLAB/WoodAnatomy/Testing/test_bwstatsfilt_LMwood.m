% test_bwstatsfilt_LMwood- testing the bw region filtering of LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 12 Febr 2016
% last modification date: 
% modification details: 

%% header message
disp('Testing DMSR derived region properties (statistics) filtering of LMwood data');

%% parameters
verbose = 1;
visualize = 1;

%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';
test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
    
    
%% processing all test cases
for test_case = test_cases
    disp(['Processing species: ' test_case]);
    
    
    [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    num_images = length(image_filenames);
    %% process the images
    for i = 1 :num_images
        %% load the needed data- regions, saliency_masks etc.
        image_filename = char(image_filenames{i});
        regions_filename = char(regions_filenames{i});
        regions_props_filename = char(regions_props_filenames{i});
        load(regions_filename);
        load(regions_props_filename);
        clear histograms regions_properties
        
        %% get the original image (for visualization only)
        if visualize
            [pathstr,base_name,ext] = fileparts(image_filename);
            image_data = imread(image_filename);
        end
        %% get the binary image from the saliency_masks
        bw = logical(saliency_masks);
        clear saliency_masks
        
        %% set_upfilterring conditions
        stats_types = {'RelativeArea', 'Solidity'};
        range  = [0.2 1]; % cut off the bottom 20% ofthe Area
        stats_values = cat(1,statistics.(char(stats_types{1})));
        max_value  = max(stats_values(:));
        lo_thr = range(1)*max_value;
        hi_thr = range(2)*max_value;
        logic_ops = {'AND'};
        ranges = {[lo_thr hi_thr], [0.85 1]}; 
        
        % stats_types = {'Orientation','Orientation','Eccentricity'};
        % logic_ops = {'Or','AND'};
        % ranges = {[-90 -60],[60 90],[0.8 1]};
              
        %% run filtering function 
        [bw_filt, regions_idx, threshs] = bwstatsfilt(bw, statistics, stats_types, ...
            logic_ops, conn_comp, ranges);
        clear conn_comp
        %% show
        if visualize
            f =  figure('units','normalized','outerposition',[0 0 1 1]);
            figure(f);
            subplot(221); imshow(image_data);title(base_name, 'Interpreter','none');
            subplot(222); imshow(bw); title('All DMSR regions: binary mask');
            subplot(223); imshow(bw_filt); title('Filtered DMSR regions: binary mask');
            xlabel('Filter condition: ');
        end
        if verbose
            disp('------------------------------------------------------------');
        end
    end
end