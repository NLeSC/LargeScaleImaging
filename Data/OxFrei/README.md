# OxFrei dataset
--------------------

PURPOSE 
--------------------
Affine region detectors evaluation.

TERMS OF USE
-------------------
The dataset is only provided for research purposes and without any warranty. 
If you use this you should cite:
Ranguelova, E., "A Salient Region Detector for Structured Images", Proceedings AICCSA 2016, pp.1-8

SOURCES
--------------------
The base images for the data sequences have been taken form the 'Freiburg dataset':
URL (accessed January 2016): http://lmb.informatik.uni-freiburg.de/resources/datasets/genmatch.en.html 
Paper: P.Fischer, A. Dosovitskiy, T. Brox, "Descriptor Matching with Convolutional Neural Networks: a Comparison to SIFT",on arXiv(1405.5769), May 2014.
Also the sequence names have been preserved except from the starting index.

The homographies for the 4 transformations ('blur','lighting','scale','viewpoint') are taken from the following sequences as provided by the 'Oxford dataset':
'graffiti' -> 'viewpoint'
'boat' -> 'scale (rotation + zoom)'
'bikes' -> 'blur'
'leuven' -> 'lighting'
URL (accessed January 2016): http://www.robots.ox.ac.uk/~vgg/research/affine/ 
Paper: K. Mikolajczyk, T. Tuytelaars, C. Schmid, A. Zisserman, J. Matas, F. Schaffalitzky, T. Kadir and L. Van Gool, 
"A comparison of affine region detectors." In IJCV 65(1/2):43-72, 2005.
Available in the 'homographies' subfolder in MAT files (MATLAB matricies). The parameters for the 'lighting' and 'blur' are given inside the generation code.

DATA
--------------------
Each of the 9 subfolders contains 4 image sequences of 6 images each: 1 base and 5 transformed images in both JPG and PPM formats (in separate folders):
'01_graffiti'
'02_freiburg_center'
'03_freiburg_from_munster_crop'
'04_freiburg_innenstadt'
'05_cool_car'
'06_freiburg_munster'
'07_graffiti'
'08_hall'
'09_small_palace'

Each base image is called '_original.<ext>' and each transformed image is called with the name of the corresponding transformation
'<trans><#>.<ext>', where <trans> is one of 'blur','lighting','scale','viewpoint',
<#> can be a number of 1 to 5, from small to big transformaiton magnitude and <ext> can be 'jpg' or 'ppm'.

CODE
--------------------
The MATLAB code, used for the generation of this dataset is availabe inthe same git repository under
Software/MATLAB/AffineRegions/DataGeneration/OxFrei
The evaluation of detectors usinf this dataset follows the protocol given with the 'Oxford dataset'. 
Examples of such evaluation can be found in 
Software/MATLAB/AfineRegions/Detectors/Testing

URL
--------------------
This dataset is availabe in the following git repository:
https://github.com/NLeSC/LargeScaleImaging/edit/master/Data/OxFrei

CONTACT
-------------------
Dr. Elena Ranguelova
Netherlands eScience Center
Amsterdam, The Netherlands
https://www.esciencecenter.nl/profile/dr.-elena-ranguelova
e.ranguelova@esciencecenter.nl
