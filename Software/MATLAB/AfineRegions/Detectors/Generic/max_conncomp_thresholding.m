% max_conncomp_thresholding.m- connected component(CC)-based thresholding
%**************************************************************************
% [binary_image, otsu, thresh] = max_conncomp_thresholding(gray_image, 
%                               num_levels, offset, 
%                               morpholigy_parameters, weights,  
%                               execution_flags)
%
% author: Elena Ranguelova, NLeSc
% date created: 07.10.2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% gray_image        matrix containing the gray-scale image
% [num_levels]      number of gray levels to be considered [1..255],
%                   default 255, i.e. all, step 1
% [offset]          the offset (number of levels) from Otsu to be processed
%                   default value- 80
% [morphology_parameters] vector with 5 values corresponding to
%                   SE_size_factor- size factor for the structuring element
%                   Area_factor_very_large- factor for the area of CC to be
%                   considered 'very large'
%                   Area_factor_large- factor for the area of CC to be
%                   considered 'large'
%                   lambda_factor- factor for the parameter lambda for the
%                   morphological opening (noise reduction)
%                   connectivity - for the morhpological opening
%                   default values [0.02 0.1 0.001 3 8]
% [weights]         vector with 3 weights for the linear combination for
%                   weight_all- the weight for the total number of CC
%                   weight_large- the weight for the number large CC
%                   weight_very_large- for the number of very large CC
%                   default value - [0.33 0.33 0.33], i.e equal
% [execution_flags] vector of 2 elements, controlling the execution
%                   verbose- verbose mode
%                   visualize- vizualize 
%                   default value- [0 0]
%**************************************************************************
% OUTPUTS:
% binary_image      the binarized gray level image
% otsu              the Otsuthreshold (gray level)
% thresh            the threshold used for binarization- the max of
%                   the weighted combination among the 3 number of CCs
%**************************************************************************
% EXAMPLES USAGE:
% 
%**************************************************************************
% REFERENCES: 
%**************************************************************************
function [binary_image, otsu, thresh] = max_conncomp_thresholding(gray_image, ...
                               num_levels, offset, ...
                               morpholigy_parameters, weights, ... 
                               execution_flags)
                           
 %**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 6 || length(execution_flags) < 2
    execution_flags = [0 0];
elseif nargin < 5 || length(weights) < 3
    weights = [0.33 0.33 0.33];
elseif nargin < 4 || length(morphology_parameters) < 5
    morphology_parameters = [0.02 0.1 0.001 3 8]; 
elseif nargin < 3
    offset = 80;
elseif nargin < 2
    num_levels = 255;
elseif nargin < 1
    error('max_conncomp_thresholding.m requires at least 1 input argument!');
end            

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% execution flags
verbose = execution_flags(1);
visualize = execution_flags(2);

% weights
weight_all = weights(1);
weight_large = weights(2);
weight_very_large = weight(3);

% morphology parameters
SE_size_factor = morphology_parameters(1);
Area_factor_very_large  = morphology_parameters(2);
Area_factor_large = morphology_parameters(3);
lambda_factor = morphology_parameters(4);
connectivity = morphology_parameters(5);

% gray levels
min_level =  1; max_level = 255;
step = (max_level - min_level)/num_levels;
if step == 0
    step = 1;
end

% image dimensions
[nrows, ncols] = size(gray_image);

% image area
Area = nrows*ncols;


% area opening parameter
lambda = ;