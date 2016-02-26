% hist_distance_LMwood- manual similarity between LMwood images
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 28 January 2016
% last modification date:
% modification details:

%% header message
disp('Similarity between the LMwood images');

%% execution parameters
verbose = 1;
visualize = 1;
batch = 1;

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



%% loop over images
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
    
    %%loop over images
    for i = 1:num_images
        j =j+1;
        %% load data
        image_filename = char(image_filenames{i});
        [~, baseFileName, ~] = fileparts(image_filename);
        
        YLabels{j} = strcat(baseFileName, ' :  ', num2str(j));
        
    end
end


%% matrix S(imilarity)
% SU =zeros(j,j);
% 
% SU(1,:) = [0.45 0.45 0.8 0.8 0.6 0.6 0.2 0.2 0.3 0.3 0.4 0.4 0.4 0.4 0.8 0.8 0.9 0.9 1];
% % copy the upper part to the lowerpart  (symmetric)
% S = SU +  SU' - diag([diag(SU)]);
load('/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/sim_er.mat');
S = sim_er;
%% visualize
figure;
hold on;
imagesc(S);
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
title('Manual similarity', 'Interpreter', 'none');

hold on;
[M,N] = size(S);

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

