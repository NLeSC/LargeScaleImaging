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

% types distance metrics
distance_metrics = {@chi_square_statistics_fast, ...
    @histogram_intersection,...
    @kolmogorov_smirnov_distance,...
    @kullback_leibler_divergence,...
    @jeffrey_divergence,...
    @jensen_shannon_divergence,...
    @match_distance};

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




%% loop over distances
for m = 1:numel(distance_metrics)
    figure('units','normalized','outerposition',[0 0 1 1]);
    dm = func2str(distance_metrics{m});
    disp(['Using metric: ' dm]);
   
    %% loop over statistics
    k = 0;
    for ts = types_stats
        type_stat = char(ts);
        disp(['Loading data for statistic: ' type_stat]);
        
        j = 0;
        
        %% loop over images
        for test_case = test_cases
            disp(['Loading data for species: ' test_case]);
            
            %% get the filenames
            [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
                get_wood_test_filenames(test_case, detector, data_path, results_path);
            
            
            num_images = numel(image_filenames);
            
            %%loop over images
            for i = 1:num_images
                %    for i = 1
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
                       
      
        D = pdist2(h,h,distance_metrics{m});
        k = k+1;
        
        subplot(2,2,k);
        hold on;
        imagesc(D);
        ax =gca;
        ax.XTick = [1:j];
        ax.YTick = [1:j];
        axis square; axis on, grid on
        %load MyColormaps; colormap(mycmap);
        colormap(jet);
        colorbar;
        title([ts '(histogram distance)'], 'Interpreter', 'none');
            xlabel( ['Metric: ' dm], 'Interpreter', 'none');
        disp('-----------------------------------------------------------');
        
    end
    
    
end