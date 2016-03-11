% test_binary_detector.m- script to test the binary detector
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 11-03-2016
% last modification date:
% modification details:
% NOTE: replaces test_mssr_binary.m
%**************************************************************************
%% execution paramaters
interactive = false;
save_flag = 1;
vis_flag = 1;
vis_only = false;
vis_steps = false;
%% image filename
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
data_path = fullfile(project_path, 'TestData', 'Binary');
results_path = data_path;

if interactive
    % image_base_filename = input('Enter the base image filename: ','s');
    test_image = input('Enter test case: [all|noise|holes|islands|indent_protr|nested]: ','s');
else
    test_image = 'holes'
end
switch lower(test_image)
    case 'all'
        image_base_filename = 'Binary_all_types.png';
    case 'noise'
        image_base_filename = 'Binary_all_types_noise.png';
    case 'holes'
        image_base_filename = 'Binary_holes.png';
    case 'islands'
        image_base_filename = 'Binary_isalnds.png';
    case 'indent_protr'
        image_base_filename = 'Binary_indentations_protrusions.png';
    case 'nested'
        image_base_filename = 'Binary_nested.png';
    otherwise
        error('test_binary_detector: unknown test_image!');
end

[~,name,ext] = fileparts(image_base_filename);
image_filename = fullfile(data_path, image_base_filename);
dname = strcat(name, '.bin');
rname = strcat(name, '_binregions.mat' );
features_filename = fullfile(results_path,dname);
regions_filename = fullfile(results_path,rname);

%% algorithm parameters
detector = 'BIN';

if interactive
    saliency_types(1) = input('Detect "holes"? [0/1]: ');
    saliency_types(2) = input('Detect "islands"? [0/1]: ');
    saliency_types(3) = input('Detect "indentations"? [0/1]: ');
    saliency_types(4) = input('Detect "protrusions"? [0/1]: ');
    SE_size_factor = input('Enter the Structuring Element size factor: ');
    Area_factor = input('Enter the Connected Component size factor: ');
    conn = input('Enter the connectivity [4|8]: ');
else
    %saliency_types = [1 1 1 1]
    switch lower(test_image)
        case {'all', 'noise', 'nested'}
            saliency_types = [1 1 1 1];
        case 'islands'
            saliency_types = [0 1  0 0];
        case 'holes'
            saliency_types = [1 0 0 0];
        case 'indent_protr'
            saliency_types = [0 0 1 1];
        otherwise
            error('test_binary_detector: unknown test_image!');
    end
    SE_size_factor = 0.15
    Area_factor = 0.3
    conn = 4
end

% saliency types
holes_flag = saliency_types(1);
islands_flag = saliency_types(2);
indentations_flag = saliency_types(3);
protrusions_flag = saliency_types(4);

%% visualization parameters
if vis_flag || vis_only
    if interactive
        typ = input('Distinguish regions saliency type (hole/island/indentaion/protrusion)? [y/n]: ','s');
        if lower(typ)=='y'
            type = 1;
        else
            type = 0;
        end
        % enter the visualisation parameters
        all = input('Display all regions? [y/n]: ','s');
        if lower(all)=='y'
            list_regions = [];
        else
            list_regions = input('Enter the list of region numbers as vector: ');
        end
        step = input('Step in the list of regions? [y/n]:','s');
        if lower(step)=='y'
            step_list_regions = input('Enter the stepin list_regions: ');
        else
            step_list_regions = 1;
        end  
        scale = input('Scale the ellipses? [y/n]: ','s');
        if lower(scale)=='y'
            scaling = input('Enter the scaling factor: ');
        else
            scaling = 1;
        end        
        line = input('Thick line? [y/n]: ','s');
        if lower(line)=='y'
            line_width = input('Enter line thickness: ');
        else
            line_width = 1;
        end        
        lab = input('Show region numbers? [y/n]: ','s');
        if lower(lab)=='y'
            labels = 1;
        else
            labels = 0;
        end
        or = input('Show original region outlines? [y/n]: ','s');
        if lower(or)=='y'
            original = 1;
        else
            original = 0;
        end
    else
        type = 1; % distinguish region's types
        list_regions = [];     % display all regions
        scaling = 1;  % no scaling
        line_width = 2; % thickness of the line
        labels = 0; % no region's labels
        col_ellipse = [];
        col_label = [];
        step_list_regions = [];
        original = 0; % no original region's outline
    end
end

%% load the image
image_data = logical(imread(image_filename));


%% run the binary detector on the test image
disp('Binary detctor');
tic
[saliency_masks] = binary_detector(image_data, SE_size_factor,Area_factor,...
    saliency_types, vis_steps);
toc
%% convert the regions into ellipses
num_saliency_types = length(find(saliency_types));

tic;
i = 0;
num_regions =0;
features =[];

if holes_flag
    i = i+1;
    holes = saliency_masks(:,:,i);
    if find(holes)
        [num_sub_regions, sub_features] = binary_mask2features(holes, conn, 1);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end
if islands_flag
    i = i+1;
    islands = saliency_masks(:,:,i);
    if find(islands)
        [num_sub_regions, sub_features] = binary_mask2features(islands, conn, 2);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end
if indentations_flag
    i = i+1;
    indentations = saliency_masks(:,:,i);
    if find(indentations)
        [num_sub_regions, sub_features] = binary_mask2features(indentations, conn, 3);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end
if protrusions_flag
    i = i+1;
    protrusions = saliency_masks(:,:,i);
    if find(protrusions)
        [num_sub_regions, sub_features] = binary_mask2features(protrusions, conn, 4);
        num_regions = num_regions + num_sub_regions;
        features = [features; sub_features];
    end
end

%% save the regionsand elliptical representation
if save_flag
    disp('Saving the salient regions');
    save_regions(detector, features_filename, regions_filename, ...
        num_regions, features, saliency_masks);
end
%% visualize
if vis_only    
    % open saved regions
    [num_regions, features, saliency_masks] =...
    open_regions(detector,features_filename, regions_filename, type);
end

if vis_flag || vis_only
    disp('Visualizing the salient regions');
    % show regions color-coded per type overlaid on the original image
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    f2 = figure('units','normalized','outerposition',[0 0 1 1]);
    f3 = figure('units','normalized','outerposition',[0 0 1 1]);
    f4 = figure('units','normalized','outerposition',[0 0 1 1]);
    figs =[f1 f2 f3];
    visualize_regions_overlay(image_data, saliency_masks, saliency_types, figs);
    % show regions color-coded per typeas ellipses overlaid on the
    % originalimage

    display_smart_regions(image_filename, detector, features_filename, [], ...
    regions_filename, type, list_regions, step_list_regions, ...
    scaling, labels, col_ellipse, line_width, col_label,...
    original, f4, []);
        
    title('Elliptic representaiton ofthe regions overlaid on the image');
end