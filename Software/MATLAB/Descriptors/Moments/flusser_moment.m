% flusser_moment.m- computing complex central moment proposed by Flusser
%**************************************************************************
% [complex_moment] = flusser_moment(u, v, pixel_list,centroid)
%
% author: Elena Ranguelova, NLeSc
% date created: 1 Aug 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% u,v              the order of the Flusser moment
% pixel_list       the list of pixel coordinates belonging to a 2D binary shape
% [centroid]       optional centroid of the 2D binary shape. If not given -
%                  average of the pixel_list coordinates
%**************************************************************************
% OUTPUTS:
% complex_moment   the complex central Flusser moment of order (u,v)
%**************************************************************************
% EXAMPLES USAGE:
% see Testing scripts and scale_moment_invariant
%**************************************************************************
% NOTES:
% See compute_region_props.m for exampleof obtaining the centroid, area and
% pixel_list 
%**************************************************************************
% REFERENCES: 
% B. Z. J. Flusser, T. Suk, "Moment and Moment Invariants in Pattern 
% Recogntion", John Wiley and Sons, 2009.
% see also % http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/FISHER/MOMINV/
% and 
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.463.3980&rep=rep1&type=pdf
%**************************************************************************

function [complex_moment] = flusser_moment(u, v, pixel_list, centroid)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
centroid_unknown = false;
if nargin < 4
    centroid_unknown = true;
end
if nargin < 3
    error('flusser_moment.m requires at least 3 input arguments!');
    complex_moment = None;
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% calculate the centroid if it's not known
if centroid_unknown
    centroid = mean(pixel_list);
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
complex_moment = 0;
num_pixels = length(pixel_list);
norm_pixel_list =  zeros(num_pixels,2);
complex_numbers = zeros(num_pixels,1);
complex_conjugate_numbers = zeros(num_pixels,1);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
for n = 1:num_pixels
    % normalised (centered) pixel list
    norm_pixel_list(n,:) = pixel_list(n,:) - centroid;
    % make the list of complex numbers
    complex_numbers(n) = pixel_list(n,1) + i*pixel_list(n,2);
    % make the complex comjugate
    complex_conjugate_numbers(n) = conj(complex_numbers(n));    
end

% multiply powered complex and complex conjugate
sum_argument = complex_numbers.^u .* complex_conjugate_numbers.^v;

% final summation
complex_moment = sum(sum_argument);



