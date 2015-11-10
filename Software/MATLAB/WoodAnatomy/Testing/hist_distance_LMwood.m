% hist_distance_LMwood- distances betweem histograms of the DMSR statistics on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 10 November 2015
% last modification date:
% modification details:

%% header message
disp('Distances between the histograms of the DMSR statistics of LMwood data');

%% execution parameters
verbose = 1;
visualize = 1;
sav_flag = 1;
batch =  true;
visualize_only = false;

%% region properties and statistics
% derived statistics of the properties
types_stats = {'RelativeArea', 'Eccentricity', 'Orientation', 'RatioAxesLengths'};

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


for ts = types_stats
    type_stat = char(ts);
    disp(['Loading data for statistic: ' type_stat]);
    
    j = 0;
    for test_case = test_cases
        disp(['Loading data for species: ' test_case]);
        
        %% get the filenames
        [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
            get_wood_test_filenames(test_case, detector, data_path, results_path);
        
        
        num_images = numel(image_filenames);
        
        for i = 1:num_images
            %for i = 1
            j = j+1;
            
            %% load data
            %         image_filename = char(image_filenames{i});
            %         features_filename = char(features_filenames{i});
            %         regions_filename = char(regions_filenames{i});
            regions_props_filename = char(regions_props_filenames{i});
            
            %         image_data = imread(image_filename);
            %         [width, length, ~] = size(image_data);
            %         image_area = width * length;
            
            
            load(regions_props_filename);
            
            %% compute the matrix of distances
            
            h(j,:) = histograms.(type_stat);
        end
    end
    clear regions_properties statistics histograms
    dist_func=@chi_square_statistics_fast;
    D=pdist2(h,h,dist_func);
    
    figure;imagesc(D);
    axis square
    axis on, grid on
    load MyColormaps
    colormap(mycmap);
    colorbar;
    title([ts ': histogram distance']);
end