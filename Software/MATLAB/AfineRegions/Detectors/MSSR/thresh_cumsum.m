% thresh_cumsum- thresholding based on cumulative sum
%**************************************************************************
% [thresh_data] = thresh_cumsum(data, factor, verbose)
%
% author: Elena Ranguelova, TNO
% date created: 25 Feb 2008
% last modification date: 12 Mar 2008
% modification details: care taken in the case when the data span/cs are zero
%**************************************************************************
% INPUTS:
% data- the 2-D data matrix to be thresholded (with values >=0)
% factor- the thresholding ((0 1]) 
% [verbose] - verbose flag, [optional], if left out default is 0
%**************************************************************************
% OUTPUTS:
% thresh_data- the thresholded data
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
%    factor = 0.75;
%    [thresh_test] = thresh_cumsum(test, factor, 1);
%    figure;imagesc(thresh_test);grid on, colorbar
%
%    factor = 0.99;
%    [thresh_test] = thresh_cumsum(test, factor, 1);
%    figure;imagesc(thresh_test);grid on, colorbar
%--------------------------------------------------------------------------
%     holes_thresh = thresh_cumsum(holes_acc, 0.75);
% as called from mssr.m; keeps the data which make the top 100-75% of the
% cumulative data sum
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [thresh_data] = thresh_cumsum(data, factor, verbose)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3
    verbose = 0;
elseif nargin < 2
    error('thresh_data.m requires at least 2 input aruments!');
    thresh_data = [];
    return
end

%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
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
data = data(:);

% non-zero data
non_zero=find(data);
data_nz=data(non_zero);

% data span
mmax = max(data_nz);
mmin = min(data_nz);
span = mmax-mmin;

if verbose 
    disp(['Data span: ' num2str(span)]);
end

if span == 0
    thresh_data = data>=0;
    thresh_data = reshape(thresh_data,nrows,ncols);
end
%--------------------------------------------------------------------------
% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
% histogram
h = hist(data_nz,span);
%figure,hist(data_nz,span);
if verbose 
    disp(['The histogram: ' num2str(h)]);
end
%cumulative sum
cs = cumsum(h);

%figure,bar(cs,span);
if verbose 
    disp(['Cumulative sum: ' num2str(cs)]);
end

% thresholding
if isempty(cs)
    tr = 0;
else
    t = fix(cs(length(cs))*factor);
    tr = min(find(cs>=t)); %#ok<MXFND>
end
if verbose 
    disp(['Location to cut the sum: ' num2str(t)]);
end

if verbose 
    disp(['Threshold: ' num2str(tr)]);
end

thresh_data = data>=tr;

%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
thresh_data = reshape(thresh_data,nrows,ncols);


