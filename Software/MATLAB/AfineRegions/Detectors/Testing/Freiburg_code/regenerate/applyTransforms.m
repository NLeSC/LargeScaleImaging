%applyTransforms- apply series of transformations to an image

transforms = {'zoom'};
num_transforms = 5;
transforms_path = '/home/elena/eStep/LargeScaleImaging/Data/FreiburgRegenerated/transformations/';
data_path = '/home/elena/eStep/LargeScaleImaging/Data/FreiburgRegenerated/01_graffiti/';
reference_file = '_original.ppm';

reference_image = imread(fullfile(data_path, reference_file));


for tr = transforms
    trans = char(tr)
    for i= 1:num_transforms
        i
        homography_file = fullfile(transforms_path, [trans num2str(i) 'M.mat']);
        load(homography_file);
        trans_image = applyGeoTransform( reference_image, H);
        trans_file_ppm = fullfile(data_path, [trans num2str(i) '.ppm']);
        trans_file_jpg = fullfile(data_path, [trans num2str(i) '.jpg']);
        imwrite(trans_image, trans_file_ppm);
        imwrite(trans_image, trans_file_jpg);
    end
    disp('--------------------------------------------------------------');
end