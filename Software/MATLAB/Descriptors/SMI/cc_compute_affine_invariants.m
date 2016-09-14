% cc_compute_affine_invariants.m- computing affine invariants from CCs
%**************************************************************************
% [affine_regions_props] = cc_compute_affine_invariants(conn_comps, ...
%                                                    order, coeff, num_moments)
%
% author: Elena Ranguelova, NLeSc
% date created: 13 Sep 2016
% last modification date:
% modification details:
%**************************************************************************
% INPUTS:
% conn_comps      the connected components derived from a binary image
% order           the moments order
% coeff           invariants coefficients (read from the TXT file provided
%                 with code)
% num_moments     the number of moment invariants, default value is 6
%**************************************************************************
% OUTPUTS:
% affine_region_props     structure with the affine invariants for each CC
%**************************************************************************
% EXAMPLES USAGE:
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% conn = 4;
% imshow(bw); title('Image with Circles'); axis on, grid on;
% conn_comps = bwconncomp(bw, conn);
% order = 4; coeff_file = 'afinvs4_19.txt';
% coeff = readinv(coeff_file);
% [affine_regions_props] = cc_compute_affine_invariants(conn_comps, order, coeff)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [affine_regions_props] = cc_compute_affine_invariants(conn_comps,...
                                                 order, coeff, num_moments)

%**************************************************************************
% input control
%--------------------------------------------------------------------------
if nargin < 4
    num_moments = 6;
elseif nargin < 3
    error('cc_compute_affine_invariants.m requires at least 3 input arguments!');
    affine_regions_props = None;
    return
end
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
im_size = conn_comps{1}.ImageSize;
%nrows= im_size(1); ncols = im_size(2);
num_regions = conn_comps{1}.NumObjects;

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
%affine_regions_props =  struct([]);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
for i = 1:num_regions
    bw = zeros(im_size);
    bw(conn_comps{1}.PixelIdxList{i}) = 1;
    aff_inv = affine_invariants(bw, order, coeff);
    affine_regions_props(i,:) = aff_inv(1:num_moments);
end

end