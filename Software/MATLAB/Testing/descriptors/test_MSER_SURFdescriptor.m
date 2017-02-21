% test_MSER_SURFdescriptor- testing the SURF descriptor computation for 
%                   MSER regions detected in an image (Oxford dataset)
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-02-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: see also test_SMIdescriptor
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters
% execution parameters
verbose = true;
visualize = true;

% paths
data_path_or = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions\';
ext  ='.png';

%% load test data
% test_case = input('Enter base test case [graffiti|leuven|boat|bikes]: ','s');
% trans_deg = input('Enter the transformation degree [1(no transformation)|2|3|4|5|6]: ');

test_case = 'leuven'; trans_deg = 1;

if verbose
   disp('Loading the image...');
end

test_path = fullfile(data_path_or,test_case);
test_image = fullfile(test_path,[test_case num2str(trans_deg) ext]); 

im = imread(test_image);

if visualize
    if verbose
        disp('Displaying the test image');
    end;
    fig_scrnsz = get(0, 'Screensize');
    figure; set(gcf, 'Position', fig_scrnsz);
    imshow(im); title(['Image: ' test_case num2str(trans_deg)]);        
end



%%
%**************** Processing *******************************
disp('Processing...');
t0 = clock;
%% detect MSER regions
if ndims(im) == 3
    im = rgb2gray(im);
end
[regions,cc] = detectMSERFeatures(im);
% visualization of the CCs
if visualize
    f = figure; set(gcf, 'Position', fig_scrnsz);
    [labeled,~] = show_cc(cc, false, [], f, subplot(221),'Connected components');
end

