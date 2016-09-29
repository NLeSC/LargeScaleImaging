% compute_derived_props.m- computing derived properties of salient regions
%**************************************************************************
% [derived_regions_props] = compute_derived_props(regions_props, area)
%
% author: Elena Ranguelova, NLeSc
% date created: 9 Sept 2016
% last modification date: 27 Sept 2016
% modification details: RelativeArea gets a weight of 100
%**************************************************************************
% INPUTS:
% regions_props         structure with all region properties 
% area                  the image area (in number of pixels)
%**************************************************************************
% OUTPUTS:
% derived_regions_props derived regions properties from the following list:
%                       (new) 'RelativeArea', 'RatioAxesLengths' 
%                       (if already computed) everything else
%**************************************************************************
% NOTE:
% the region_props must have 'Area', 'MinorAxisLength','MajorAxisLength'
%**************************************************************************
% EXAMPLES USAGE:
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% conn = 4;
% imshow(bw); title('Image with Circles'); axis on, grid on;
% list = {'Centroid', 'Area','MinorAxisLength','MajorAxisLength','Solidity'};
% [regions_properties, conn_comp] = compute_region_props(bw, conn, list);
% area = size(a,1) * size(a,2);
% [derived_regions_properties] = compute_derived_props(regions_properties, area)
%**************************************************************************
% REFERENCES: 
%**************************************************************************

function [derived_regions_props] = compute_derived_props(regions_props, area)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
% compulsory statistics types   
list_compulsory_types = {'Area','MinorAxisLength','MajorAxisLength'};

if nargin < 2
    error('compute_region_props.m requires at least 2 input arguments!');
    derived_region_properties = [];
    return
else
    % compulsory statistics types    
    for ts = list_compulsory_types
        type_stat = char(ts);
        if ~ isfield(regions_props, type_stat)
            error(['The input region_props.m must have a field: ' type_stat '!']);
            derived_region_properties = [];
            return
        end
    end                 
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% derived field names
list_derived_types = {'RelativeArea', 'RatioAxesLengths'}';
list_existing_types_all = fieldnames(regions_props);
list_existing_types = setdiff(list_existing_types_all, list_compulsory_types);
list_derived_types_all = union(list_derived_types, list_existing_types);

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
derived_regions_props =  struct([]);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
% compute the derived properies
for n = 1: length(regions_props)
    for ts = 1:length(list_derived_types_all)
        type_stat = char(list_derived_types_all{ts});
        switch type_stat
%             case {'Centroid'}
%                 continue;
            case {'RelativeArea'}
                reg_area = regions_props(n).Area;
                derived_regions_props(n).(type_stat) = reg_area/area * 100;
            case {'RatioAxesLengths'}
                minor_axis_length = regions_props(n).MinorAxisLength;
                major_axis_length = regions_props(n).MajorAxisLength;
                derived_regions_props(n).(type_stat) = minor_axis_length/major_axis_length;
            otherwise
                prop = regions_props(n).(type_stat);
                derived_regions_props(n).(type_stat) = prop;
        end
    end
end
