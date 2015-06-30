% mser- main function of the MSER detector called from Matlab
%**************************************************************************
% mser(image_fname, features_fname, ellipse_scale, output_file_type, verbose)
%
% author: Elena Ranguelova, TNO
% date created: 6 Mar 2008
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% image_fname- the input image filename 
% [features_fname] - the (output) feature filename [optional], if left out
%                   or empty same as the image_fname with extension .mser
% [ellipse_scale]- the scale of the ellipses [optional]
%                   if left out or empty [], default is 1
% [output_file_type]- 0- RLE, 1- Extended boundary, 2- ellipse, 3-GF, 4- aff.
%                     (see README.txt and mser -h)
%                    [optional], if left out- default is 2
% [verbose]-        [optional], default is 0
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% EXAMPLES USAGE: 
% mser('..\..\data\other\graffiti1.jpg');
% finds MSER saleint regions for the image
%--------------------------------------------------------------------------
%**************************************************************************
% RERERENCES:http://www.robots.ox.ac.uk/~vgg/research/affine/detectors.html
%**************************************************************************
function  mser(image_fname, features_fname, ellipse_scale, ...
               output_file_type, verbose)
                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 5
    verbose = 0;
end
if nargin < 4 || isempty(output_file_type)
    output_file_type = 2;
end
if nargin < 3 || isempty(ellipse_scale)
    ellipse_scale = 1;
end
if nargin < 2 || isempty(features_fname)
    i = find(image_fname =='.');
    j = i(end);
    if isempty(j)
        features_fname = ['"' image_fname '.mser' '"']    
    else
        features_fname = ['"' image_fname(1:j-1) '.mser' '"']
    end
end
if nargin < 1
    error('mser.m requires at least 1 input argument- the image filename!');
end

%**************************************************************************
% constants/ hard-set parameters
%--------------------------------------------------------------------------

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
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
%..........................................................................
% compute MSER regions
%..........................................................................
t0 = clock;

% invoke the Windows executable
command = ['mser -t ' num2str(output_file_type) ' -es  '...
            num2str(ellipse_scale) ' -i ' image_fname ' -o ' features_fname];
system(command);
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
if verbose
       disp(['Total elapsed time:  ' num2str(etime(clock,t0))]);
end

