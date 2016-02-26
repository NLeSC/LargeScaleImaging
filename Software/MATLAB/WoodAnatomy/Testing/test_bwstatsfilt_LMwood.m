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
batch = true;
%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Stem'};
end
    
    
%% processing all test cases
for test_case = test_cases
    if verbose
        disp(['Processing species: ' test_case]);
    end
    
    [image_filenames, features_filenames, regions_filenames,...
        regions_props_filenames, filtered_regions_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    pause;
    num_images = length(image_filenames);
    %% process the images
    for i = 1: num_images
        %% load the needed data- regions, saliency_masks etc.
        image_filename = char(image_filenames{i});
        regions_filename = char(regions_filenames{i});
        features_filename = char(features_filenames{i});
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
%         stats_types = {'RelativeArea', 'Solidity'};
%         range1  = [0.2 1]; % cut off the bottom 20% of the Area
%         range2 = [0.85 1];
%         stats_values = cat(1,statistics.(char(stats_types{1})));
%         max_value  = max(stats_values(:));
%         lo_thr = range_area(1)*max_value;
%         hi_thr = range_area(2)*max_value;
%         logic_ops = {'AND'};
%         ranges = {[lo_thr hi_thr], range_sol};
%         ranges_fig = {range_area, range_sol};
        
%         stats_types = {'Orientation','Orientation','Eccentricity', 'RelativeArea'};
%         logic_ops = {'Or','AND','AND'};
%         range_area = [0 0.2];
%         ranges = {[-90 -55],[55 90],[0.75 1],range_area};
%         ranges_fig = ranges;
%         stats_values = cat(1,statistics.(char(stats_types{end})));
%         max_value  = max(stats_values(:));
%         lo_thr = range_area(1)*max_value;
%         hi_thr = range_area(2)*max_value;
%         ranges{end} = [lo_thr hi_thr];
        
%         stats_types = {'RelativeArea', 'Solidity'};
%         range_area  = [0 0.199]; 
%         range_sol = [0.85 1];
%         stats_values = cat(1,statistics.(char(stats_types{1})));
%         max_value  = max(stats_values(:));
%         lo_thr = range_area(1)*max_value;
%         hi_thr = range_area(2)*max_value;
%         logic_ops = {'AND'};
%         ranges = {[lo_thr hi_thr], range_sol};
%         ranges_fig = {range_area, range_sol};

%          stats_types = {'Orientation','Orientation','Eccentricity', 'Solidity', 'RelativeArea'};
%          range_ori1 = [-90 -55];
%          range_ori2 = [55 90];
%          range_ecc= [0.75 1];
%          range_area  = [0 0.2]; 
%          range_sol = [0.85 1];
%          stats_values = cat(1,statistics.(char(stats_types{end})));
%          max_value  = max(stats_values(:));
%          lo_thr = range_area(1)*max_value;
%          hi_thr = range_area(2)*max_value;
%          logic_ops = {'OR','AND','AND', 'AND'};
%          ranges = {range_ori1, range_ori2, range_ecc, range_sol, [lo_thr hi_thr]};
%          ranges_fig = {range_ori1, range_ori2,range_ecc, range_sol,range_area};         

        % stats_types = {'Orientation','Orientation','Orientation','Orientation','Eccentricity', 'Solidity', 'RelativeArea'};
         stats_types = {'Eccentricity', 'Solidity', 'RelativeArea'};
         range_ori1 = [-90 -70];
         range_ori2 = [70 90];
         range_ori3 = [-20 0];
         range_ori4 = [0 20];
         range_ecc= [0 0.85];
         range_area  = [0 0.199]; 
         range_sol = [0.85 1];
         stats_values = cat(1,statistics.(char(stats_types{end})));
         max_value  = max(stats_values(:));
         lo_thr = range_area(1)*max_value;
         hi_thr = range_area(2)*max_value;
%          logic_ops = {'OR','OR','OR','AND','AND', 'AND'};
%          ranges = {range_ori1, range_ori2, range_ori3, range_ori4, range_ecc, range_sol, [lo_thr hi_thr]};
%          ranges_fig = {range_ori1, range_ori2, range_ori3, range_ori4, range_ecc, range_sol,range_area};   
         logic_ops = {'AND', 'AND'};
         ranges = {range_ecc, range_sol, [lo_thr hi_thr]};
         ranges_fig = {range_ecc, range_sol,range_area}; 
        %% run filtering function 
        [bw_filt, regions_idx, threshs] = bwstatsfilt(bw, statistics, stats_types, ...
            logic_ops, conn_comp, ranges);
        clear conn_comp
        %% show
        if visualize
            f =  figure('units','normalized','outerposition',[0 0 1 1]);
            figure(f);
            subplot(221); imshow(image_data);title(base_name, 'Interpreter','none');
            axis on, grid on
            subplot(222); imshow(bw); title('All DMSR regions: binary mask');
            axis on, grid on
            subplot(223); imshow(bw_filt); title('Filtered DMSR regions: binary mask');
            axis on, grid on
            caption = []; num_conds = length(stats_types); 
            for c = 1:num_conds
                if c< num_conds
                    caption =[caption char(stats_types{c}) ' in [' num2str(ranges_fig{c}(1)) ' ' num2str(ranges_fig{c}(2)) '] ' char(logic_ops{c}) ' '];
                else
                    caption =[caption char(stats_types{c}) ' in [' num2str(ranges_fig{c}(1)) ' ' num2str(ranges_fig{c}(2)) '].'];
                end
            end
            
            xlabel(['Filterring: ' caption]);
            
            % display filtered regions
            sbp4 = subplot(224); 
            list_smartregions = regions_idx';
            %list_smartregions = []; % plot all
            step_list_regions  = 1;
            type = 1; % distinguish region's types
            scaling = 1;  % no scaling
            line_width = 2; % thickness of the line
            labels = 0; % no region's labels
            
            col_ellipse = [];
            col_label = 'green';
            
            original = 0; % no original region's outline
            
            display_smart_regions(image_filename, detector, features_filename, [], ...
                regions_filename,type, ...
                list_smartregions,step_list_regions,scaling, labels, col_ellipse, ...
                line_width, col_label, original, f, sbp4);
            if labels
                title('Filtered DMSR regions with their indicies over image');
            else
                title('Filtered DMSR regions over image');
            end
            axis on, grid on            
           % disp('Pause- press a key');pause;
        end
        clear caption
        if verbose
            disp('------------------------------------------------------------');
        end

    end
end