# -*- coding: utf-8 -*-
import cv2
import numpy as np
import scipy.io as sio

def show_image(img, window_name='image'):
    '''
    Display the image for 10 seconds.
    When a key is pressed, the window is closed
    
    Parameters:
    ------
    img: multidimensional numpy array
        image
    window_name: str, optional
        name of the window
    '''
    cv2.namedWindow(window_name)
    cv2.startWindowThread()
    cv2.imshow(window_name, img)
    cv2.waitKey(10000)
    cv2.destroyAllWindows()
    

def binarize(img, threshold=127, vizualize=True):
    '''
    Binarize the image according to a given threshold.
    Returns a one-channel image with only values of 0 and 255.
    
    Parameters:
    ------
    img: 3-dimensional numpy array
        image to fill
    threshold: int, optional
        threshold value
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    binzarized:  2-dimensional numpy array with values 0/255
        The binarized image
    '''
    ret, binarized = cv2.threshold(img, threshold, 255, cv2.THRESH_BINARY)
    binarized = binarized[:,:,0]
    if vizualize:
        show_image(binarized)
    return binarized
    

def read_matfile(filename, vizualize=True):
    '''
    Read a matfile with the binary masks for the salient regions.
    Returns:
        islands, holes, protrusions, indentations
    These are masks with 0/255 values for the 4 salient types
    
    Parameters:
    ------
    filename: str
        Path to the mat file
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    holes:  2-dimensional numpy array with values 0/255
        Binary image with holes as foreground
    islands:  2-dimensional numpy array with values 0/255
        Binary image with islands as foreground
    protrusions:  2-dimensional numpy array with values 0/255
        Binary image with protrusions as foreground
    indentations:  2-dimensional numpy array with values 0/255
        Binary image with indentations as foreground
    '''
    matfile = sio.loadmat(filename)
    regions = matfile['saliency_masks']*255
    holes = regions[:,:,0]
    islands = regions[:,:,1]
    indentations = regions[:,:,2]
    protrusions = regions[:,:,3]
    if vizualize:
        show_image(holes, 'holes')
        show_image(islands, 'islands')     
        show_image(indentations, 'indentations')
        show_image(protrusions, 'protrusions')   
    return holes, islands, indentations, protrusions
    
    
    
def image_diff(img1, img2, vizualize=True):
    '''
    Compares two images and shows the difference.
    Useful for testing purposes.
    
    Parameters:
    ------
    img1: 2-dimensional numpy array with values 0/255
        first image to compare
    img1: 2-dimensional numpy array with values 0/255
        second image to comparen
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    is_same: bool
        True if all pixels of the two images are equal
    '''
    if vizualize:
        show_image(cv2.bitwise_xor(img1, img2), 'difference')
    return np.all(img1 == img2)
    
    
def get_SE(img, SE_size_factor=0.15):
    '''
    Get the structuring element en minimum salient region area for this image.
    
    Parameters:
    ------
    img: 2-dimensionalnumpyarray with values 0/255
        image to detect islands
    SE_size_factor: float, optional
        The fraction of the image size that the SE should be
    
    Returns:
    ------
    SE: 2-dimensional numpy array of shape (k,k)
        The structuring element to use in processing the image
    lam: float
        lambda, minimumm area of a salient region
    '''
    nrows, ncols = img.shape
    ROI_area = nrows*ncols
    SE_size = int(SE_size_factor*np.sqrt(ROI_area/np.pi))
    SE = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (SE_size, SE_size))
    lam = 5*SE_size
    return SE, lam
