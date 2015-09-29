% get_test_filenames- obtain test filenames from test_case and detector
%**************************************************************************
% [image_filenames, features_filenames, regions_filenames] = ...
%           get_test_filenames(test_case, detector, data_path, results_path)
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% test_case- test case from LM pictures wood dataset, e.g. 'Carini'
% detector - salience regions detector, e.g. 'MSER'
% data_path- path to the image data
% results_path - path to the resulting files
%**************************************************************************
% OUTPUTS:
% image_filenames- cell array with the original image filenames
% features_filenames- cell array wtih feature filenames
% regions_filenames- cell array with the binary masks of detected regions
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% see scrpits (for example test_mser_LMwood.m)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [image_filenames, features_filenames, regions_filenames] = ...
           get_test_filenames(test_case, detector, data_path, results_path)
       
if nargin < 4
    error('get_test_filenames requires 4 input arguments!');
end

image_filenames = cell(1,1);
features_filenames = cell(1,1);
regions_filenames = cell(1,1);

for i = 1:6
    name = strcat(test_case, num2str(i), '.png' );
    image_filenames{i} = fullfile(data_path,test_case,name);
    name = strcat(test_case, num2str(i), '.', detector );
    features_filenames{i} = fullfile(results_path,test_case,name);
    switch lower(detector)
        case 'mser'
            name = strcat(test_case, num2str(i), '_mser.mat' );     
        case 'smmsr'
            name = strcat(test_case, num2str(i), '_salientregions.mat' ); 
            
    end
    regions_filenames{i} = fullfile(results_path,test_case,name);
end