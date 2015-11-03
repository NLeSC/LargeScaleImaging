% hist_regionprops_LMwood- histograms of the DMSR region properties on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 3 November 2015
% last modification date: 
% modification details: 

%% header message
disp('Histograms of the DMSR region properties of LMwood data');

%% parameters
verbose = 1;
visualize = 1;
sav_flag = 1;
batch =  true;
visualize_only = false;
nbins = 50;

types_props = {'Area', 'ConvexArea', ... % 'Centroid'
    'Eccentricity', 'EquivDiameter', 'MinorAxisLength',...
    'MajorAxisLength', 'Orientation'};
%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s' , 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Stem'};
end

for test_case = test_cases
    disp(['Processing species: ' test_case]);
    
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    
    num_images = length(image_filenames);
    
    for i = 1:num_images
    %for i = 1
        image_filename = char(image_filenames{i});
        features_filename = char(features_filenames{i});
        regions_filename = char(regions_filenames{i});
        regions_props_filename = char(regions_props_filenames{i});
        
        if verbose
            disp(regions_props_filename);
        end
        
        %% load the DMSR regions properties
        load(regions_props_filename);
        num_regions = length(regions_properties);
        
        %% compute the histograms of regions properties
        if not(visualize_only)
            if verbose
                disp('Compute regions properties histograms');
            end
            for type_props = types_props
                type_prop = char(type_props);
                
                property = cat(1, regions_properties.(type_prop));
                histograms.(type_prop) =  histnorm(property, nbins);
                
            end
            
            if sav_flag
                if verbose
                    disp('Saving computed histograms');
                end
                save(regions_props_filename, 'histograms', '-append');
            end
        end
        %% visualize
        if visualize
            %% setup
            f =  figure('units','normalized','outerposition',[0 0 1 1]);
            s(1) = subplot(331);s(2) = subplot(332);s(3) = subplot(333);
            s(4) = subplot(334);s(5) = subplot(335);s(6) = subplot(336);
            s(7) = subplot(337);s(8) = subplot(338);s(9) = subplot(339);
            
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
            [pathstr,name,ext] = fileparts(image_filename);
            title(['DMSR elliptical regions for ' num2str(name)]);
            xlabel(['Number of regions detected: ', num2str(num_regions)]);
            ylabel(['Displayed every ',num2str(step_list_regions) , 'st/nd/rd/th']);
            axis on; grid on;
            
            %% visualize region properties histograms
            if visualize_only
                load(regions_props_filename);
            end
            sbp = 2;
            for type_props = types_props
                type_prop = char(type_props);
                sbp = sbp + 1;
                subplot(s(sbp)); bar(histograms.(type_prop));
                title(type_prop); axis on; grid on;
            end
        end
        clear regions_properties histograms
    end
    
end