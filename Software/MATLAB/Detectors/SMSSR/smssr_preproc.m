% smssr_preproc.m- pre-processing for the SMMSR detector
%**************************************************************************
% [out_image] = smssr_preproc(in_image, preproc_types, SE_size_factor, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 May 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% in_image - input gray-level image
% [preproc_type]- array with 2 flags for the 2 proprocessing types 
%                [Smoothing, HistogramEquilization]
%                [optional], if left out- default is [1 1]
% [SE_size_factor]- structuring element (SE) size factor for smoothing
%                  [optional], if left out is 0.02
  
% [visualise] - visualisation flag
%                     [optional], if left out- default is 0
%**************************************************************************
% OUTPUTS:
% out_image - the output gray-level image after pre-rpocessing
%**************************************************************************
% EXAMPLES USAGE:
% [out_image] = smssr_preproc(in_image,  preproc_types, SE_size_factor,visualise)
%
% as called from test_smssr.m
%--------------------------------------------------------------------------
% [out_image] = smssr_preproc(in_image, [1 0],0.02, 1)
%
% Performes only histogram equilization, no smoothing with visualisation
%**************************************************************************
% REFERENCES: see test_smssr.m 
%**************************************************************************
function [out_image] = smssr_preproc(in_image,preproc_types, ...
                                     SE_size_factor,  visualise)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin <1
    error('smssr_preproc.m requires at least 1 input aruments!');
    out_image = [];
    return;
end
if nargin <2    
    preproc_types = [1 1]; 
end
if nargin < 3
    SE_size_factor = 0.02; 
end
if nargin < 4
    visualise = 0;
end

%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
[nrows,ncols] = size(in_image);
if ~isempty(preproc_types)
    smooth = preproc_types(1);
    hist_eq = preproc_types(2);
end


Area = nrows*ncols;

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
out_image = in_image;

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
if smooth
    % SE
    SE_size = fix(sqrt(SE_size_factor*Area/(2 * pi)));
    SE = strel('disk',SE_size);
    out_image = imclose(out_image, SE);
end
if hist_eq
    out_image= histeq(out_image);   
end
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------

% TO DO: visualizations