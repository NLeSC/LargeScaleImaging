% hist_distance_LMwood- distances betweem histograms of the DMSR statistics on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 10 November 2015
% last modification date: 25 November 2015
% modification details:

%% header message
disp('Distances between the histograms of the DMSR statistics of LMwood data');

%% execution parameters
verbose = 1;
visualize = 1;
batch =  true;

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
%for m =1
    figure('units','normalized','outerposition',[0 0 1 1]);
    dm = func2str(distance_metrics{m});
    if verbose
        disp(['Using metric: ' dm]);
    end
    
    %% loop over statistics
    k = 0;
    for ts = types_stats
        type_stat = char(ts);
        if verbose
            disp(['Loading data for statistic: ' type_stat]);
        end
        
        j = 0;
        
        %% loop over images
        for test_case = test_cases
            if verbose
                disp(['Loading data for species: ' test_case]);
            end
            
            %% get the filenames
            [image_filenames, features_filenames, regions_filenames, regions_props_filenames] = ...
                get_wood_test_filenames(test_case, detector, data_path, results_path);
            
            
            num_images = numel(image_filenames);
            
            %%loop over images
            for i = 1:num_images
                j = j+1;
                
                %% load data
                image_filename = char(image_filenames{i});
                [~, baseFileName, ~] = fileparts(image_filename);
                
                YLabels{j} = strcat(baseFileName, ' :  ', num2str(j));
                regions_props_filename = char(regions_props_filenames{i});
                
                
                %         image_data = imread(image_filename);
                %         [width, length, ~] = size(image_data);
                %         image_area = width * length;
                
                
                load(regions_props_filename);
                
                %% compute the matrix of distances
                
                h(j,:) = histograms.(type_stat).N;
            end
        end
        clear regions_properties statistics histograms
        
        D = pdist2(h,h,distance_metrics{m});
        k = k+1;
        
        %% visualize
        subplot(2,2,k);
        hold on;
        imagesc(1-D);
        ax =gca;
        ax.XTick = [1:j];
        ax.XTickLabels = [1:j];
        ax.XTickLabelRotation = 45;
        ax.YTick = [1:j];
        ax.YTickLabel = YLabels;
       % ax.YTickLabelRotation = 30;
        
        axis square; axis on, grid on
        %load MyColormaps; colormap(mycmap);
        colormap(jet);
        colorbar;
        title([ts '(histogram similarity (1-dist))'], 'Interpreter', 'none');
        xlabel( ['Metric: ' dm], 'Interpreter', 'none');
        
        hold on;
        [M,N] = size(D);
        
        for l = [0.5,3.5, 5.5:2:19.5]
            x = [0.5 N+0.5];
            y = [l l];
            plot(x,y,'Color','w','LineStyle','-');
            plot(x,y,'Color','k','LineStyle',':');
        end
        
        for l = [0.5,3.5, 5.5:2:19.5]
            x = [l l];
            y = [0.5 M+0.5];
            plot(x,y,'Color','w','LineStyle','-');
            plot(x,y,'Color','k','LineStyle',':');
        end
        
        hold off;
        
        disp('-----------------------------------------------------------');
        
    end
    
    
end