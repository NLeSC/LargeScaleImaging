% testing geometric distribution of centroids
% we consider only 4 images for the Chrys.(200microm) and Stem. species (500microm)
% and only the large roundish regions filtered out

%% setting up radius for the cirdular histograms
nrows_c = 1392;ncols_c = 1040;
res_C = 200/100;
diag_C = sqrt(nrows_c^2 + ncols_c^2);

res_S = 500/100;
nrows_s = 1288;ncols_s = 966;
diag_S = sqrt(nrows_s^2 + ncols_s^2);
fraction_factors = [0.1 0.25 0.5];
radiuses_C = diag_C * fraction_factors/res_C;
radiuses_S = diag_S * fraction_factors/res_S;

fnts = 7;

%% getting indexies of filtred regions
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Chrys afrPL01_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat', 'filtered_regions_idx')
regions_idx_C1 = filtered_regions_idx;
clear filtered_regions_idx
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Chrys afrPL02_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat', 'filtered_regions_idx')
regions_idx_C2 = filtered_regions_idx;
clear filtered_regions_idx
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Stemonurus celebicus 01_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat', 'filtered_regions_idx')
regions_idx_S1 = filtered_regions_idx;
clear filtered_regions_idx
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/filtered/LargeRoundish/BigAreaAndBigSolidity/Stemonurus celebicus 03_dmsrregions_filtered_AREA in_0.2_1_AND_S in_0.85_1.mat', 'filtered_regions_idx')
regions_idx_S3 = filtered_regions_idx;

clear filtered_regions_idx

%% getting all centroids
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Chrys afrPL01_dmsrregions_props.mat', 'regions_properties')
Centroids_C1 = cat(1,regions_properties.Centroid);
clear region_properties
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Chrys afrPL02_dmsrregions_props.mat', 'regions_properties')
Centroids_C2 = cat(1,regions_properties.Centroid);
clear region_properties
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Stemonurus celebicus 01_dmsrregions_props.mat', 'regions_properties')
Centroids_S1 = cat(1,regions_properties.Centroid);
clear region_properties
load('/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood/DMSR/Stemonurus celebicus 03_dmsrregions_props.mat', 'regions_properties')
Centroids_S3 = cat(1,regions_properties.Centroid);
clear region_properties

%% finding out only  the filtered centroids
C1 = Centroids_C1(regions_idx_C1,:);
C2 = Centroids_C2(regions_idx_C2,:);
S1 = Centroids_S1(regions_idx_S1,:);
S3 = Centroids_S3(regions_idx_S3,:);

%% visualize
figure;
subplot(221);
C= C1;
filt_reg = regions_idx_C1;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','red','FontSize',fnts);
end
hold off
grid on
title('C1- large roundish');
axis([1 nrows_c 1 ncols_c]); axis ij;

subplot(222);
C= C2;
filt_reg = regions_idx_C2;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','red','FontSize',fnts);
end
hold off
grid on
title('C2- large roundish');
axis([1 nrows_c 1 ncols_c]); axis ij;

subplot(223);
C= S1;
filt_reg = regions_idx_S1;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','red','FontSize',fnts);
end
hold off
grid on
axis([1 nrows_s 1 ncols_s]); axis ij;
title('S1- large roundish');

subplot(224);
C= S3;
filt_reg = regions_idx_S3;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','red','FontSize',fnts);
end
axis([1 nrows_s 1 ncols_s]); axis ij;
hold off
grid on
title('S3- large roundish');


