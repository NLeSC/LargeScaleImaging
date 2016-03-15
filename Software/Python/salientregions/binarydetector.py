# -*- coding: utf-8 -*-
import cv2
import helpers
import numpy as np

def fill_image(img, lam=20, vizualize=True):
    '''
    Fills all holes in connected components in the image. Also return the
    small elements.
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to fill
    lam: float, optional
        lambda, minimumm area of a salient region
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    filled:  2-dimensional numpy array with values 0/255
        The filled image
    filled_small: 2-dimensional numpy array with values 0/255
        Image with all small elements as foreground.
    '''
    
    filled = img.copy()
    filled_small = np.zeros(img.shape, dtype='uint8')
    img2, contours, hierarchy = cv2.findContours(filled,cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        #Fill the original image for all the contours
        cv2.drawContours(filled, [cnt], 0, 255, -1)
        #If it's a small contour, draw it to the noise-image
        if cv2.contourArea(cnt) < lam:
            cv2.drawContours(filled_small, [cnt], 0, 255, -1)
            
    if vizualize:
        helpers.show_image(filled, 'filled image')
        helpers.show_image(filled_small, 'filled small elements')
    
    return filled, filled_small
    

def get_holes(img, lam=-1, vizualize=True):
    '''
    Find salient regions of type 'hole'
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect holes
    lam: float, optional
        lambda, minimumm area of a salient region
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    filled:  2-dimensional numpy array with values 0/255
        The filled image
    holes: 2-dimensional numpy array with values 0/255
        Image with all holes as foreground.
    '''
    
    if(vizualize):
        helpers.show_image(img, 'original')

    #Determine lambda, if necessary
    if lam < 0:
        SE, lam = helpers.get_SE(img)
    #retrieve the filled image and the filled small elements
    filled, filled_small = fill_image(img, lam, vizualize)
    #get all the holes (including those that are noise)
    all_the_holes = cv2.bitwise_and(filled, cv2.bitwise_not(img))
    #Substract the noise elements
    theholes = cv2.bitwise_and(all_the_holes, cv2.bitwise_not(filled_small))

    if vizualize:
        helpers.show_image(all_the_holes, 'holes with noise')
        helpers.show_image(theholes, 'holes without noise')
    
    return filled, theholes
    
    
def get_islands(img, lam=20, vizualize=True):
    '''
    Find salient regions of type 'island'
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect islands
    lam: float, optional
        lambda, minimumm area of a salient region
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    invfilled:  2-dimensional numpy array with values 0/255
        The filled inverse image
    holes: 2-dimensional numpy array with values 0/255
        Image with all islands as foreground.
    '''
    invimg = cv2.bitwise_not(img)
    invfilled, islands = get_holes(invimg, lam, vizualize)
    return invfilled, islands
    
    
    

def remove_small_elements(elements, lam, connectivity=4, vizualize=True):
    '''
    Remove elements (Connected Components) that are smaller then a given threshold
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        binary image with elements
    lam: float, optional
        lambda, minimumm area of a salient region
    connectivity: int
        What connectivity to use to define CCs
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    
    '''
    result = elements.copy()
    nr_elements, labels, stats, _ = cv2.connectedComponentsWithStats(elements, connectivity=connectivity)
    for i in xrange(1, nr_elements) :
        area =  stats[i, cv2.CC_STAT_AREA]
        if area < lam:
            result[[labels==i]] = 0
    if vizualize:
        helpers.show_image(result, 'small elements removed')
    return result