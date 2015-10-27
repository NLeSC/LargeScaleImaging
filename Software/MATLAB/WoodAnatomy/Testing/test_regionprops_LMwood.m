% test_regionprops_LMwood- testing the DMSR region properties on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 23 October 2015
% last modification date: 27 October 2015
% modification details: the region properties computation is now in a generic
% function

%% header message
disp('Testing DMSR region properties of LMwood data');

%% parameters
verbose = 0;
visualize = 1;

%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

for test_case = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'}
    disp(['Processing species: ' test_case]);
    
    %% get the filenames
    [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    
    num_images = length(image_filenames);
    
    for i = 1:num_images
    %for i = 1
        regions_filename = char(regions_filenames{i});
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
                L = bwlabel(saliency_masks(:,:,j));
                imshow(label2rgb(L));title('Salient regions of same type labelled');
                axis on, grid on 
            end
            if sal_types > 1
                j = j+ 1;
                L = bwlabel(saliency_masks(:,:,j));
                subplot(x,y,j);
                imshow(label2rgb(L));title('Salient regions  of same type labelled');
                axis on, grid on
            end
            if sal_types > 2
                j = j+ 1;
                L = bwlabel(saliency_masks(:,:,j));
                subplot(x,y,j);
                imshow(label2rgb(L));title('Salient regions of same type labelled');
                axis on, grid on
            end
            if sal_types > 3
                j = j+ 1;
                L = bwlabel(saliency_masks(:,:,j));
                subplot(x,y,j);
                imshow(label2rgb(L)); title('Salient regions of same type labelled');
                axis on, grid on
            end
        end
        
        %% compute region properties of the salient regions
        types_props = {'Area', 'Centroid','ConvexArea', ...
            'Eccentricity', 'EquivDiameter', 'MinorAxisLength',...
            'MajorAxisLength', 'Orientation'};
        [regions_properties] = compute_region_props(saliency_masks, ...
            types_props);
        %% save the calculated properties
        save(regions_props_filename, 'regions_properties');
        clear saliency_masks regions_properties
    end
    
end