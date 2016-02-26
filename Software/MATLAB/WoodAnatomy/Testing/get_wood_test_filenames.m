% get_wood_test_filenames- obtain test filenames from test_case and detector
%**************************************************************************
% [image_filenames, features_filenames, regions_filenames, ...
% regions_props_filenames, filtered_regions_filenames] = ...
%     get_wood_test_filenames(test_case, detector, data_path, results_path)
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Sept 2015
% last modification date: 26 Feb 2016
% modification details: added filtered regions filename as output
% last modification date: 27 Oct 2015
% modification details: added region properties filename as output
% last modification date: 15 Oct 2015
% modification details: adapted for the actual wood test images as in LM
% pictures wood Dropbox directory
%**************************************************************************
% INPUTS:
% test_case- test case from LM pictures wood dataset, e.g. 'Carini'
% detector - salience regions detector, e.g. 'MSER', 'DMSR'
% data_path- path to the image data
% results_path - path to the resulting files
%**************************************************************************
% OUTPUTS:
% image_filenames- cell array with the original image filenames
% features_filenames- cell array wtih feature filenames
% regions_filenames- cell array with the binary masks of detected regions
%                   filenames
% regions_props_filenames- cell array with the regions properties filenames
%**************************************************************************
% NOTES: called from testing scripts
%**************************************************************************
% EXAMPLES USAGE: 
% see scrpits (for example test_mser_LMwood.m)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [image_filenames, features_filenames, regions_filenames,...
           regions_props_filenames, filtered_regions_filenames] = ...
           get_wood_test_filenames(test_case, detector, data_path, results_path)
       
if nargin < 4
    error('get_test_filenames requires 4 input arguments!');
end

image_filenames = cell(1,1);
features_filenames = cell(1,1);
regions_filenames = cell(1,1);
regions_props_filenames = cell(1,1);
filtered_regions_filenames = cell(1,1);

switch lower(char(test_case))
    case 'argania'
        base_fname{1} = 'Argania spinosa1';
        base_fname{2} = 'Argan spinL01';
        base_fname{3} = 'Argan spinL02';
    case 'brazzeia_c'
        base_fname{1} = 'Brazzeia congo01';
        base_fname{2} = 'Brazzeia congo02';
    case 'brazzeia_s'
        base_fname{1} = 'Brazzeia soyaux01';
        base_fname{2} = 'Brazzeia soyaux02';
    case 'chrys'
        base_fname{1} = 'Chrys afrPL01';
        base_fname{2} = 'Chrys afrPL02';
    case 'citronella'
        base_fname{1} = 'Citronella silvatica 01';
        base_fname{2} = 'Citronella silvatica 02';
    case 'desmo'
        base_fname{1} = 'Desmostachys vogelii 01';
        base_fname{2} = 'Desmostachys vogelii 04';
    case 'gluema'
        base_fname{1} = 'Gluema ivor01';
        base_fname{2} = 'Gluema ivor02';
    case 'rhaptop'
        base_fname{1} = 'Rhaptop beguei01';
        base_fname{2} = 'Rhaptop beguei02';
    case 'stem'
        base_fname{1} = 'Stemonurus celebicus 01';
        base_fname{2} = 'Stemonurus celebicus 03';
end

num_images = length(base_fname);
for i = 1:num_images
    base = char(base_fname{i});
    basic_image_filename = [base '.png'];
    image_filenames{i} = fullfile(data_path, basic_image_filename);
    name = strcat(base, '.', lower(detector));
    features_filenames{i} = fullfile(results_path,upper(detector),name);
    switch lower(detector)
        case 'mser_matlab'
            name = strcat(base, '.mat' );
        case 'mser'
            name = strcat(base, '_mser.mat' );
        case 'smmsr'
            name = strcat(base, '_salientregions.mat' );
        case 'dmsr'
            name = strcat(base, '_dmsrregions.mat' );
        otherwise
            error('Unknown detector');            
    end
    regions_filenames{i} = fullfile(results_path,detector, name);        
    switch lower(detector)
        case 'mser_matlab'
            name_props = strcat(base, '_props.mat' );
        case 'mser'
            name_props = strcat(base, '_mser_props.mat' );
        case 'smmsr'
            name_props = strcat(base, '_salientregions_props.mat' );
        case 'dmsr'
            name_props = strcat(base, '_dmsrregions_props.mat' );
        otherwise
            error('Unknown detector');
    end
    regions_props_filenames{i} = fullfile(results_path,detector, name_props);    
    switch lower(detector)
        case 'mser_matlab'
            continue;
        case 'mser'
            continue;
        case 'smmsr'
            continue;
        case 'dmsr'
            name_filtered = strcat(base, '_dmsrregions_filtered.mat' );
            filtered_regions_filenames{i} = fullfile(results_path,detector,...
                'filtered',name_filtered);
        otherwise
            error('Unknown detector');
    end
    
end