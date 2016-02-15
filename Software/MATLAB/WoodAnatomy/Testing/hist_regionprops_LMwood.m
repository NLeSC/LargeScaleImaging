% hist_regionprops_LMwood- histograms of the DMSR region properties on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 3 November 2015
% last modification date:
% modification details:

%% header message
disp('Histograms of the DMSR region properties of LMwood data');

%% execution parameters
verbose = 0;
visualize = 1;
sav_flag = 1;
batch =  false;
visualize_only = false;
nbins = 50;

%% region properties and statistics
% derived statistics of the properties
types_stats = {'RelativeArea', 'Eccentricity', 'Orientation', 'RatioAxesLengths', 'Solidity'};

%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s' , 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Argania'};
end

for test_case = test_cases
    disp(['Processing species: ' test_case]);
    
    %% specify microscopy resolution (can be 200 or 500 micrometers)
    % for now hard-coded...
    switch char(test_case) % read it by hand from the image
        case {'Argania','Chrys', 'Gluema'}
            micro_res = 200;
        case {'Brazzeia_c', 'Brazzeia_s', 'Rhaptop','Stem' }
            micro_res = 500;
    end
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    num_images = numel(image_filenames);
    
    %for i = 1:num_images
    for i = 1       
        %% specify microscopy resolution (can be 200 or 500 micrometers)
        % for now hard-coded...
        switch char(test_case) % read it by hand from the image
            case {'Citronella', 'Desmo'}
                switch i
                    case 1
                        micro_res = 500;
                    case 2
                        micro_res = 200;
                end
        end
        
        %% load data
        image_filename = char(image_filenames{i});
        features_filename = char(features_filenames{i});
        regions_filename = char(regions_filenames{i});
        regions_props_filename = char(regions_props_filenames{i});
        
        image_data = imread(image_filename);
        [width, length, ~] = size(image_data);
        image_area = width * length;
        
%         if verbose
%             disp(regions_props_filename);
%         end
        
        load(regions_props_filename);
        clear histograms
        num_regions = size(regions_properties);
        
        if not(visualize_only)
            %% prepare derived statistics
            if verbose
                disp('Compute statistics...');
            end
            for ts = types_stats
                type_stat = char(ts);
                switch type_stat
                    case {'RelativeArea'}
                        if verbose
                            disp('Compute relative area...');
                        end
                        areas = cat(1, regions_properties.Area);
                        statistics.(type_stat) = areas./image_area * (100/micro_res);
                    case {'Orientation', 'Eccentricity','Solidity'}
                        if verbose
                            disp('Assign already computed property to statistic...');
                        end
                        property = cat(1, regions_properties.(type_stat));
                        statistics.(type_stat) = property;
                    case {'RatioAxesLengths'}
                        if verbose
                            disp('Compute ratio of axes lengths...');
                        end
                        minor_axis_length = cat(1, regions_properties.MinorAxisLength);
                        major_axis_length = cat(1, regions_properties.MajorAxisLength);
                        statistics.(type_stat) = minor_axis_length./major_axis_length;
                end
            end
            if sav_flag
                if verbose
                    disp('Saving computed statistics...');
                end
                save(regions_props_filename, 'statistics', '-append');
            end
            %% compute the histograms of regions properties
            
            if verbose
                disp('Compute statistics histograms...');
            end
            for ts = types_stats
                
                type_stat = char(ts);
                statistic = cat(1, statistics.(type_stat));
                [N,edges] = histcounts(statistic, nbins);
                histograms.(type_stat).edges = edges(2:end);
                histograms.(type_stat).N = N;
                
            end
            
            if sav_flag
                if verbose
                    disp('Saving computed histograms...');
                end
                save(regions_props_filename, 'histograms',  '-append');
            end
        end
        %% visualize
        if visualize
            %% setup
            f =  figure('units','normalized','outerposition',[0 0 1 1]);
            s(1) = subplot(321);s(2) = subplot(322);s(3) = subplot(323);
            s(4) = subplot(324);s(5) = subplot(325);s(6) = subplot(326);
            % s(7) = subplot(337);s(8) = subplot(338);s(9) = subplot(339);
            
            %% show the image
            figure(f); %subplot(s(1));
            %imshow(image_data);
            [pathstr,name,ext] = fileparts(image_filename);
            %title([num2str(name)]);
            %% visualize the image and the detected regions
            type = 1; % distinguish region's types
            
            list_smartregions = [];     % display all regions
            
            scaling = 1;  % no scaling
            line_width = 2; % thickness of the line
            labels = 0; % no region's labels
            
            col_ellipse = [];
            col_label = [];
            step_list_regions = 5;
            
            original = 0; % no original region's outline
            
            display_smart_regions(image_filename, detector, ...
                features_filename, [], ...
                regions_filename, type, ...
                list_smartregions, step_list_regions, scaling, labels, col_ellipse, ...
                line_width, col_label, original, f, s(1));
            
            title(['DMSR elliptical regions for ' num2str(name)]);
            xlabel(['Number of regions detected: ', num2str(num_regions)]);
            ylabel(['Displayed every ',num2str(step_list_regions) , 'st/nd/rd/th']);
            axis on; grid on;
            
            %% visualize region properties histograms
            if visualize_only
                load(regions_props_filename);
            end
            sbp = 1;
            for ts = types_stats
                type_stat = char(ts);
                sbp = sbp + 1;
                subplot(s(sbp));
                h = histograms.(type_stat);
                bar(h.edges, h.N);                
                title(type_stat); axis on; grid on;
            end
        end
        clear regions_properties statistics %histograms
    end
    
end