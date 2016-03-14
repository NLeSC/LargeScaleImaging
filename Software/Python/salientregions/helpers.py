# -*- coding: utf-8 -*-
import cv2
import numpy as np
import scipy.io as sio

def show_image(img, window_name='image'):
    '''
    Display the image for 10 seconds.
    When a key is pressed, the window is closed
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
    '''
    ret, binarized = cv2.threshold(img, threshold, 255, cv2.THRESH_BINARY)
    binarized = binarized[:,:,0]
    if(vizualize):
        show_image(binarized)
    return binarized
    

def read_matfile(filename, vizualize=True):
    '''
    Read a matfile with the binary masks for the salient regions.
    Returns:
        islands, holes, protrusions, indentations
    These are masks with 0/255 values for the 4 salient types
    '''
    matfile = sio.loadmat(filename)
    regions = matfile['saliency_masks']*255
    islands = regions[:,:,0]
    holes = regions[:,:,1]
    protrusions = regions[:,:,2]
    indentations = regions[:,:,3]
    if(vizualize):
        show_image(holes, 'holes')
        show_image(islands, 'islands')
        show_image(protrusions, 'protrusions')
        show_image(indentations, 'indentations')
    return holes, islands, protrusions, indentations
    
    
def image_diff(img1, img2, vizualize=True):
    '''
    Compares two images and shows the difference.
    Useful for testing purposes.
    '''
    if(vizualize):
        show_image(cv2.bitwise_xor(img1, img2))
    return np.all(img1 == img2)
    
    
def get_SE(img, SE_size_factor=0.02):
    nrows, ncols = img.shape[0], img.shape[1]
    ROI_area = nrows*ncols
    SE_size = SE_size_factor*np.sqrt(ROI_area/np.pi)
    SE = np.ones((SE_size,SE_size))
    lam = 5*SE_size
    return SE, lam