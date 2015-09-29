% test_mser_LMwood- testing build-in MSER detector on LMwood data
%**************************************************************************
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2015
% last modification date: 
% modification details: 

%% paths and filenames
data_path = '/home/elena/eStep/LargeScaleImaging/Data/Scientific/WoodAnatomy/LM pictures wood/PNG';
results_path ='/home/elena/eStep/LargeScaleImaging/Results/Scientific/WoodAnatomy/LM pictures wood';

%test_case = input('Enter test case: [anodendron|argania|carini|crater|dregia|gymnema|napol|ocinotis|periploca]: ','s');
test_case = 'anodendron';
switch lower(test_case)
    case 'anodendron'
        image_filename = 'Anodendron rubescens01.png';
    case 'argania'
        image_filename = 'Argania spinosa1.png';
    case 'carini'
        image_filename = 'Carini decr01.png';
    case 'crater'
        image_filename = 'Crater letest8603_01.png';
    case 'dregia'
        image_filename = 'Dregia volubilis04.png';
    case 'gymnema'
        image_filename = 'Gymnema tingens04.png';
    case 'napol'
        image_filename = 'Napol vog 41120_01.png';
    case 'ocinotis'
        image_filename = 'Ocinotis gracilis02.png';
    case 'periploca'
        image_filename = 'Periploca laevigata02.png';
end  

data_filename = fullfile(data_path, image_filename);
result_filename = fullfile(results_path, [test_case '.mat']);

%% load
image_data_orig = imread(data_filename);

if ~ismatrix(image_data_orig)
    image_data_2D = rgb2gray(image_data_orig);
end

%% extract
tic
MSERregions = detectMSERFeatures(image_data_2D);
toc

%% save
save(result_filename,'MSERregions');

%% visualize
figure; imshow(image_data_2D); hold on; 
plot(MSERregions, 'showPixelList', true, 'showEllipses', false);
title(['MSER exact regions for ' num2str(image_filename)]);
hold off;

figure; imshow(image_data_2D); hold on;
plot(MSERregions); 
title(['MSER elliptical regions for ' num2str(image_filename)]);
hold off;