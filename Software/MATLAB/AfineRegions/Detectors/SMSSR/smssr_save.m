% smssr_save- function to save the results from the SMSSR detector
%**************************************************************************
% smssr_save(features_fname, regions_fname, num_regions, features, ...
%                                                           saliency_masks)
%
% author: Elena Ranguelova, NLeSc
% date created: 03 June 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% features_fname- the filename for the ellipse features (.txt)
% regions_fname- the file for the saliency masks of the regions (binary .mat)
% num_regions- the number of salient regions
% saliency_masks- the binary saliency masks
% features- the array with ellipse features
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% NOTES: usually is executed after smssr.m
%**************************************************************************
% EXAMPLES USAGE: 
% see scrpits (for example test_smssr.m)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function smssr_save(features_fname, regions_fname, num_regions, features, ...
                                                           saliency_masks)

%**************************************************************************
% input control    
%--------------------------------------------------------------------------
if nargin < 5
    error('mssr_save.m requires 5 input arguments!');
    return
end
%**************************************************************************
% constants/hard-set parameters
%--------------------------------------------------------------------------
%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% create additional filename to save all the features (incl. saliency type)
i = find(features_fname == '.');
if isempty(i)
    features_type_fname = [features_fname '_type.smssr'];
else
    j=i(end);
    features_type_fname = [features_fname(1:i-1) '_type.smssr'];
end
%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
%**************************************************************************
% computations
%--------------------------------------------------------------------------
% pre-processing
%--------------------------------------------------------------------------
% leave out the saliency type
num_features = size(features,2);

features_notype = zeros(num_regions, num_features - 1);
features_notype = features(:,1:num_features - 1);

% parameters depending on pre-processing
%--------------------------------------------------------------------------
% core processing
%--------------------------------------------------------------------------
%**************************************************************************
% variables -> output parameters
%--------------------------------------------------------------------------
% save the binary masks
save(regions_fname,'saliency_masks');
%..........................................................................
% save the ellipse features

% without the type (for the descriptor)
fid = fopen(features_fname,'w');
fprintf(fid,'%d \n',0);
fprintf(fid,'%d \n',num_regions);
for j = 1:num_regions
       fprintf(fid, '%f ', features_notype(j,:));fprintf(fid,'\n');
end
fclose(fid);
%..........................................................................
% with the saliency type (for potentail future use)

fid = fopen(features_type_fname,'w');
fprintf(fid,'%d \n',0);
fprintf(fid,'%d \n',num_regions);
for j = 1:num_regions
       fprintf(fid, '%f ', features(j,:));fprintf(fid,'\n');
end
fclose(fid);

