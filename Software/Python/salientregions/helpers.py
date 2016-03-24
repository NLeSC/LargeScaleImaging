# -*- coding: utf-8 -*-
import cv2
import numpy as np
import scipy.io as sio

def show_image(img, window_name='image', display_time=10000):
    '''
    Display the image for 10 seconds.
    When a key is pressed, the window is closed
    
    Parameters:
    ------
    img: multidimensional numpy array
        image
    window_name: str, optional
        name of the window
    display_time: int, optional
        time for showing the image (in ms)    
    '''
    cv2.namedWindow(window_name)
    cv2.startWindowThread()
    cv2.imshow(window_name, img)
    cv2.waitKey(display_time)
    cv2.destroyAllWindows()
    
def visualize_elements(img, holes=None, islands=None, indentations=None, protrusions=None, visualize=True, display_name = 'salient regions', display_time=100000):
    '''
    Display the image with the salient regions provided.
    
    Parameters:
    
    img: multidimensional numpy array
        image
    holes:  2-dimensional numpy array with values 0/255, optional
        The holes, to display in blue
    islands:  2-dimensional numpy array with values 0/255, optional
        The islands, to display in yellow
    indentations:  2-dimensional numpy array with values 0/255, optional
        The indentations, to display in green
    protrusions:  2-dimensional numpy array with values 0/255, optional
        The protrusions, to display in red
    visualize:  bool, optional
        vizualizations flag
    display_name: str, optional
        name of the window
   display_time: int, optional
        time for showing the image (in ms)  
        
    display_time: visualization time (in ms)
    
    
    Returns:
    ------
    img_to_show: 3-dimensional numpy array
        image with the colored regions
    '''
    #colormap bgr
    colormap = {'holes': [255,0,0], #BLUE
                'islands': [0,255,255], #YELLOW
                'indentations': [0,255,0], #GREEN
                'protrusions': [0,0,255] #RED
               }
    
    img_to_show = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    if holes is not None:
        img_to_show[[holes>0]] = colormap['holes']
    if islands is not None:
        img_to_show[[islands>0]] = colormap['islands']
    if indentations is not None:
        img_to_show[[indentations>0]] = colormap['indentations']
    if protrusions is not None:
        img_to_show[[protrusions>0]] = colormap['protrusions']
    
    if visualize:
        show_image(img_to_show, window_name=display_name, display_time=display_time)
    return img_to_show

def binarize(img, threshold=-1, visualize=True):
    '''
    Binarize the image according to a given threshold.
    Returns a one-channel image with only values of 0 and 255.
    
    Parameters:
    ------
    img: 3-dimensional numpy array
        image to fill
    threshold: int, optional
        threshold value. If -1 (default), OTSU thresholding is used.
    visualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    binzarized:  2-dimensional numpy array with values 0/255
        The binarized image
    '''
    if threshold == -1:
        _, binarized = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY+cv2.THRESH_OTSU)
    else:
        _, binarized = cv2.threshold(img, threshold, 255, cv2.THRESH_BINARY)
        
    #If the image still has three channels, only pick one
    if len(binarized.shape) > 2:
        binarized = binarized[:,:,0]
    if visualize:
        show_image(binarized)
    return binarized
    

def read_matfile(filename, visualize=True):
    '''
    Read a matfile with the binary masks for the salient regions.
    Returns:
        islands, holes, protrusions, indentations
    These are masks with 0/255 values for the 4 salient types
    
    Parameters:
    ------
    filename: str
        Path to the mat file
    visualize: bool, optional
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
    if visualize:
        show_image(holes, 'holes')
        show_image(islands, 'islands')     
        show_image(indentations, 'indentations')
        show_image(protrusions, 'protrusions')   
    return holes, islands, indentations, protrusions
    
    
    
def image_diff(img1, img2, visualize=True):
    '''
    Compares two images and shows the difference.
    Useful for testing purposes.
    
    Parameters:
    ------
    img1: 2-dimensional numpy array with values 0/255
        first image to compare
    img1: 2-dimensional numpy array with values 0/255
        second image to comparen
    visualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    is_same: bool
        True if all pixels of the two images are equal
    '''
    if visualize:
        show_image(cv2.bitwise_xor(img1, img2), 'difference')
    return np.all(img1 == img2)
    
    
def get_SE(img, SE_size_factor=0.15, lam_factor=5):
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
    SE_dim_size = SE_size * 2 - 1
    SE = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (SE_dim_size, SE_dim_size))
    lam = lam_factor*SE_size
    return SE, lam

def get_SEhi(SE, lam, scaleSE=2, scalelam=10):
    '''
    Get the smaller structuring element from the large structuring element
    
    Parameters:
    ------
    SE: 2-dimensional numpy array of shape (k,k)
        The large structuring element
    scale: int
        scale indicating how much smaller the smal SE should be
    
    Returns:
    ------
    SEhi: 2-dimensional numpy array of shape (k,k)
        The smaller structuring element to use in processing the image
    lam_hi: float
        Minimum area of salient region detected on boundaries of holes/islands
    '''
    SEhi = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (int(SE.shape[0]/scaleSE), int(SE.shape[1]/scaleSE)))
    lamhi = lam/scalelam
    return SEhi, lamhi