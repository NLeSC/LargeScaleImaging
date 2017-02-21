% test_SMIdescriptor- testing the SMI descriptor computation for 
%                   an image (Oxford dataset)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-02-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: see also test_IsSameScene_imagePair_Oxford and IsSameScene
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% execution parameters
verbose = true;
visualize = true;
area_filtering = true;  % if true, perform area filterring on regions
binarized = false;

% moments parameters
order = 4;
coeff_file = 'afinvs4_19.txt';
max_num_moments = 16;

% CC parameters
conn = 8;
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
area_factor = 0.0005;

% paths
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions\';
if binarized
    data_path_bin = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\';
    ext = '_bin.png';
else
    ext  ='.png';
end

%% load test data
test_case = input('Enter base test case [graffiti|leuven|boat|bikes]: ','s');
trans_deg = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');

if verbose
   disp('Loading the image...');
   if binarized
       disp('Already binarized image is used.');
   end
end

if binarized
    test_path = fullfile(data_path_bin,test_case);
else
    test_path = fullfile(data_path_or,test_case);
end

test_image = fullfile(test_path,[test_case num2str(trans_deg) ext]); 

im = imread(test_image);

if visualize
    if verbose
        disp('Displaying the test image');
    end;
    fig_scrnsz = get(0, 'Screensize');
    figure; set(gcf, 'Position', fig_scrnsz);
    imshow(im); title(['First image: ' test_case num2str(trans_deg)]);        
end


%% processing
%**************** Processing *******************************
disp('Processing...');
t0 = clock;

%% binarization
if not( islogical(im))
    % find out the dimensionality
    if ndims(im) == 3
        im = rgb2gray(im);
    end
    tic
    
    if ismatrix(im)
        if verbose
            disp('Data-driven binarization ...');
        end
        [bw,~] = data_driven_binarizer(im);
    end
    if verbose
        toc
    end
else
    bw = logical(im); 
end

% visualization of the binarization result
if visualize
    f = figure; set(gcf, 'Position', fig_scrnsz);
    show_binary(bw, f, (111),'Binarized image');
end