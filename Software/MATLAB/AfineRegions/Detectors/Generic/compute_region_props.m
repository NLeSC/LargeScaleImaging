% compute_region_props.m- computing region properties from salient binary masks
%**************************************************************************
% [saliency_masks] = binary_detector(ROI, SE_size_factor, area_factor, ...
%                                saliency_type, visualise)
%
% author: Elena Ranguelova, NLeSc
% date created: 28 Sept 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% ROI- binary mask of the Region Of Interest
% SE_size_factor- structuring element (SE) size factor
% area_factor - area factor for the significant connected components (CCs)
% [saliency_type]- array with 4 flags for the 4 saliency types 
%                (Holes, Islands, Indentations, Protrusions)
%                [optional], if left out- default is [1 1 1 1]   
% [visualise] - visualisation flag
%               [optional], if left out- default is 0, if set to 1, 
%               intermendiate steps of the detection are shown 
%**************************************************************************
% OUTPUTS:
% saliency_masks - 3-D array of the binary saliency masks of the regions
%                  saliency_masks(:,:,i) contains the salient regions per 
%                  type: i=1- "holes", i=2- "islands", i=3 - "indentaitons"
%                  and i =4-"protrusions"  if saliency_types is [1 1 1 1]
%**************************************************************************
% EXAMPLES USAGE:
% [saliency_masks] = binary_detector(ROI, se_size_factor, area_factor, ...
%                                saliency_type, visualise);
%                    as called from a gray level detector
%**************************************************************************
% REFERENCES: Ranguelova, E., Pauwels, E. J. ``Morphology-based Stable
% Salient Regions Detector'', International conference on Image and Vision 
% Computing New Zealand (IVCNZ'06), Great Barrier Island, New Zealand,
% November 2006, pp.97-102