% test_regionprops_LMwood- testing the DMSR region properties on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 23 October 2015
% last modification date: 27 October 2015
% modification details: the region properties computation is now in a generic
% function
% last modification date: 3 Feb 2016
% modification details: the connected components are also computed and saved
% last modification date: 12 Feb 2016
% modification details: the connected components are computed with connectivity 4 (like DMSR)
%% header message
disp('Testing DMSR region properties of LMwood data');

%% parameters
verbose = 1;
visualize = 1;
batch = false;
conn = 4;
%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Argania'};
end
%% processing all test cases
for test_case = test_cases
    if verbose
        disp(['Processing species: ' test_case]);
    end
    
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
        
    num_images = length(image_filenames);
    
    %% process the images
    %for i = 1:num_images
    for i = 1
        regions_filename = char(regions_filenames{i});
        [pathstr,base_name,ext] = fileparts(regions_filename);
        regions_props_filename = char(regions_props_filenames{i});
        
        if verbose
            disp(regions_filename);
        end
        
        %% load the detected DMSR regions
        load(regions_filename);
        
        %% visualize
        % how many types of regions?
        sal_types = size(saliency_masks,3);
        if visualize
            figure; 
            switch sal_types
                case 1
                    x = 1; y = 1;
                case 2
                    x = 1; y = 2;
                case {3, 4}
                    x=2; y= 2;
            end
            j = 0;
            if sal_types > 0
                j = j+ 1;
                subplot(x,y,j);
                L = bwlabel(saliency_masks(:,:,j),conn);
                imshow(label2rgb(L));
                title(base_name, 'Interpreter','none');
                xlabel('Salient regions of same type labelled');
                axis on, grid on 
            end
            if sal_types > 1
                j = j+ 1;
                L = bwlabel(saliency_masks(:,:,j),conn);
                subplot(x,y,j);
                imshow(label2rgb(L));
                title(base_name, 'Interpreter','none');
                xlabel('Salient regions  of same type labelled');
                axis on, grid on
            end
            if sal_types > 2
                j = j+ 1;
                L = bwlabel(saliency_masks(:,:,j),conn);
                subplot(x,y,j);
                imshow(label2rgb(L));
                title(base_name, 'Interpreter','none');
                xlabel('Salient regions of same type labelled');
                axis on, grid on
            end
            if sal_types > 3
                j = j+ 1;
                L = bwlabel(saliency_masks(:,:,j),conn);
                subplot(x,y,j);
                imshow(label2rgb(L)); 
                title(base_name, 'Interpreter','none');
                xlabel('Salient regions of same type labelled');
                axis on, grid on
            end
        end
        
        %% compute region properties of the salient regions
        types_props = {'Area', 'Centroid','ConvexArea', ...
            'Eccentricity', 'EquivDiameter', 'MinorAxisLength',...
            'MajorAxisLength', 'Orientation', 'Solidity'};
        [regions_properties, conn_comp] = compute_region_props(saliency_masks, ...
            conn, types_props);
        %% save the calculated properties
        save(regions_props_filename, 'regions_properties', 'conn_comp');
        clear saliency_masks regions_properties conn_comp
                
        if verbose
            disp('------------------------------------------------------------');
        end
    end
    
end