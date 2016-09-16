% show_binary - visualize binary image in a given figure/subplot with title
% **************************************************************************
% [] = show_binary(bw, hfig, hsbplt, title_str)
%
% author: Elena Ranguelova, NLeSc
% date created: 15 Sep 2016
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% bw            binary image (logical)- can be mask of detected regions
% [hfig]        figure handle. Optional. If not given new figure is created
% [hsbplt]      subplot. Optional. If not given (111) is assumed, i.e. no subplot
% [title_str]       title string. Optional. I fnot given no title is displayed.
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE: 
% 
% see test_matching_SMI_desc_affine_dataset.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function show_binary(bw, hfig, hsbplt, title_str)

%% input parameters
if nargin < 4
    title_str =[]; % no title    
end
if nargin < 3
    hsbplt = subplot(111);
end
if nargin < 2
    hfig = figure;
end
if nargin < 1
    error('show_binary requires min. 1 input argument!');
end
%% initializations
figure(hfig);
subplot(hsbplt);

%% visualize
imshow(bw);
axis on; grid on;

title(title_str);
end
