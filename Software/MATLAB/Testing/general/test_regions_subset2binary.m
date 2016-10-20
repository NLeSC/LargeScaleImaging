% test_regions_subset2binary.m- tetsing script for regions_subset2binary

im = imread('Blobs.png');
bw = logical(rgb2gray(im));
f = figure; subplot(221); imshow(bw);title('Binary blobs');
conn_comp = bwconncomp(bw,8);
labeled = labelmatrix(conn_comp);
figure(f); subplot(222);imshow(label2rgb(labeled));title('Region labels');
 
stats = regionprops(conn_comp,'Centroid');
for k = 1:conn_comp.NumObjects
hold on;
    if k <= 3
        col= 'w';
    else
        col = 'k';
    end
    text(stats(k).Centroid(1), stats(k).Centroid(2), num2str(k),'Color',col);
end
hold off

regions_ind = [1 3 5 7 9];

[bw_out] = regions_subset2binary(bw, regions_ind, 8);

figure(f);subplot(223); imshow(bw_out); title('Binary image containing only odd regions from the original');