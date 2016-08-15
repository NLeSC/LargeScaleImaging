% test_filter_regions.m- script to test filter_regions function

%% load data
im = imread('Blobs.png');
bw = logical(rgb2gray(im));
im_area = size(bw,1)*size(bw,2);
disp(['Image area: ' num2str(im_area)]);
%% preprocess
conn_comp = bwconncomp(bw);
labeled = labelmatrix(conn_comp);
list_properties = {'Centroid','Area','Eccentricity'};
stats = regionprops(conn_comp, list_properties);
stats_table = struct2table(stats);
stats_table.Properties.RowNames = {'1', '2', '3', '4', '5', '6','7', '8', '9','10'};
disp('Region props: '); disp(stats_table(:, [1 3]));
%% visualize data
figure;set(gcf, 'Position', get(0, 'Screensize'));
subplot(221); imshow(bw);title('Binary blobs');
subplot(222); imshow(label2rgb(labeled));title('Region labels');
for k = 1:numel(stats)
    hold on;
    if k <= 3
        col= 'w';
    else
        col = 'k';
    end
    text(stats(k).Centroid(1), stats(k).Centroid(2), num2str(k),'Color',col);
end
hold off

%% test1- single condition
disp('********************************************************************');
disp('Test1: single condition (Area > 0.01*image area)');

prop_types = {'Area'};
ranges = {[0.01*im_area im_area]};
disp('Filterring...');
[bw_filt, regions_idx, threshs] = filter_regions(bw, stats, prop_types, {}, ranges, conn_comp);
subplot(223);imshow(bw_filt); title('Filtered regions - single condition');
for k = 1:length(regions_idx)
    hold on;
    col = 'k';
    text(stats(regions_idx(k)).Centroid(1), stats(regions_idx(k)).Centroid(2), ...
        num2str(regions_idx(k)),'Color',col);
end
hold off
disp(['Thresholds Area: ', num2str(threshs{1})]);
disp(['Regions index list: ', num2str(regions_idx')]);

%% test2- dobule condition
disp('********************************************************************');
disp('Test2: double condition (Area > 0.01*image area) OR (Eccentricity in [0.1 0.8])');

prop_types = {'Area','Eccentricity'};
ranges = {[0.01*im_area im_area],[0.1 0.8]};
logic_opts = {'OR'};
disp('Filterring...');
[bw_filt, regions_idx, threshs] = filter_regions(bw, stats, prop_types, logic_opts, ranges);
subplot(224);imshow(bw_filt); title('Filtered regions - double condition');
for k = 1:length(regions_idx)
    hold on;
    col = 'k';
    text(stats(regions_idx(k)).Centroid(1), stats(regions_idx(k)).Centroid(2), ...
        num2str(regions_idx(k)),'Color',col);
end
hold off
disp(['Thresholds Area: ', num2str(threshs{1})]);
disp(['Thresholds Eccentricity: ', num2str(threshs{2})]);
disp(['Regions index list: ', num2str(regions_idx')]);


