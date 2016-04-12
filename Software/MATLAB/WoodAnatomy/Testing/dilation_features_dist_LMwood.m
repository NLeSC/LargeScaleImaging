%% dilation_features_dist_LMood- distances between dilation features of DMSR
%                               filtered regions on LM wood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 12 April 2016
% last modification date: 
% modification details:

%% header message
disp('Distances between the dilation features of the filtered DMSR regions of LMwood data');

%% execution parameters
verbose = 1;
visualize = 1;

%% parameters
distance_metrics = {'euclidean'}; %'seuclidean','cosine'};

test_cases = {'Argania' ,'Brazzeia_c', 'Brazzeia_s' , 'Chrys', 'Citronella',...
    'Desmo', 'Gluema', 'Rhaptop', 'Stem'};

% factor_large = 1/8;
% factor_small = 3/8;
% factor_small_ell_vert = 3/8;
% factor_small_round_hor = 1/8;
 factor_large = 0;
 factor_small = 2/5;
 factor_small_ell_vert = 2/5;
 factor_small_round_hor = 1/5;


%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';
detector  = 'DMSR';


%% loop over distances
for m = 1:numel(distance_metrics)
    %for m =1
    figure('units','normalized','outerposition',[0 0 1 1]);
    dm = char(distance_metrics{m});
    if verbose
        disp(['Using metric: ' dm]);
    end
    
    
    %% loop over test cases
    j =0;
    for test_case = test_cases
        if verbose
            disp(['Loading data for species: ' test_case]);
        end
        
        %% get the filenames
        [image_filenames, features_filenames, regions_filenames, ...
            regions_props_filenames, ~] = ...
            get_wood_test_filenames(test_case, detector, data_path, results_path);
        
        
        num_images = numel(image_filenames);
        
        %% loop over images per test case
        for i = 1:num_images
            j = j+1;
            
            %% load data
            image_filename = char(image_filenames{i});
            [~, baseFileName, ~] = fileparts(image_filename);
            
            YLabels{j} = strcat(baseFileName, ' :  ', num2str(j));
            regions_props_filename = char(regions_props_filenames{i});                                   
            
            load(regions_props_filename,'features');
            
            %% compute the matrix of distances
            % weight the features
            features(1,:) = factor_large * features(1,:);
            features(2,:) = factor_small * features(2,:);
            features(3,:) = factor_small_ell_vert * features(3,:);
            features(4,:) = factor_small_round_hor * features(4,:);
            all_features(j,:) = features(:)';
            
        end
    end
    
    D = pdist2(all_features,all_features,distance_metrics{m});
    
    %% visualize
   % subplot(2,2,k);
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
    ts = 'Similarity (1-dist) between features';
    title([ts 'of successive dilations of filtered DMSRegions'], 'Interpreter', 'none');
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