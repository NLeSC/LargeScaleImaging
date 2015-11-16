function [ trans_image ] = applyAffineTransform( input_image, H, keepsize)
% applyAffineTransform- apply an affine transform spesified by 
% the homography H

% transpose the homography matrix sonce rows, cols in MATLAB are swapped
% (x,y)
%Ht = transpose(H);

% image size
[height, width, ndims]  = size(input_image);

% make the affine transformation
%Tt = maketform('affine',Ht);
T = maketform('affine',H);

% transform the image
if keepsize
    trans_image = imtransform(input_image,T,'XData' ,[1 width],'YData' ,[1 height]);
else
    trans_image = imtransform(input_image,T);
end
%trans_image = imtransform(input_image,T);
end

