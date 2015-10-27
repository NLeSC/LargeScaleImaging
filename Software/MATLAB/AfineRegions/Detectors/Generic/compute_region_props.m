% compute_region_props.m- computing region properties from salient binary masks
%**************************************************************************
% [regions_properties] = compute_region_props(saliency_masks, list_properties)
%
% author: Elena Ranguelova, NLeSc
% date created: 27 Oct 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% saliency_masks-  the binary masks of the extracted salient regions
% list_properties- the list of desired region properties (see help
%                  regionprops for all values)
%**************************************************************************
% OUTPUTS:
% region_properties- structure with all region properties. The fileds of 
%                   the structure are as required in list_properties
%**************************************************************************
% EXAMPLES USAGE:
% a = imread('circlesBrightDark.png');
% bw = a < 100;
% imshow(bw); title('Image with Circles')
% list = {'Centroid', 'MajorAxisLength','MinorAxisLength'};
% [regions_properties] = compute_region_props(bw, list)
%**************************************************************************
% REFERENCES: 
%**************************************************************************
function [regions_properties] = compute_region_props(saliency_masks, ...
                                                     list_properties)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 2
    list_properties = {'Area', 'Centroid','ConvexArea', ...
                'Eccentricity', 'EquivDiameter', 'MinorAxisLength',...
                'MajorAxisLength', 'Orientation'};
elseif nargin < 1
    error('compute_region_props.m requires at least 1 input argument!');
    region_properties = [];
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

%**************************************************************************
% computations
%--------------------------------------------------------------------------
j = 0;
if sal_types > 0
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j));
    regions_properties = regionprops(CC, list_properties);
end
if sal_types > 1
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j));
    new_properties = regionprops(CC, list_properties);
    regions_properties = append_props(regions_properties, new_properties,...
        list_propertiess);
end
if sal_types > 2
    j = j+ 1;
    CC = bwconncomp(saliency_masks(:,:,j));
    new_properties = regionprops(CC, list_properties);
    regions_properties = append_props(regions_properties, new_properties,...
        list_propertiess);
end
if sal_types > 3
    j = j+ 1;
    BW = saliency_masks(:,:,j);
    new_properties = regionprops(BW, list_properties);
    regions_properties = append_props(regions_properties, new_properties,...
        list_propertiess);
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