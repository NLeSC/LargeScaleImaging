% bwSMIdescriptor- Shape and Moment Invariants descriptor for a binary image
%**************************************************************************
% [SMIarray, SMIstruct] = bwSMIdescriptor(bw, conn, list_props, ...
%                                       order, coeff_file, num_moments)
%
% author: Elena Ranguelova, NLeSc
% date created: 14 Sept 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw               binary image for whose regions we want to compute SMI
% [conn]           neighbourhood connectivity to obtain the regions (CC)
%                  from bw. Optional, default 4       
% [list_props]     list of shape properties to be computed. Optional. 
%                  Can be all or subset of the default list:
%                  {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
%                  'Eccentricity','EulerNumber','Solidity'}
%                  Compulsory subset are the first 4 of the above list.
% [order]          the moments order. Optional, default is 4.
% [coeff_file]     the moment coefficients file. Optional, default is 'afinvs4_19.txt'
% [num_moments]    number of affine moment invariants. Optional, default 6
%**************************************************************************
% OUTPUTS:
% SMIarray         2D array with SMI descriptos for each CC in bw
% SMIstruct        structure with field names and values of all properties
%**************************************************************************
% NOTE:            The final list in the SMI output structure consists of 
%                  these compulsory fields
%                  {'AffineInvariants', 'RelativeArea', 'RatioAxesLengths'}
%                  and all other specified in the list_props and not used 
%                  to derive those     
% TO Do: include Carlos's shape descriptors in the future!
%**************************************************************************
% EXAMPLES USAGE:
% cl;
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% [bwSMIarray, bwSMIstruct] = bwSMIdescriptor(bw);
%**************************************************************************
% REFERENCES: 
%**************************************************************************

function [SMIarray, SMIstruct] = bwSMIdescriptor(bw, conn, list_props, ...
                                       order, coeff_file, num_moments)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
% compulsory statistics types   
if nargin < 6
    num_moments = 6;
end
if nargin < 5
    coeff_file = 'afinvs4_19.txt';
end
if nargin < 4
    order = 4;
end
if nargin < 3
    list_props =  {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
                  'Eccentricity','EulerNumber','Solidity'};
end
if nargin < 2
    conn = 4;
end
if nargin < 1
    error('bwSMIdescriptor.m requires at least 1 input argument!');             
end

if not(islogical(bw))
    error('bwSMIdescriptor: bw should be of class "logical"!');
end
%**************************************************************************
% constants
%--------------------------------------------------------------------------
%order = 4; coeff_file = 'afinvs4_19.txt';

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
coeff = readinv(coeff_file);
image_area = size(bw,1)*size(bw,2);
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
SMIstruct_no_centr =  struct([]);
SMIarray = [];
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% region properities
[regions_props, conn_comps] = compute_region_props(bw, conn, list_props);
% derived properties
[derived_props] = compute_derived_props(regions_props, image_area);
% affine invariants
[affine_props] = cc_compute_affine_invariants(conn_comps, order, coeff, num_moments);
% combine
[SMIstruct] = combine_regions_props(derived_props, affine_props);


% remove the Centroid from the structure
props_names = fieldnames(SMIstruct);
if isfield(SMIstruct, 'Centroid')
    for n = 1: length(regions_props)
        for ts = 1:length(props_names)
            type_stat = char(props_names{ts});
            switch type_stat
                case {'Centroid'}
                      continue;
                otherwise
                    prop = SMIstruct(n).(type_stat);
                    SMIstruct_no_centr(n).(type_stat) = prop;
            end
        end
    end
end
% convert the structure to array
SMIarray = struct2array(SMIstruct_no_centr);