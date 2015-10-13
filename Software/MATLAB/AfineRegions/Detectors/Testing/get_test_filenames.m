% get_test_filenames- obtain test filenames from test_case and detector
%**************************************************************************
% [image_filenames, features_filenames, regions_filenames] = ...
%           get_test_filenames(test_case, detector, data_path, results_path)
%
% author: Elena Ranguelova, NLeSc
% date created: 23 Sept 2015
% last modification date: 1 Oct 2015    
% modification details: added the DSMR detector
%**************************************************************************
% INPUTS:
% test_case- test case from the VGG test suite, e.g. 'graffitti'
% detector - salience regions detector, e.g. 'MSSR', 'SMSSR', 'DMSR'
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
% see scrpits (for example test_smssr_general.m)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [image_filenames, features_filenames, regions_filenames] = ...
           get_test_filenames(test_case, detector, data_path, results_path)
       
if nargin < 4
    error('get_test_filenames requires 4 input arguments!');
end

image_filenames = cell(6,1);
features_filenames = cell(6,1);
regions_filenames = cell(6,1);

for i = 1:6
    name = strcat(test_case, num2str(i), '.png' );
    image_filenames{i} = fullfile(data_path,test_case,name);
    name = strcat(test_case, num2str(i), '.', lower(detector) );
    features_filenames{i} = fullfile(results_path,test_case,name);
    switch lower(detector)
        case 'mssr'
            name = strcat(test_case, num2str(i), '_regions.mat' );    
        case 'mssra'
            name = strcat(test_case, num2str(i), '_allregions.mat' );    
        case 'smssr'
            name = strcat(test_case, num2str(i), '_smartregions.mat' ); 
        case 'dmsr'
            name = strcat(test_case, num2str(i), '_dmsrregions.mat' );
        case 'dmsra'
            name = strcat(test_case, num2str(i), '_dmsrallregions.mat' );  
        otherwise
            error('Unknown detector!');
    end
    regions_filenames{i} = fullfile(results_path,test_case,name);
end