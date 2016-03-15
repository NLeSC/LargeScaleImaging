% test_dbscan_filt_centroids.m - testing DBSCAN algorithms on the filtered regions centroids
% we consider only 4 images for the Chrys.(200microm) and Stem. species (500microm)
% and only the large roundish regions filtered out

%% setting up parameters
nrows_c = 1392;ncols_c = 1040;
res_C = 100/200;
diag_C = sqrt(nrows_c^2 + ncols_c^2);

res_S = 100/500;
nrows_s = 1288;ncols_s = 966;
diag_S = sqrt(nrows_s^2 + ncols_s^2);
fraction_factor = [0.2];
radius_C = diag_C * fraction_factor*res_C;
radius_S = diag_S * fraction_factor*res_S;

%% filenames 
% filtred regions
filt_reg_fname_C1 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Chrys afrPL01_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat';
filt_reg_fname_C2 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Chrys afrPL02_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat';

filt_reg_fname_S1 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Stemonurus celebicus 01_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat';
filt_reg_fname_S3 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Stemonurus celebicus 03_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat';

% all regions properties
reg_props_fname_C1 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Chrys afrPL01_dmsrregions_props.mat';
reg_props_fname_C2 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Chrys afrPL02_dmsrregions_props.mat';

reg_props_fname_S1 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Stemonurus celebicus 01_dmsrregions_props.mat';
reg_props_fname_S3 = '/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Stemonurus celebicus 03_dmsrregions_props.mat';

%% finding out only the filtered centroids
C1 = get_filtered_regions_centroids(reg_props_fname_C1, filt_reg_fname_C1);
C2 = get_filtered_regions_centroids(reg_props_fname_C2, filt_reg_fname_C2);
S1 = get_filtered_regions_centroids(reg_props_fname_S1, filt_reg_fname_S1);
S3 = get_filtered_regions_centroids(reg_props_fname_S3, filt_reg_fname_S3);

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
