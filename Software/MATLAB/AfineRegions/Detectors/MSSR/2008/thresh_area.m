% thresh_area- thresholding based on the data's effective "area"
%**************************************************************************
% [thresh_data] = thresh_cumsum(data, thresh,verbose)
%
% author: Elena Ranguelova, TNO
% date created: 25 Feb 2008
% last modification date: 26 Feb 2008
% modification details: added threshold parameter
%**************************************************************************
% INPUTS:
% data- the 2-D data matrix to be thresholded (values >=0)
% [thresh]- - threshold, [optional], if left out default is 0.75
% [verbose] - verbose flag, [optional], if left out default is 0
%**************************************************************************
% OUTPUTS:
% thresh_data- the thresholded data
%**************************************************************************
% NOTES: when the area ratio is high and no thresh is given, it's 
%        equivalent to thresh_cumsum
%**************************************************************************
% EXAMPLES USAGE:
%    sz = 51; test =zeros(sz);  val = 1;
%    for i = 1:26
%        for off1 = val+1:sz -val+2
%            for off2 = val+1: sz-val+2
%               test(off1,off2) = val;
%            end
%        end
%        val = val + 1;
%    end
%    imagesc(test); grid on, colorbar
%    [thresh_test] = thresh_area(test,[],1);
%    figure;imagesc(thresh_test);grid on, colorbar
%--------------------------------------------------------------------------
%    sz = 51; test =zeros(sz);  val = 1;
%    for i = 1:26
%        for off = val+1:sz -val+2
%           test(off,off) = val;
%        end
%        val = val + 1;
%    end
%    imagesc(test); grid on, colorbar
%    [thresh_test] = thresh_area(test,[],1);
%    figure;imagesc(thresh_test);grid on, colorbar
%--------------------------------------------------------------------------
%     protrusions_thresh = thresh_area(protrusions_acc, thresh, verbose);
% as called from mssr.m;
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [thresh_data] = thresh_area(data, thresh, verbose)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3
    verbose = 0;
elseif (nargin<2)||(isempty(thresh))
    thresh = 0.75;
elseif nargin < 1
    error('thresh_data.m requires at least 1 input arument!');
    thresh_data = [];
    return
end

%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
% area ratio thresholding parameter (2%)
ar_tr = 0.02;

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
[nrows,ncols] = size(data);

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% total area 
A = nrows * ncols;

% "effective" area
% non-zero data
data_nz=data(data>0);
A1 = bwarea(data_nz);

% area ratio
AR = A1/A;

if verbose 
    disp(['Area ratio: ' num2str(AR)]);
end    
% thresholding

if AR < ar_tr
    thresh_data = data >0;
    if verbose
        disp('No thresholding!');
    end
    thresh_data = reshape(thresh_data,nrows,ncols);
else
    if verbose 
        disp(['Threshold: ' num2str(thresh)]);
    end
    thresh_data = thresh_cumsum(data,thresh,verbose);
end

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------



