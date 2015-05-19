% transform_test_image.m- script to affinely transformation a test image
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 15-05-2015
% last modification date: 19-05-2015
% modification details: made OS independant; added gray-level test image
%**************************************************************************

%% paramaters
interactive = false;
visualize = false;

%% input image filename
if ispc 
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
if interactive 
    image_filename = input('Enter the test image filename: ','s');
else
    test_image = input('Enter test case: [binary_test|basic_saliency|phantom]: ','s');
    switch lower(test_image)
        case 'binary_test'
            image_filename = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','TestBinarySaliency.png');

        case 'basic_saliency'
            image_filename = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','Synthetic','Binary','BasicSaliency.png');

        case 'phantom'
            image_filename = fullfile(starting_path,'eStep','LargeScaleImaging',...
            'Data','AffineRegions','Phantom','phantom.png');
        
    end
end

%% output image filename
[pathstr,name,ext] = fileparts(image_filename);
out_name = strcat(name, '_affine', ext);
out_image_filename = fullfile(pathstr,out_name);

%% apply affine transformation
tform_matrix = [.5 0.2 0; 0.25 0.75 0; 20 30 1];
% tform = affine2d(tform_matrix); -- newer MATLAB version
tform = maketform('affine', tform_matrix);
switch lower(test_image)
        case {'binary_test','basic_saliency'}
            I = logical(imread(image_filename));
        case 'phantom'
            I = imread(image_filename);        
end
J =  imtransform(I,tform);
% J = imwarp(I,tform); -- newer MATLAB version
imshow(I), figure, imshow(J);

%% save transformed image
imwrite(J,out_image_filename);
