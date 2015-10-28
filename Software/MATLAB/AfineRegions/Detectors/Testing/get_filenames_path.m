% get_filenames_path- obtain filenames from path and detector
%**************************************************************************
% [image_filenames, features_filenames, regions_filenames] = ...
%           get_test_filenames(detector, data_path, results_path)
%
% author: Elena Ranguelova, NLeSc
% date created: 28 Oct 2015
% last modification date: 1 Oct 2015    
% modification details: 
%**************************************************************************
% INPUTS:
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
% see scrpits (for example test_mssr_freiburg.m)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [image_filenames, features_filenames, regions_filenames] = ...
           get_filenames_path(detector, data_path, results_path)
       
if nargin < 3
    error('get_filenames_path requires 3 input arguments!');
end

% find out the number of png images in the data_path
image_fnames = dir(fullfile(data_path,'*.png'));
num_images = length(image_fnames);

% initialize the  filenames structure
image_filenames = cell(num_images,1);
features_filenames = cell(num_images,1);
regions_filenames = cell(num_images,1);


for i = 1:num_images
    [~,name,~] = fileparts(image_fnames(i).name); 
    image_filenames{i} = fullfile(data_path,image_fnames(i).name);
    dname = strcat(name, '.', lower(detector) );
    features_filenames{i} = fullfile(results_path,dname);
    switch lower(detector)
        case 'mssr'
            rname = strcat(name, '_regions.mat' );    
        case 'mssra'
            rname = strcat(name, '_allregions.mat' );    
        case 'smssr'
            rname = strcat(name, '_smartregions.mat' ); 
        case 'dmsr'
            rname = strcat(name, '_dmsrregions.mat' );
        case 'dmsra'
            rname = strcat(name, '_dmsrallregions.mat' );  
        otherwise
            error('Unknown detector!');
    end
    regions_filenames{i} = fullfile(results_path,rname);
end