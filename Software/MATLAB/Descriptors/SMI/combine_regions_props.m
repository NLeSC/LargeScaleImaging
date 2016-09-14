% combine_regions_props.m- combining region properties and affine invariants
%**************************************************************************
% [combined_props] = combine_regions_props(derived_props, affine_props)
%
% author: Elena Ranguelova, NLeSc
% date created: 13 Sept 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% derived_props         structure with all derived region properties as
%                       given by bw_compute_region_props
% affine_props          array with affine region properties as given 
%                       by cc_compute_affine_invariants
%**************************************************************************
% OUTPUTS:
% combined_props        structure with all combined regions properties 
%                       The affine invariants are under key 'AffineInvariants'
%**************************************************************************
% NOTE:
%**************************************************************************
% EXAMPLES USAGE:
% %% clear up
% cl;
% %% load data, params
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% conn = 4;
% %imshow(bw); title('Image with Circles'); axis on, grid on;
% list = {'Centroid', 'Area','MinorAxisLength','MajorAxisLength','Solidity'};
% order = 4; coeff_file = 'afinvs4_19.txt';
% coeff = readinv(coeff_file);
% %% region properities
% [regions_props, conn_comps] = compute_region_props(bw, conn, list);
% area = size(a,1) * size(a,2);
% [derived_props] = compute_derived_props(regions_props, area)
% %% affine invariants
% [affine_props] = cc_compute_affine_invariants(conn_comps, order, coeff)
% %% combine
% [combined_props] = combine_regions_props(derived_props, affine_props)
%**************************************************************************
% REFERENCES: 
%**************************************************************************

function [combined_props] = combine_regions_props(derived_props, affine_props)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
% compulsory statistics types   
if nargin < 2
    error('combine_regions_props.m requires at least 2 input arguments!');
    combined_props = [];
    return
else
    % check dimensions
    num_derived_props = length(derived_props);
    num_affine_props = size(affine_props, 1);    
    if (num_derived_props - num_affine_props) ~= 0
        error('combine_regions_props: the properties to be combined must be of the same cardinality!');
    end
             
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% derived field names
list_derived_types = fieldnames(derived_props);
list_all = union(list_derived_types, 'AffineInvariants');

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
combined_props =  struct([]);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% compute the derived properies
for n = 1: num_derived_props
    for ts = 1:length(list_all)
        type_stat = char(list_all{ts});
        switch type_stat
            case {'AffineInvariants'}
                aff_inv = affine_props(n,:);
                combined_props(n).(type_stat) = aff_inv;
            otherwise
                prop = derived_props(n).(type_stat);
                combined_props(n).(type_stat) = prop;
        end
    end
end
