% mser_detector_many.m- script for applying MSER detector on many images
%**************************************************************************
%
% author: Elena Ranguelova, TNO
% date created: 11 Mar 08
% last modification date: 13 Mar 08
% modification details: added possibility to process only part of the
%                       images in given directory
%**************************************************************************
% NOTES: for now produces only regions in ellipse output format
%        input directory is assumed to contain ONLY input images
%**************************************************************************
% EXAMPLES USAGE:
% simply type
%
% mser_detector_many
%
% and follow questions.
%........................................................................
% example: 
%
% mser_detector_many
% Enter the full path to the input image directory: V:\WIR\Video_processing\projects\saliency\data\traffic_signs\
% Enter the full path to the output features directory: V:\WIR\Video_processing\projects\saliency\results\traffic_signs\MSER\
% 
%**************************************************************************
clc; 
disp('------------------------------------------------------------------');
disp('    Maximally Stable Extremal Regions (MSER) Detection            ');
disp('------------------------------------------------------------------');
disp('                                                                  ');

% input image directory
input_dir = input('Enter the full path to the input image directory: ','s');

fnames_struct = dir([input_dir '*.png']);

if isempty(fnames_struct)
    fnames_struct = dir([input_dir '*.pgm']);    
end
if isempty(fnames_struct)
    fnames_struct = dir([input_dir '*.ppm']);    
end
if isempty(fnames_struct)
    disp('The input directory must contain images in one of these formats: PNG/PPM/PGM!');    
    return;
else
    num_images = length(fnames_struct);
end

for i = 1:num_images
    fnames{i} = fnames_struct(i).name; 
end

% all images?
all = input(['Process all ' num2str(num_images) ' input images [y/n]? '],'s');
if strcmpi(all,'n')
    ind = input('Specify part (P) of images with beginning and end indicies or list (L) [P/L]?: ','s');
    if strcmpi(ind,'p')
        ind_beg = input('Enter the beginning image number: ');  
        ind_end = input('Enter the ending image number: ');
        indicies = ind_beg:ind_end;
    else
        indicies = input('Enter the list of image indicies: ');
    end
else
    indicies = 1:num_images;
end

% output (feature) directory
features_dir = input('Enter the full path to the output features directory: ','s');

% run for the selected images
for i = indicies
    base_fname = fnames{i};
    image_fname = ['"' input_dir base_fname '"'];
    k = find(base_fname =='.');
    l = k(end);
    if isempty(l)
        features_fname = ['"' features_dir base_fname '.mser' '"'];
    else
        features_fname = ['"' features_dir base_fname(1:l-1) '.mser' '"'];
    end
   

    disp([' Processing image index # ' num2str(i) ' out of total ' num2str(length(indicies)) ' images...']);
   % disp([' Processing image: ' image_fname ]);
    
    % Saliency detector
    tic
    mser(image_fname, features_fname);
    toc
    disp('------------------------------------------------------------------');
    
end
    disp('--------------- The End ---------------------------------');


