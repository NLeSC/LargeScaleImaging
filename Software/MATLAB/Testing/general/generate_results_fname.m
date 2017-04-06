% generate_results_fname- generates unique results filename for an experiment
%**************************************************************************
% [filename] = generate_results_fname(results_path, script_name, format_datetime, ext)
%
% author: Elena Ranguelova, NLeSc
% date created: 6 April 2017
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% results_path - path to the resulting file
% script_name - name of the script for the experiment
% format_datetime - the format for the date and time strings
% ext - output file extension
%**************************************************************************
% OUTPUTS:
% filename- output filename containing the results of the script
%**************************************************************************
% NOTES: called from testing scripts. Uses current date and time to make
% the output filename unique
%**************************************************************************
% EXAMPLES USAGE: 
% see scrpits (for example test_IsSameScene_BIN_SMI_Oxford)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [filename] = generate_results_fname(results_path, script_name, format_datetime, ext)
    
   
%% input control
if nargin < 4
    ext = 'mat';
end
if nargin < 3
    error('generate_results_fname requires 2 input arguments!');
end

%% get the current date and time as formatted string
datetime_str = datestr(datetime('now'), format_datetime);

%% make the full filename
fname = strcat(script_name,'_',datetime_str,'.',ext);
filename = fullfile(results_path, fname);
