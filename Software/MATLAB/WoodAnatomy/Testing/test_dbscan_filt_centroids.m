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
batch = true;

%% algorithm parameters
filtering_conditions_string = 'AREA in_0.2_1_AND_S in_0.85_1';
fraction_factor = 0.2;
MinPts = 2; % DBSCAN parameter
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
    switch char(test_case) % read it by hand from the image
        case {'Argania','Chrys', 'Gluema'}
            micro_res = 200;
        case {'Brazzeia_c', 'Brazzeia_s', 'Rhaptop','Stem' }
            micro_res = 500;
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
%         if verbose
%             disp('image_filename: '); disp(image_filename);
%             disp('regions_props_filename: '); disp(regions_props_filename);
%             disp('filtered_regions_filename: '); disp(filtered_regions_filename);
%         end
  
        % get the centroids
        if verbose
            disp('Get the centroids ...');
        end
        centroids = get_filtered_regions_centroids(regions_props_filename, filtered_regions_filename);
        
        % get the image dimensions snd decide on DBSCAN parameters
        image_data = imread(image_filename);
        [nrows, ncols,~] = size(image_data);
        clear image_data
        
        % get the algorithm parameters depending on the image size and the microscopy resolution 
        %% algorithm parameters
        res = 100/micro_res;
        diag = sqrt(nrows^2 + ncols^2);
        epsilon = diag * fraction_factor*res;% DBSCAN parameter
        
        %% DBSCAN on the centroid points
        if verbose
            disp('BDSCAN clusterring of the centroids ...');
        end
        Idx=DBSCAN(centroids,epsilon,MinPts);
        %% visualization
        if visualize
            figure('units','normalized','outerposition',[0 0 1 1]);
            PlotClusterinResult(centroids, Idx);
            axis ij; axis([1 ncols 1 nrows]); grid on;
            title(filt_name, 'Interpreter', 'none');
            
            xlabel(['DBSCAN Clustering (\epsilon = ' num2str(epsilon) ', MinPts = ' num2str(MinPts) ')']);
        end

        if verbose
            disp('----------------------------------------------------------');
        end
    end
end
if verbose
   disp('DONE.');
end