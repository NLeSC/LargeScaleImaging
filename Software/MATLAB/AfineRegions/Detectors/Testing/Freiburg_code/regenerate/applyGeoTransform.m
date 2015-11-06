function [ trans_image ] = applyGeoTransform( input_image, H)
% applyGeoTransform- apply a geometric transform spesified by 
% the homography H

% transpose the homography matrix sonce rows, cols in MATLAB are swapped
% (x,y)
Ht = transpose(H);

% image size
[height, width, ndims]  = size(input_image);

% make the affine transformation
Tt = maketform('affine',Ht);

% transform the image
trans_image = imtransform(input_image,Tt,'XData' ,[1 width],'YData' ,[1 height]);

end

