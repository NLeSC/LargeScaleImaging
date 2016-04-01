% binary_mask2features- obtain the equivalent elipses from a binary mask
%**************************************************************************
% [num_regions, features] = binary_mask2features(binary_mask,conn, saliency_type)
%
% author: Elena Ranguelova, NLeSc
% date created: 11 August 2015
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% binary_masks    2D binary mask of detected salient regions
% [conn]            neighbourhood connectivity to extract connected components
%                 [optional], if not specified default is 4
% saliency_type   one of the 4 possible MSSR types-
%                 holes/islands/indentaitons/protrusions
%**************************************************************************
% OUTPUTS:
% num_regions    number of salient regions
% features       parameters of the equivalent to the region ellipse
%**************************************************************************
% SEE ALSO
% smssr_old- the oldimplemntation of the SMSSR detector 
%**************************************************************************
% RERERENCES:
%**************************************************************************
function [num_regions, features] = binary_mask2features(binary_mask,conn, saliency_type)

                                         
%**************************************************************************
% input control                                         
%--------------------------------------------------------------------------
if nargin < 2 || isempty(conn)
    conn = 4;
end
if nargin < 1
    error('binary_mask2features.m requires at least 1 input argument- the binary mask!');
    thres_masks = [];
    return
end


%**************************************************************************
% computations
%--------------------------------------------------------------------------
%num_regions = 0;

[LE, num_regions] = bwlabel(binary_mask,conn);
stats = regionprops(LE, 'Centroid','MajorAxisLength',...
    'MinorAxisLength','Orientation');

for j = 1:num_regions

    %ellipse parameters
    a = fix(getfield(stats,{j},'MajorAxisLength')/2);
    b = fix(getfield(stats,{j},'MinorAxisLength')/2);

    if ((a>0) && (b>0))
       % num_regions = num_regions+1;
        C = getfield(stats,{j},'Centroid');
        x0 = C(1); y0= C(2); %ORIGINAL LINE!!
       % x0 = C(1)-1; y0= C(2)-1; % added for comparision to Python as indexing starts from 0,not 1 
        disp(x0), disp(y0)
        disp('---');
        phi_deg = getfield(stats,{j},'Orientation');
        if (phi_deg==0)
            phi_deg = 180;
        end
        phi = phi_deg*pi/180;

        % compute the MSER features
        [A, B, C] = conversion_ellipse(a, b, -phi);
        features(j,:) = [x0; y0; A; B; C; saliency_type]'; %#ok<AGROW>
    else
        %num_regions = num_regions + 1;
        features(j,:) = [NaN; NaN; NaN; NaN; NaN; saliency_type]';%#ok<AGROW>
        disp('binary_masks2features warning: A non-fitting ellipse found- recording NaN values!');
    end

end % for j



