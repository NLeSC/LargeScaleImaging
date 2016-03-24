# -*- coding: utf-8 -*-
import cv2
import helpers
import binarydetector
import numpy as np

def get_salient_regions_gray(img,  find_holes=True, find_islands=True, 
                       find_indentations=True, find_protrusions=True, 
                        SE_size_factor=0.15, area_factor=0.05, connectivity=4, 
                        visualize=True):
    '''
    Find salient regions of all four types
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values between 0 and 255
        grayscale image to detect regions
    find_holes: bool, optional
        Whether to detect regions of type hole
    find_islands: bool, optional
        Whether to detect regions of type island
    find_indentations: bool, optional
        Whether to detect regions of type indentation
    find_protrusions: bool, optional
        Whether to detect regions of type protrusion
    SE_size_factor: float, optional
        The fraction of the image size that the structuring element should be
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    visualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------ 
    dictiornary with the following possible items:
    holes: 2-dimensional numpy array with values 0/255
        Image with all holes as foreground.
    islands: 2-dimensional numpy array with values 0/255
        Image with all islands as foreground.
    indentations: 2-dimensional numpy array with values 0/255
        Image with all indentations as foreground.
    protrusions: 2-dimensional numpy array with values 0/255
        Image with all protrusions as foreground.
    '''
    
    #Binarize image
    binarized = helpers.binarize(img, visualize=visualize)
    result = binarydetector.get_salient_regions(binarized, find_holes, find_islands, 
                       find_indentations, find_protrusions, SE_size_factor, 
                       area_factor, connectivity, visualize)
    return result
    
def get_salient_regions_color(img,  find_holes=True, find_islands=True, 
                       find_indentations=True, find_protrusions=True, 
                        SE_size_factor=0.15, area_factor=0.05, connectivity=4, 
                        visualize=True):
    '''
    Find salient regions of all four types
    
    Parameters:
    ------
    img: 3-dimensional numpy array with values between 0 and 255
        image to detect regions
    find_holes: bool, optional
        Whether to detect regions of type hole
    find_islands: bool, optional
        Whether to detect regions of type island
    find_indentations: bool, optional
        Whether to detect regions of type indentation
    find_protrusions: bool, optional
        Whether to detect regions of type protrusion
    SE_size_factor: float, optional
        The fraction of the image size that the structuring element should be
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    visualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------ 
    dictiornary with the following possible items:
    holes: 2-dimensional numpy array with values 0/255
        Image with all holes as foreground.
    islands: 2-dimensional numpy array with values 0/255
        Image with all islands as foreground.
    indentations: 2-dimensional numpy array with values 0/255
        Image with all indentations as foreground.
    protrusions: 2-dimensional numpy array with values 0/255
        Image with all protrusions as foreground.
    '''
    
    #Make grayscale image
    grayscale = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    return get_salient_regions_gray(grayscale,  find_holes=find_holes, find_islands=find_islands, 
                       find_indentations=find_indentations, find_protrusions=find_protrusions, 
                        SE_size_factor=SE_size_factor, area_factor=area_factor, 
                        connectivity=connectivity, visualize=visualize)

    
    
def data_driven_binarization(img, area_factor_large=0.001, area_factor_verylarge=0.1, lam=-1, weights=(0.33,0.33,0.33), connectivity=4, visualize=True):
    '''
    Binarize the image such that the desired number of (large) connected 
    components is maximized.
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values between 0 and 255
        grayscale image to binarize
    area_factor_large: float, optional
        factor that describes the minimum area of a large CC
    area_factor_verylarge: float, optional
        factor that describes the minimum area of a very large CC
    lam: float, optional
        lambda, minimumm area of a connected component
    weights: (float, float, float)
        weights for number of CC, number of large CC and number of very large CC
        respectively.
    connectivity: int
        What connectivity to use to define CCs
    visualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------ 
    t_opt: int
        optimal threshold
    binarized: 2-dimensional numpy array with values 0/255
        The binarized image
    '''
    area = img.size
    if lam == -1:
        _, lam = helpers.get_SE(img) 
    area_large = area_factor_large*area
    area_verylarge = area_factor_verylarge*area
    
    if visualize:
        print 'lambda is: %i' % lam
        print 'Area large is: %i' % area_large
        print 'Area very large is: %i' % area_verylarge
    
    #Initialize the
    a_nccs = np.zeros(256)
    a_nccs_large = np.zeros(256)
    a_nccs_verylarge = np.zeros(256)
    for t in xrange(256) :
        bint = helpers.binarize(img, threshold=t, visualize=False)
        nccs, labels, stats, centroids = cv2.connectedComponentsWithStats(bint, connectivity=connectivity)
        areas = stats[:, cv2.CC_STAT_AREA]
        a_nccs[t] = sum(areas > lam)
        a_nccs_large[t] = sum(areas > area_large)
        a_nccs_verylarge[t] = sum(areas > area_verylarge)

    #Normalize
    a_nccs = a_nccs/float(a_nccs.max())
    a_nccs_large = a_nccs_large/float(a_nccs_large.max())
    a_nccs_verylarge = a_nccs_verylarge/float(a_nccs_verylarge.max())
    scores = weights[0]*a_nccs + weights[1]*a_nccs_large + weights[2]*a_nccs_verylarge
    t_opt = scores.argmax()
    binarized = helpers.binarize(img, threshold=t_opt, visualize=visualize)
    return t_opt, binarized
