% test_mser_LMwood- testing build-in MSER detector on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2015
% last modification date: 
% modification details: 

% data
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
%image_filename = 'Ocinotis gracilis02.png';
%image_filename = 'Argania spinosa1.png';
image_filename = 'Carini decr01.png';


filename = fullfile(data_path, image_filename);

% load
image_data_orig = imread(filename);

if ~ismatrix(image_data_orig)
    image_data_2D = rgb2gray(image_data_orig);
end

% extract
tic
MSERregions = detectMSERFeatures(image_data_2D);
toc

% visualize
figure; imshow(image_data_2D); hold on; 
plot(MSERregions, 'showPixelList', true, 'showEllipses', false);
title(['MSER exact regions for ' num2str(image_filename)]);
hold off;

figure; imshow(image_data_2D); hold on;
plot(MSERregions); 
title(['MSER elliptical regions for ' num2str(image_filename)]);
hold off;