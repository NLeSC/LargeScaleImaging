% bwstatsfilt- filters binary regions on a pre-computed statistic (derived property)
% **************************************************************************
% [bw_filt, regions_idx, thresh] = bwstatsfilt(bw, stats, stats_types, conn_comp, range) 
%
% author: Elena Ranguelova, NLeSc
% date created: 03 Feb 2016
% last modification date: 11/12 Feb 2016
% modification details: the function can accept now lists of statistics type
%                       and ranges;  the relationship between types is AND 
%**************************************************************************
% INPUTS:
% bw        - binary image (logical)- can be mask of detected regions
% stats      - statistics of derived regionproperties
% stats_types - list of types of statistics to filter on; can be only any of
%              {'RelativeArea', 'Eccentricity', 'Orientation', ...
%              'RatioAxesLengths'}
% [conn_comp] - connected components pre-computed from bw (e.g. by a detector)
%               if empty- they are computed from bw using default connectivity
% [ranges]     - list of vectors of 2 thresholds per stats_types to filter on (in between);
%               if empty- every range is [0.1 0.9]*max_value(stats_type{i})
%**************************************************************************
% OUTPUTS:
% bw_filet    - binary image (logical) of the filtered regions
% regions_idx - index of filtered regions
% threshs     - the threshold values = ranges or ranges*max_value (per statistic)
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% see test_bwtatsfilt.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [bw_filt, regions_idx, threshs] = bwstatsfilt(bw, stats, stats_types,...
                                               conn_comp, ranges)
                                               
%% input parameters
if nargin < 3
    error('get_test_filenames requires min. 3 input arguments!');
else
   num_stats = length(stats_types); 
end
if nargin < 5    
    for i = 1:num_stats
        ranges{i} = [0.1 0.9];
    end
end
if nargin < 4
    conn_comp = bwconncomp(bw);
end

possible_stats_types = {'RelativeArea', 'Eccentricity', 'Orientation', 'RatioAxesLengths'};
for i = 1:num_stats
    if ~ismember(char(stats_types{i}), possible_stats_types)
        error('Parameter stats_types per element can be only one of: RelativeArea|Eccentricity|Orientation|RatioAxesLengths');
    end
end

%% initialize
bw_filt = logical(zeros(size(bw)));
threshs= cell(1, num_stats);
num_regions = length(cat(1,stats.RelativeArea));
index = ones(num_regions,1);
%% get the values per statistics type
for i = 1:num_stats
    type_stat =char(stats_types{i});
    stats_values = cat(1,stats.(type_stat));
    range = ranges{i};
    % show the histogram for debugging
%     h =  histcounts(stats_values, 50, 'Normalization','probability');
%     figure; bar(h);
    
    %% compute the thresholds
    if nargin < 5
        max_value  = max(stats_values(:));
        lo_thr = range(1)*max_value;
        hi_thr = range(2)*max_value;
    else
        lo_thr = range(1);
        hi_thr = range(2);
    end
    %% select the regions within [lo_thr hi_thr]
    sub_index = (stats_values >= lo_thr) & (stats_values <= hi_thr);
    index = and(index, sub_index);
    threshs{i} = [lo_thr hi_thr];
    clear stats_values sub_index
end
%length(index)
%% find the pixel indicies to keep
pixels_idx = conn_comp{1,1}.PixelIdxList(index);
clear conn_comp
pixels_idx = vertcat(pixels_idx{:});

%% make the new binary image and return the non-zero region indicies and threshold
bw_filt(pixels_idx) = true;

num_regions = length(index);
region_index = index(:)'.*(1:num_regions);
regions_idx = nonzeros(region_index);

end

