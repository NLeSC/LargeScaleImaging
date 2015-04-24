There are five different changes in imaging conditions: 
 viewpoint changes,
scale changes, image blur,
JPEG compression, and illumination.
In the cases of viewpoint change, scale change and blur, the
same change in imaging conditions is applied to two different
scene types. This means that the effect of changing the image conditions
can be separated from the effect of changing the scene type.
One scene type contains homogeneous regions with
distinctive edge boundaries (e.g. graffiti, buildings), 
and the other contains repeated textures of different forms.

In the viewpoint change test the camera varies from a fronto-parallel
view to one with significant foreshortening at approximately 60
degrees to the camera. The scale change and blur sequences are acquired by varying
the camera zoom and focus respectively. The scale changes by about a
factor of four.  The light changes are introduced by varying the camera
aperture.  The JPEG sequence is generated using a standard xv image 
browser with the image quality parameter varying from  40\% to 2\%. 
Each of the test sequences contains  6 images with a gradual
geometric or photometric transformation. All images are of medium resolution
(approximately 800 x 640 pixels).

The images are either of planar scenes or the camera position is fixed
during acquisition, so that in all cases the images are related by
homographies (plane projective transformations). This means that
the mapping relating images is known (or can be computed), and this
mapping is used to determine ground truth matches for the affine
covariant detectors. 

The homographies between the reference image and the other
images in a particular dataset are computed in two steps.  First, a
small number of point correspondences are selected manually between
the reference and other image. These correspondences are used to
compute an approximate homography between the images, and the other
image is warped by this homography so that it is roughly aligned with
the reference image. Second, a standard small-baseline robust
homography estimation algorithm is used to compute an accurate
residual homography between the reference and warped image (using
hundreds of automatically detected and matched interest
points).  The composition of these two homographies
(approximate and residual) gives an accurate homography between the
reference and other image.