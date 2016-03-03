% testing geometric distribution of centroids
% we consider only 4 images for the Chrys.(200microm) and Stem. species (500microm)
% and only the large roundish regions filtered out

%% setting up radius for the cirdular histograms
nrows_c = 1392;ncols_c = 1040;
res_C = 100/200;
diag_C = sqrt(nrows_c^2 + ncols_c^2);

res_S = 100/500;
nrows_s = 1288;ncols_s = 966;
diag_S = sqrt(nrows_s^2 + ncols_s^2);
fraction_factors = [0.3 0.5 0.9];
col = {'red','blue','magenta'};
radiuses_C = diag_C * fraction_factors*res_C;
radiuses_S = diag_S * fraction_factors*res_S;
num_radiuses = length(fraction_factors);

max_number_regions = 45;
label_rot_angle  = 45;
fnts = 8;

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

%% finding out only the filtered centroids
C1 = Centroids_C1(regions_idx_C1,:);
C2 = Centroids_C2(regions_idx_C2,:);
S1 = Centroids_S1(regions_idx_S1,:);
S3 = Centroids_S3(regions_idx_S3,:);

%% visualize
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
s1 = subplot(221);
C= C1;
filt_reg = regions_idx_C1;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','black','FontSize',fnts);
end
hold off
grid on
title('C1- large roundish');
axis([1 nrows_c 1 ncols_c]); axis ij;

s2 = subplot(222);
C= C2;
filt_reg = regions_idx_C2;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','black','FontSize',fnts);
end
hold off
grid on
title('C2- large roundish');
axis([1 nrows_c 1 ncols_c]); axis ij;

s3 = subplot(223);
C= S1;
filt_reg = regions_idx_S1;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','black','FontSize',fnts);
end
hold off
grid on
axis([1 nrows_s 1 ncols_s]); axis ij;
title('S1- large roundish');

s4 = subplot(224);
C= S3;
filt_reg = regions_idx_S3;
for i=1:length(C)
    plot(C(i,1), C(i,2), 'k*'); hold on;
    text(C(i,1)+5, C(i,2)+5, num2str(filt_reg(i)),'Color','black','FontSize',fnts);
end
axis([1 nrows_s 1 ncols_s]); axis ij;
hold off
grid on
title('S3- large roundish');

%% compute how many other centroids fall within given circle(s) around each centroid (aka circular histograms)
num_points = length(C1);
counts_C1 = zeros(num_points, num_radiuses);
for i = 1:num_points
    % determine the current point and the remaining points
    other_points =[];
    current_point =  C1(i,:);
    % highight the current point
    figure(f1); subplot(s1); hold on;
    filt_reg = regions_idx_C1;
    plot(current_point(1), current_point(2), 'c*'); hold on;
    hold off
    
    if i>2
        other_points = [other_points; C1(1:i-1,:)];
    end
    if i< num_points
        other_points = [other_points; C1(i+1:end,:)];
    end
    
    % find distances from the current point tothe others
    distancies = pdist2(current_point, other_points);
    
    % count how many of the other poitns are within a given circle distance
    for j =  1:num_radiuses
        counts_C1(i,j) = length(find(distancies < radiuses_C(j)));
        figure(f1); subplot(s1); hold on;        
        text(current_point(1)-(5+10*j), current_point(2)-(5+10*j), ...
            num2str(counts_C1(i,j)),'Color',col{j},'FontSize',fnts-2);
    end    
end

num_points = length(C2);
counts_C2 = zeros(num_points, num_radiuses);
for i = 1:num_points
    % determine the current point and the remaining points
    other_points =[];
    current_point =  C2(i,:);
    % highight the current point
    figure(f1); subplot(s2); hold on;
    filt_reg = regions_idx_C2;
    plot(current_point(1), current_point(2), 'c*'); hold on;
    hold off
    
    if i>2
        other_points = [other_points; C2(1:i-1,:)];
    end
    if i< num_points
        other_points = [other_points; C2(i+1:end,:)];
    end
    
    % find distances from the current point tothe others
    distancies = pdist2(current_point, other_points);
    
    % count how many of the other poitns are within a given circle distance
    for j =  1:num_radiuses
        counts_C2(i,j) = length(find(distancies < radiuses_C(j)));
        figure(f1); subplot(s2); hold on;        
        text(current_point(1)-(5+10*j), current_point(2)-(5+10*j), ...
            num2str(counts_C2(i,j)),'Color',col{j},'FontSize',fnts-2);
    end    
end

