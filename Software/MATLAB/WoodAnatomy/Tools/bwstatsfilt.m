% bwstatsfilt- filters binary regions on a pre-computed statistic (derived property)
% **************************************************************************
% [bw_filt, regions_idx, thresh] = bwstatsfilt(bw, stats, stats_type, conn_comp, range) 
%
% author: Elena Ranguelova, NLeSc
% date created: 03 Feb 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw        - binary image (logical)- can be mask of detected regions
% stats      - statistics of derived regionproperties
% stats_type - the type of statistic to filter on; can be only any of
%              {'RelativeArea', 'Eccentricity', 'Orientation', ...
%              'RatioAxesLengths'}
% [conn_comp] - connected components pre-computed from bw (e.g. by a detector)
%               if empty- they are computed from bw using default connectivity
% [range]     - vector of 2 thresholds for stats_type to filter on (in between);
%               if empty- the range is [0.1 0.9]*max_value(stats_type)
%**************************************************************************
% OUTPUTS:
% bw_filet    - binary image (logical) of the filtered regions
% regions_idx - index of filtered regions
% thresh      - the threshold values = range or range*max_value (of the statistic)
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% see test_bwtatsfilt.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [bw_filt, regions_idx, thresh] = bwstatsfilt( bw, stats, stats_type,...
                                               conn_comp, range)
                                               
%% input parameters 
if nargin < 5
    range = [0.1 0.9];
end
if nargin < 4
    conn_comp = bwconncomp(bw);
end
if nargin < 3
    error('get_test_filenames requires min. 3 input arguments!');
end
stats_types = {'RelativeArea', 'Eccentricity', 'Orientation', 'RatioAxesLengths'};
if ~ismember(stats_type, stats_types)
    error('Parameter stats_type can be only one of: RelativeArea|Eccentricity|Orientation|RatioAxesLengths');
end

%% initialize
bw_filt = logical(zeros(size(bw)));
regions_idx =[];
thresh= [];

%% get the values of the selected statistics type
type_stat =char(stats_type);
stats_values = cat(1,stats.(type_stat));
num_regions = length(stats_values);
% show the histogram for debugging
%h =  histcounts(stats_values, 50, 'Normalization','probability');
%figure; bar(h);

%% compute the thresholds
if nargin < 5
    max_value  = max(stats_values(:));
    lo_thr = range(1)*max_value;
    hi_thr = range(2)*max_value;
else
    lo_thr = range(1);
    hi_thr = range(2);
end
% show the values for debugging
%figure;plot(stats_values)
%% select the regions within [lo_thr hi_thr]
index = (abs(stats_values) >= lo_thr) & (abs(stats_values) <= hi_thr);
%figure;imshow(index);
%size(index)
clear stats_values
%length(index)
%% find the pixel indicies to keep
pixels_idx = conn_comp{1,1}.PixelIdxList(index);
clear conn_comp
pixels_idx = vertcat(pixels_idx{:});

%% make the new binary image and return the non-zero region indicies and threhsold
bw_filt(pixels_idx) = true;

region_index = index(:)'.*(1:num_regions);
regions_idx = nonzeros(region_index);
thresh = [lo_thr hi_thr];


end

