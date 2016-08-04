% scale_moment_invariants - computing the 5 scale moment invariants by Flusser
%**************************************************************************
% [moment_invariants] = scale_moment_invatriants(pixel_list, centroid, area)
%
% author: Elena Ranguelova, NLeSc
% date created: 4 Aug 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% pixel_list        the list of pixel coordinates belonging to a 2D binary shape
% [centroid]        optional centroid of the 2D binary shape. If not given -
%                   average of the pixel_list coordinates
% [area]            optional the area of the 2D binary shape. If not given - the 
%                   number of all pixels
%**************************************************************************
% OUTPUTS:
% moment_invariants the 5scale moment invariants defined for orders
%                   (1,1), (1,2), (2,0), (2,1)  and (3,0)
%**************************************************************************
% EXAMPLES USAGE:
% see test_scale_moment_invariants.m
%**************************************************************************
% NOTES:
% See also scale_moment_invariant
%**************************************************************************
% REFERENCES: 
% B. Z. J. Flusser, T. Suk, "Moment and Moment Invariants in Pattern 
% Recogntion", John Wiley and Sons, 2009.
% see also % http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/FISHER/MOMINV/
% and 
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.463.3980&rep=rep1&type=pdf
%**************************************************************************

function [moment_invariants] = scale_moment_invariants(pixel_list, ...
                                                        centroid, area)
                                                    
%**************************************************************************
% input control    
%--------------------------------------------------------------------------
centroid_unknown = false;
area_unknown = false;
if nargin < 3
    area_unknown = true;
else if area <= 0
        error('The 2D shape area must be positive and non-zero');
    end
end
if nargin < 2
    centroid_unknown = true;
end
if nargin < 1
    error('scale_moment_invariants.m requires at least 1 input argument!');
    moment_invariants = [];
    return
end             

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% calculate the centroid if it's not known
if centroid_unknown
    centroid = mean(pixel_list);
end
% calculate the area if it's not known
if area_unknown
    area = length(pixel_list);
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
moment_invariants = zeros(1,5);

% the moment orders
u = [1 1 2 2 3];
v = [1 2 0 1 0];

%**************************************************************************
% computations
%--------------------------------------------------------------------------
for i = 1:5
    moment_invariants(i) = scale_moment_invariant(u(i), v(i), pixel_list, ...
                                                        centroid, area);
end