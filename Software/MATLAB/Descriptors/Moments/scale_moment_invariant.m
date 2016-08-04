% scale_moment_invariant.m- computing a scale moment invariant proposed by Flusser
%**************************************************************************
% [moment_invariant] = scale_moment_invatriant(u, v, pixel_list, centroid, area)
%
% author: Elena Ranguelova, NLeSc
% date created: 2 Aug 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% u,v               the order of the Flusser moment
% pixel_list        the list of pixel coordinates belonging to a 2D binary shape
% [centroid]        optional centroid of the 2D binary shape. If not given -
%                   average of the pixel_list coordinates
% [area]            optional the area of the 2D binary shape. If not given - the 
%                   number of all pixels
%**************************************************************************
% OUTPUTS:
% moment_invariant  the scale moment invariant of order (u,v)
%**************************************************************************
% EXAMPLES USAGE:
% see scale_moment_invariants.m
%**************************************************************************
% NOTES:
% See Testing scripts 
%**************************************************************************
% REFERENCES: 
% B. Z. J. Flusser, T. Suk, "Moment and Moment Invariants in Pattern 
% Recogntion", John Wiley and Sons, 2009.
% see also % http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/FISHER/MOMINV/
% and 
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.463.3980&rep=rep1&type=pdf
%**************************************************************************

function [moment_invariant] = scale_moment_invariant(u, v, pixel_list, ...
                                                        centroid, area)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
centroid_unknown = false;
area_unknown = false;
if nargin < 5
    area_unknown = true;
else if area <= 0
        error('The 2D shape area must be positive and non-zero');
    end
end
if nargin < 4
    centroid_unknown = true;
end
if nargin < 3
    error('scale_moment_invariant.m requires at least 3 input arguments!');
    moment_invariant = None;
    return
else
    order_values = [0 1 2 3];
    if not(ismember(u,order_values)) | not(ismember(v, order_values))
        error(['The moment orders could have only values: ' num2str(order_values)]);
    end
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
% determine the power factor for the area
area_power = 1;

power_str = sprintf('%d',[u v]);
switch power_str,
    case {'11','20'}
        area_power = 2;
    case {'12','21','30'}
        area_power = 2.5;
    otherwise
        error('Wrong combination of moment orders (u,v)!');
end
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
moment_invariant = 0;

%**************************************************************************
% computations
%--------------------------------------------------------------------------
complex_moment = flusser_moment(u,v,pixel_list, centroid);
moment_invariant = complex_moment/(area^area_power);