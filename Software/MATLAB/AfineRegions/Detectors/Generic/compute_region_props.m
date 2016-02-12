% compute_region_props.m- computing region properties from salient binary masks
%**************************************************************************
% [regions_properties] = compute_region_props(saliency_masks, list_properties)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 Oct 2015
% last modification date: 03 Feb 2016
% modification details: connected components are also output
% last modification date: 12 Feb 2016
% modification details: new parameter conenctivity is aded
%**************************************************************************
% INPUTS:
% saliency_masks-  the binary masks of the extracted salient regions
% list_properties- the list of desired region properties (see help
%                  regionprops for all values)
%**************************************************************************
% OUTPUTS:
% region_properties- structure with all region properties. The fileds of 
%                   the structure are as required in list_properties
% conn- neighbourhood connectivity to compute toobtainthe regions from
%       the binary masks
% conn_comp - the connected components derived from the saliency_masks
%**************************************************************************
% EXAMPLES USAGE:
% a = imread('circlesBrightDark.png');
% bw = a < 100;
% imshow(bw); title('Image with Circles')
% list = {'Centroid', 'MajorAxisLength','MinorAxisLength'};
% [regions_properties, conn_comp] = compute_region_props(bw, list)
%**************************************************************************
% REFERENCES: 
%**************************************************************************
function [regions_properties, conn_comp] = compute_region_props(saliency_masks, ...
                                                     conn, list_properties)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 3
    list_properties = {'Area', 'Centroid','ConvexArea', ...
                'Eccentricity', 'EquivDiameter', 'MinorAxisLength',...
                'MajorAxisLength', 'Orientation', 'Solidity'};
elseif nargin < 2
    conn = 4;
elseif nargin < 1
    error('compute_region_props.m requires at least 1 input argument!');
    region_properties = [];
    connn_comp = [];
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% how many types of regions?
sal_types = size(saliency_masks,3);

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
regions_properties=  struct([]);
conn_comp = [];

%**************************************************************************
% computations
%--------------------------------------------------------------------------
j = 0;
if sal_types > 0
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j), conn);
    regions_properties = regionprops(CC, list_properties);
    conn_comp{j} = CC;
end
if sal_types > 1
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j), conn);
    new_properties = regionprops(CC, list_properties);
    regions_properties = append_props(regions_properties, new_properties,...
        list_propertiess);
    conn_comp{j} = CC;
end
if sal_types > 2
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j), conn);
    new_properties = regionprops(CC, list_properties);
    regions_properties = append_props(regions_properties, new_properties,...
        list_propertiess);
    conn_comp{j} = CC;
end
if sal_types > 3
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j), conn);
    new_properties = regionprops(CC, list_properties);
    regions_properties = append_props(regions_properties, new_properties,...
        list_propertiess);
    conn_comp(j) = CC;
end
%**************************************************************************
% nested functions
%--------------------------------------------------------------------------
function appended_props = append_props(old_props, new_props, list_props)
    for l = 1: length(list_props)
        appended_props = old_props;
        new_props_per_type = new_props.list_props{l};
        appended_props.list_props{l} = [appended_props.list_props{l} ...
            new_props_per_type];
    end    
end

end