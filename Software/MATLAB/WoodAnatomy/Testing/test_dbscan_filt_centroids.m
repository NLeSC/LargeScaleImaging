% test_dbscan_filt_centroids.m - testing DBSCAN algorithms on the filtered regions centroids
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 16 Mar 2016
% last modification date: 
% modification details: 
%% header message
disp('Testing DBSCAN clusterring algorithm on filtered DMSR regions of LMwood data');

%% execution parameters
verbose = 1;
visualize = 1;
saving = 0;
batch = false;
filtering_conditions_string = 'AREA in_0.2_1_AND_S in_0.85_1';
%% algorithm parameters
nrows_c = 1392;ncols_c = 1040;
res_C = 100/200;
diag_C = sqrt(nrows_c^2 + ncols_c^2);

res_S = 100/500;
nrows_s = 1288;ncols_s = 966;
diag_S = sqrt(nrows_s^2 + ncols_s^2);
fraction_factor = 0.14;
radius_C = diag_C * fraction_factor*res_C;
radius_S = diag_S * fraction_factor*res_S;

%% paths
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';

if batch
    test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s', 'Chrys', 'Citronella',...
        'Desmo', 'Gluema', 'Rhaptop', 'Stem'};
else
    test_cases = {'Chrys'};
end

%% processing all test cases
for test_case = test_cases
    if verbose
        disp(['Processing species: ' test_case]);
    end
    
    [image_filenames, ~, ~, ...
        regions_props_filenames, filtered_regions_filenames_base] = ...
        get_wood_test_filenames(test_case, detector, data_path, results_path);
    
    num_images = length(image_filenames);
    %% process the images
    for i = 1: num_images
        
       % contruct the proper filenames storing old results
        image_filename = char(image_filenames{i});
        regions_props_filename = char(regions_props_filenames{i});        
        filtered_regions_filename_base = char(filtered_regions_filenames_base{i});        
        [filt_pathstr,filt_name,filt_ext] = fileparts(filtered_regions_filename_base);
        filt_name = [filt_name '_' filtering_conditions_string filt_ext];
        filtered_regions_filename = fullfile(filt_pathstr,filt_name); 
        if verbose
           % disp('image_filename: '); disp(image_filename);
            disp('regions_props_filename: '); disp(regions_props_filename);
            disp('filtered_regions_filename: '); disp(filtered_regions_filename);
        end
  
        % get the centroids
        centroids = get_filtered_regions_centroids(regions_props_filename, filtered_regions_filename);
        
        % get the image dimensions snd decide on DBSCAN parameters
        image_data = load(image_filename);
        [nrows, ncols] = size(image_data);
        clear image_data
        
        % get the resoltuion depending on the test case (TO DO: Find script
        % where this is already done!
    end
end

return;

%% DBSCAN clusterring
MinPts = 2;
epsilon = radius_C;

figure;
Idx_C1=DBSCAN(C1,epsilon,MinPts);
PlotClusterinResult(C1, Idx_C1);
axis ij; axis([1 nrows_c 1 ncols_c])
axis on; grid on;
title(['C1: DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);

figure;
Idx_C2=DBSCAN(C2,epsilon,MinPts);
PlotClusterinResult(C2, Idx_C2);
axis ij; axis([1 nrows_c 1 ncols_c])
axis on; grid on;
title(['C2: DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);

epsilon = radius_S;

figure;
Idx_S1=DBSCAN(S1,epsilon,MinPts);
PlotClusterinResult(S1, Idx_S1);
axis ij; axis([1 nrows_s 1 ncols_s])
axis on; grid on;
title(['S1: DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);

figure;
Idx_S3=DBSCAN(S3,epsilon,MinPts);
PlotClusterinResult(S3, Idx_S3);
axis ij; axis([1 nrows_s 1 ncols_s])
axis on; grid on;
title(['S3: DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);
