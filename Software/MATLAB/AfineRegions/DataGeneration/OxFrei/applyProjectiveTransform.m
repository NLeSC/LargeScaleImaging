function [ trans_image ] = applyProjectiveTransform( input_image, H)
% applyProjectiveTransform- apply a projective transform spesified by 
% the homography H

% transpose the homography matrix sonce rows, cols in MATLAB are swapped
% (x,y)
Ht = transpose(H);

% image size
[height, width, ndims]  = size(input_image);

% make the affine transformation
Tt = maketform('projective',Ht);

% transform the image
trans_image = imtransform(input_image,Tt,'XData' ,[1 width],'YData' ,[1 height]);

end

