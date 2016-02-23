% bwstatsfilt- filters binary regions on a pre-computed statistic (derived property)
% **************************************************************************
% [bw_filt, regions_idx, thresh] = bwstatsfilt(bw, stats, stats_types, logic_ops, conn_comp, range) 
%
% author: Elena Ranguelova, NLeSc
% date created: 03 Feb 2016
% last modification date: 12 Feb 2016
% modification details: added extra input- the logic relationship can be OR or AND 
% last modification date: 11 Feb 2016
% modification details: the function can accept now lists of statistics type
%                       and ranges;  the relationship between types is AND 
%**************************************************************************
% INPUTS:
% bw        - binary image (logical)- can be mask of detected regions
% stats      - statistics of derived regionproperties
% stats_types - list of types of statistics to filter on; can be only any of
%              {'RelativeArea', 'Eccentricity', 'Orientation', ...
%              'RatioAxesLengths'}
% [logic_ops]- list of logical operations between the possible filter
%              conditions; default is 'AND';the order
%              orevaluaitonisstrictly left to right
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
                                               logic_ops, conn_comp, ranges)
                                               
%% input parameters
if nargin < 3
    error('get_test_filenames requires min. 3 input arguments!');
else
   num_conds = length(stats_types);
end
if nargin < 6 || isempty(ranges)  
    auto_range = true;
    for i = 1:num_conds
        ranges{i} = [0.1 0.9];
    end
else
    auto_range = false;
end
if nargin < 5 || isempty(conn_comp)
    conn_comp = bwconncomp(bw);
end
if nargin < 4 || isempty(logic_ops)
    if num_conds > 1
        for j =  1: num_conds - 1
            logic_ops{j} = 'AND';
        end
    end
end
num_logic_ops = length(logic_ops);
possible_logic_ops = {'or', 'and'};
for j = 1:num_logic_ops
    if ~ismember(lower(char(logic_ops{j})), possible_logic_ops)
        error('Parameter logic_ops per element can be only one of: AND|OR');
    end
end
if num_logic_ops ~= (num_conds - 1)
    error('The number of the logical operations should be with 1 less than the number of filterring conditions');
end
possible_stats_types = {'RelativeArea', 'Eccentricity', 'Orientation', 'RatioAxesLengths', 'Solidity'};
for i = 1:num_conds
    if ~ismember(char(stats_types{i}), possible_stats_types)
        error('Parameter stats_types per element can be only one of: RelativeArea|Eccentricity|Orientation|RatioAxesLengths');
    end
end

%% initialize
bw_filt = false((size(bw)));
threshs= cell(1, num_conds);
num_regions = length(cat(1,stats.RelativeArea));
index = ones(num_regions,1);
%% get the values per statistics type
for i = 1:num_conds
    type_stat =char(stats_types{i});
    stats_values = cat(1,stats.(type_stat));
    range = ranges{i};
    % show the histogram for debugging
%     h =  histcounts(stats_values, 50, 'Normalization','probability');
%     figure; bar(h);
    
    %% compute the thresholds
    if auto_range
        max_value  = max(stats_values(:));
        lo_thr = range(1)*max_value;
        hi_thr = range(2)*max_value;
    else
        lo_thr = range(1);
        hi_thr = range(2);
    end
    %% select the regions within [lo_thr hi_thr]
    sub_index = (stats_values >= lo_thr) & (stats_values <= hi_thr);
    if i == 1 
        index = and(index, sub_index);
    else
        oper = char(logic_ops{i-1});
        switch lower(oper)
            case 'and'
                index = and(index, sub_index);
            case 'or'
                index = or(index, sub_index);
        end
    end
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

%num_regions = length(index);
%region_index = index(:)'.*(1:num_regions);
%regions_idx = nonzeros(region_index);
regions_idx = find(index);

end