num_points = length(S1);
counts_S1 = zeros(num_points, num_radiuses);
for i = 1:num_points
    % determine the current point and the remaining points
    other_points =[];
    current_point =  S1(i,:);
    % highight the current point
    figure(f1); subplot(s3); hold on;
    filt_reg = regions_idx_S1;
    plot(current_point(1), current_point(2), 'c*'); hold on;
    hold off
    
    if i>2
        other_points = [other_points; S1(1:i-1,:)];
    end
    if i< num_points
        other_points = [other_points; S1(i+1:end,:)];
    end
    
    % find distances from the current point tothe others
    distancies = pdist2(current_point, other_points);
    
    % count how many of the other poitns are within a given circle distance
    for j =  1:num_radiuses
        counts_S1(i,j) = length(find(distancies < radiuses_S(j)));
        figure(f1); subplot(s3); hold on;        
        text(current_point(1)-(5+10*j), current_point(2)-(5+10*j), ...
            num2str(counts_S1(i,j)),'Color',col{j},'FontSize',fnts-2);
    end       
end

num_points = length(S3);
counts_S3 = zeros(num_points, num_radiuses);
for i = 1:num_points
    % determine the current point and the remaining points
    other_points =[];
    current_point =  S3(i,:);
    % highight the current point
    figure(f1); subplot(s4); hold on;
    filt_reg = regions_idx_S3;
    plot(current_point(1), current_point(2), 'c*'); hold on;
    hold off
    
    if i>2
        other_points = [other_points; S3(1:i-1,:)];
    end
    if i< num_points
        other_points = [other_points; S3(i+1:end,:)];
    end
    
    % find distances from the current point tothe others
    distancies = pdist2(current_point, other_points);
    
    % count how many of the other poitns are within a given circle distance
    for j =  1:num_radiuses
        counts_S3(i,j) = length(find(distancies < radiuses_S(j)));
        figure(f1); subplot(s4); hold on;        
        text(current_point(1)-(5+10*j), current_point(2)-(5+10*j), ...
            num2str(counts_S3(i,j)),'Color',col{j},'FontSize',fnts-2);
    end     
end

%% visualize the counts
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
s1 = subplot(221);
filt_reg = regions_idx_C1;
num_points = length(C1);
for j = 1:num_radiuses
    plot(1:num_points, counts_C1(:,j),col{j}); hold on;
end
xlabel('Centroid (region) indicies'); ylabel('Number of centroids in the neighbourhood');
axis on; grid  on;
ax = gca;
set(ax,'XTick',1:num_points,'XTickLabels',num2str(filt_reg), ...
    'XTickLabelRotation',label_rot_angle);
axis([0 num_points+1 0 max_number_regions]);
legend(num2str(radiuses_C'));
title('C1');

s2 = subplot(222);
filt_reg = regions_idx_C2;
num_points = length(C2);
for j = 1:num_radiuses
    plot(1:num_points, counts_C2(:,j),col{j}); hold on;
end
xlabel('Centroid (region) indicies'); ylabel('Number of centroids in the neighbourhood');
axis on; grid  on;
ax = gca;
set(ax,'XTick',1:num_points,'XTickLabels',num2str(filt_reg), ...
    'XTickLabelRotation',label_rot_angle);
axis([0 num_points+1 0 max_number_regions]);
legend(num2str(radiuses_C'));
title('C2');

s3 = subplot(223);
filt_reg = regions_idx_S1;
num_points = length(S1);
for j = 1:num_radiuses
    plot(1:num_points, counts_S1(:,j),col{j}); hold on;
end
xlabel('Centroid (region) indicies'); ylabel('Number of centroids in the neighbourhood');
axis on; grid  on;
ax = gca;
set(ax,'XTick',1:num_points,'XTickLabels',num2str(filt_reg), ...
    'XTickLabelRotation',label_rot_angle);
axis([0 num_points+1 0 max_number_regions]);
legend(num2str(radiuses_S'));
title('S1');

s4 = subplot(224);
filt_reg = regions_idx_S1;
num_points = length(S3);
for j = 1:num_radiuses
    plot(1:num_points, counts_S3(:,j),col{j}); hold on;
end
xlabel('Centroid (region) indicies'); ylabel('Number of centroids in the neighbourhood');
axis on; grid  on;
ax = gca;
set(ax,'XTick',1:num_points,'XTickLabels',num2str(filt_reg), ...
    'XTickLabelRotation',label_rot_angle);
axis([0 num_points+1 0 max_number_regions]);
legend(num2str(radiuses_S'));
title('S3');

%% visualize histograms
f3 = figure('units','normalized','outerposition',[0 0 1 1]);
s1 = subplot(221);
%filt_reg = regions_idx_C1;
%num_points = length(C1);
for j = 1:num_radiuses
    %[N,edges] = histcounts(counts_C1(:,j), 20);
   % hist(counts_C1(:,j));
    %histogram.edges = edges(2:end); histogram.N= N;
    bar(edges(2:end), N, col{j}); hold on;
end
%xlabel('Centroid (region) indicies'); ylabel('Number of centroids in the neighbourhood');
axis on; grid  on;
%ax = gca;
%set(ax,'XTick',1:num_points,'XTickLabels',num2str(filt_reg), ...
%    'XTickLabelRotation',label_rot_angle);
%axis([0 num_points+1 0 max_number_regions]);
%legend(num2str(radiuses_C'));
title('C1');
hold off;