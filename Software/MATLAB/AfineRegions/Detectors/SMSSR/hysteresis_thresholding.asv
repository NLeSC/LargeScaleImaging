% hysteresis_thresholding- function for hysteresis thresholding
%**************************************************************************
% [binary_image] = hysteresis_thresholding(image_data,ROI_mask, ...
%                                               thresholds, execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 23 June 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% image_data        the input gray-level image data
% [ROI_mask]        the Region Of Interenst binary mask [optional]
%                   if specified should contain the binary array ROI
%                   if left out or empty [], the whole image is considered
% [thresholds]      high and low thrsholds [hightr lowtr]
%                   [optional]. if not specified highttr = 240, lowtr = 10
% [execution_flags] vector with 3 flags [verbose, visualise_major, ...
%                                                       visualise_minor]
%                   [optional], if left out- default is [0 0 0]
%                   visualise_major "overrides" visualise_minor
%**************************************************************************
% OUTPUTS:
% binary_image      the thresholded image
%**************************************************************************
% SEE ALSO
% smssr- the SMSSR detector 
%**************************************************************************
% EXAMPLES USAGE: 
% cl;
% if ispc 
%     starting_path = fullfile('C:','Projects');
% else
%     starting_path = fullfile(filesep,'home','elena');
% end
% image_filename = fullfile(starting_path,'eStep','LargeScaleImaging',...
%            'Data','AffineRegions','Phantom','phantom.png');
% image_data =imread(image_filename);
% [binary_image] = hysteresis_thresholding(image_data, [], [150 120], [1 1 1]);
%--------------------------------------------------------------------------
% see also test_smssr.m
%**************************************************************************
% RERERENCES:
function [binary_image] = hysteresis_thresholding(image_data,ROI_mask, ...
                                               thresholds, execution_flags)
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 4 || length(execution_flags) < 3
    execution_flags = [0 0 0];
end
if nargin < 3 || isempty(thresholds) || length(thresholds) < 2
    thresholds = [240 10];
end
if nargin < 2
    ROI_mask = [];
end
if nargin < 1
    error('hysteresis_thrsholding.m requires at least 1 input argument- the gray_level image!');
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% thresholds
hightr = thresholds(1);
lowtr = thresholds(2);

% execution flags
verbose = execution_flags(1);
visualise_major = execution_flags(2);
visualise_minor = execution_flags(3);    

if visualise_minor
    visualise_major = 1;  
end
%**************************************************************************
% parameters
%--------------------------------------------------------------------------
% image dimensions
[nrows, ncols] = size(image_data);

% set up figure 
if visualise_major || visualise_minor
    f =figure;
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
binary_image = zeros(nrows, ncols);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
% if image is colour make is gray-scale
if ndims(image_data)>2
    image_data = rgb2gray(image_data);
end
% apply the ROI mask if given and get the range of gray levels
if ~isempty(ROI_mask)
    ROI_only = image_data.*uint8(ROI_mask);
else
    ROI_only = image_data;
end

    
if verbose
    disp('Thresholding...');
end

tic;
t0 = clock;

highmask = ROI_only>hightr;
lowmask = bwlabel(~(ROI_only<lowtr));
binary_image = ismember(lowmask,unique(lowmask(highmask)));

%**************************************************************************
% visualization
%--------------------------------------------------------------------------
if visualise_major
    figure(f); subplot(221);imshow(ROI_only); 
    axis on; grid on; title('Input image (ROI)');
    subplot(224);imshow(binary_image); axis on; grid on; 
    title(['Hysteresis thresholded ROI at thresholds: ' num2str(lowtr) ' and ' num2str(hightr)]);    
    if visualise_minor
        figure(f);subplot(222);imshow(highmask); axis on; grid on; 
        title(['Thresholded ROI at high threshold: ' num2str(hightr)]); 
        subplot(223);imshow(lowmask); axis on; grid on; 
        title(['Thresholded ROI at low threshold: ' num2str(lowtr)]); 
    end
end

if verbose
       disp(['Total elapsed time:  ' num2str(etime(clock,t0))]);
end