% rotation_moment_invariants - computing the 6 rotation moment invariants by Flusser
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
% moment_invariants the 6 rotation moment invariants 
%**************************************************************************
% EXAMPLES USAGE:
% see test_rotation_moment_invariants.m
%**************************************************************************
% NOTES:
% See also scale_moment_invariants.m
%**************************************************************************
% REFERENCES: 
% B. Z. J. Flusser, T. Suk, "Moment and Moment Invariants in Pattern 
% Recognition", John Wiley and Sons, 2009.
% Jan Flusser, "On the independence of rotation moment invariants": 
% http://library.utia.cas.cz/prace/20000033.pdf
% see also % http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/FISHER/MOMINV/
% and 
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.463.3980&rep=rep1&type=pdf
%**************************************************************************

function [moment_invariants] = rotation_moment_invariants(pixel_list, ...
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
moment_invariants = zeros(1,6);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% compute the 5 scaleinvariants
sc_mom_inv = scale_moment_invariants(pixel_list, centroid, area);
% get the specific moments out of the vector of moments
s11 = sc_mom_inv(1);
s12 = sc_mom_inv(2);
s20 = sc_mom_inv(3);
s21 = sc_mom_inv(4);
s30 = sc_mom_inv(5);

% compute intermediate terms
s12_sq = s12*s12;
s12_cub = s12_sq*s12;
s20_s12_sq = s20*s12_sq;
s30_s12_cub = s30*s12_cub;

% compute the rotation invariants
moment_invariants(1) = real(s11);
moment_invariants(2)= 1000 * real(s21*s12);
moment_invariants(3) = 10000 * real(s20_s12_sq);
moment_invariants(4) = 10000 * imag(s20_s12_sq);
moment_invariants(5) = 100000 * real(s30_s12_cub);
moment_invariants(6) = 100000 * imag(s30_s12_cub);

% moment_invariants(1) = s11;
% moment_invariants(2)= s21*s12;
% moment_invariants(3) = real(s20_s12_sq);
% moment_invariants(4) = imag(s20_s12_sq);
% moment_invariants(5) = real(s30_s12_cub);
% moment_invariants(6) = imag(s30_s12_cub);



