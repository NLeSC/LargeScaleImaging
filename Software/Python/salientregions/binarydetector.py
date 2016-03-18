# -*- coding: utf-8 -*-
import cv2
import helpers
import numpy as np

def fill_image(img, vizualize=True):
    '''
    Fills all holes in connected components in the image. 
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to fill
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    filled:  2-dimensional numpy array with values 0/255
        The filled image
    '''
    
    filled = img.copy()
    _, contours, hierarchy = cv2.findContours(filled,cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        #Fill the original image for all the contours
        cv2.drawContours(filled, [cnt], 0, 255, -1)
    
    filled = cv2.bitwise_or(filled, img)        
    if vizualize:
        helpers.show_image(filled, 'filled image')
    
    return filled

def get_holes(img, filled=None, lam=-1, connectivity=4, vizualize=True):
    '''
    Find salient regions of type 'hole'
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect holes
    filled: 2-dimensional numpy array with values 0/255, optional
        precomputed filled image
    lam: float, optional
        lambda, minimumm area of a salient region
    connectivity: int
        What connectivity to use to define CCs
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    filled:  2-dimensional numpy array with values 0/255
        The filled image
    holes: 2-dimensional numpy array with values 0/255
        Image with all holes as foreground.
    '''
    
    if vizualize:
        helpers.show_image(img, 'original')

    #Determine lambda, if necessary
    if lam < 0:
        SE, lam = helpers.get_SE(img)
    #retrieve the filled image
    if filled is None:
        filled = fill_image(img, vizualize)
    #get all the holes (including those that are noise)
    all_the_holes = cv2.bitwise_and(filled, cv2.bitwise_not(img))
    #Substract the noise elements
    theholes = remove_small_elements(all_the_holes, lam=lam, remove_border_elements=True, connectivity=connectivity, vizualize=vizualize)

    if vizualize:
        helpers.show_image(all_the_holes, 'holes with noise')
        helpers.show_image(theholes, 'holes without noise')
    
    return filled, theholes
    
    
def get_islands(img,  invfilled=None, lam=-1, connectivity=4, vizualize=True):
    '''
    Find salient regions of type 'island'
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect islands
    invfilled: 2-dimensional numpy array with values 0/255, optional
        precomputed filled inverse image
    lam: float, optional
        lambda, minimumm area of a salient region
    connectivity: int
        What connectivity to use to define CCs
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
    if invfilled is None:
        invfilled = fill_image(invimg, vizualize=vizualize)
    invfilled, islands = get_holes(invimg, filled=invfilled, lam=lam, connectivity=connectivity, vizualize=vizualize)
    return invfilled, islands
    
    
    

def remove_small_elements(elements, lam, remove_border_elements=True, connectivity=4, vizualize=True):
    '''
    Remove elements (Connected Components) that are smaller then a given threshold
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        binary image with elements
    lam: float, optional
        lambda, minimumm area of a salient region
    remove_border_elements: bool, optional
        Also remove elements that are attached to the border
    connectivity: int
        What connectivity to use to define CCs
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    result: 2-dimensional numpy array with values 0/255
        Image with all elements larger then lam
    '''
    result = elements.copy()
    nr_elements, labels, stats, _ = cv2.connectedComponentsWithStats(elements, connectivity=connectivity)
    
    leftborder = 0
    rightborder = elements.shape[1]
    upperborder = 0
    lowerborder = elements.shape[0]
    for i in xrange(1, nr_elements) :
        area =  stats[i, cv2.CC_STAT_AREA]
        if area < lam:
            result[[labels==i]] = 0
            
        if remove_border_elements:
            xmin = stats[i, cv2.CC_STAT_LEFT]
            xmax = stats[i, cv2.CC_STAT_LEFT] + stats[i, cv2.CC_STAT_WIDTH]
            ymin = stats[i, cv2.CC_STAT_TOP]
            ymax = stats[i, cv2.CC_STAT_TOP] + stats[i, cv2.CC_STAT_HEIGHT]
            if xmin <= leftborder \
                or xmax >= rightborder \
                or ymin <= upperborder \
                or ymax >= lowerborder :
                    result[[labels==i]] = 0
    if vizualize:
        helpers.show_image(result, 'small elements removed')
    return result
    
    
def get_protrusions(img, filled=None, holes=None, SE=None, SEhi=None, lam=-1, area_factor=0.05, connectivity=4, vizualize=True):
    '''
    Find salient regions of type 'protrusion'
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect holes
    filled: 2-dimensional numpy array with values 0/255, optional
        precomputed filled image
    SE: 2-dimensional numpy array of shape (k,k), optional
        precomputed structuring element for the tophat operation
    lam: float, optional
        lambda, minimumm area of a salient region
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    filled:  2-dimensional numpy array with values 0/255
        The filled image
    protrusions: 2-dimensional numpy array with values 0/255
        Image with all protrusions as foreground.
    '''
    if holes is None:
        filled, holes = get_holes(img, filled=filled, lam=lam, connectivity=connectivity, vizualize=False)

    #fill the image, if not yet done
    if filled is None:
        filled = fill_image(img, vizualize)

    #Calculate structuring element, if not yet done
    if SE is None or lam==-1:
        SE2, lam2 = helpers.get_SE(img)
        SE = SE2 if SE is None else SE
        lam = lam2 if lam==-1 else lam
        
    if SEhi is None:
        SEhi = helpers.get_SEhi(SE)
        
    #Calculate minimum area for connected components
    min_area = area_factor * img.size
    
    #initalize protrusion image
    prots = np.zeros(img.shape, dtype='uint8')
    
    #Retrieve all connected components
    nccs, labels, stats, centroids = cv2.connectedComponentsWithStats(filled, connectivity=connectivity)
    for i in xrange(1, nccs) :
        area =  stats[i, cv2.CC_STAT_AREA]
        #For the significant CCs, perform tophat
        if area > min_area:            
            ccimage = np.array(255*(labels==i), dtype='uint8')
            wth = cv2.morphologyEx(ccimage, cv2.MORPH_TOPHAT, SE )
            prots += wth
            if vizualize:
                helpers.show_image(wth, 'Top hat')
    if vizualize:
        helpers.show_image(prots, 'Elements with noise')
        
    #Now get indentations of significant holes
    nccs2, labels2, stats2, centroids2 = cv2.connectedComponentsWithStats(holes, connectivity=connectivity)
    for i in xrange(1, nccs2) :
        area =  stats2[i, cv2.CC_STAT_AREA]
        ccimage = np.array(255*(labels2==i), dtype='uint8')
        ccimage_filled = fill_image(ccimage, vizualize=False)
        #For the significant CCs, perform tophat
        if area > min_area:            
            bth = cv2.morphologyEx(ccimage_filled, cv2.MORPH_BLACKHAT, SEhi )
            prots += bth
            if vizualize:
                helpers.show_image(bth, 'Black Top hat')
    
    prots_nonoise = remove_small_elements(prots, lam, connectivity=8, vizualize=vizualize)
    return filled, prots_nonoise
    
def get_indentations(img,  invfilled=None, islands=None, SE=None, SEhi=None, lam=-1, area_factor=0.05, connectivity=4, vizualize=True):
    '''
    Find salient regions of type 'island'
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect islands
    invfilled: 2-dimensional numpy array with values 0/255, optional
        precomputed filled inverse image
    SE: 2-dimensional numpy array of shape (k,k), optional
        precomputed structuring element for the tophat operation
    lam: float, optional
        lambda, minimumm area of a salient region
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------
    invfilled:  2-dimensional numpy array with values 0/255
        The filled inverse image
    indentations: 2-dimensional numpy array with values 0/255
        Image with all indentations as foreground.
    '''
    invimg = cv2.bitwise_not(img)
    if islands is None:
        invfilled, islands = get_islands(img, invfilled=invfilled, lam=lam, connectivity=connectivity, vizualize=False)
    if invfilled is None:
        invfilled = fill_image(invimg, vizualize=vizualize)
    invfilled, indentations = get_protrusions(invimg, filled=invfilled, holes=islands, 
                                              SE=SE, SEhi=SEhi, lam=lam, area_factor=area_factor, 
                                              connectivity=connectivity, vizualize=vizualize)
    return invfilled, indentations
    
def get_salient_regions(img, SE_size_factor=0.15, area_factor=0.05, connectivity=4, vizualize=True):
    '''
    Find salient regions of all four types
    
    Parameters:
    ------
    img: 2-dimensional numpy array with values 0/255
        image to detect islands
    SE_size_factor: float, optional
        The fraction of the image size that the structuring element should be
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    vizualize: bool, optional
        option for vizualizing the process
    
    Returns:
    ------ 
    holes: 2-dimensional numpy array with values 0/255
        Image with all holes as foreground.
    islands: 2-dimensional numpy array with values 0/255
        Image with all islands as foreground.
    indentations: 2-dimensional numpy array with values 0/255
        Image with all indentations as foreground.
    protrusions: 2-dimensional numpy array with values 0/255
        Image with all protrusions as foreground.
    '''
    # Get structuring elements    
    SE, lam = helpers.get_SE(img, SE_size_factor=0.15)
    SEhi = helpers.get_SEhi(SE)
    
    #Get holes and islands
    filled, holes = get_holes(img, filled=None, lam=lam, connectivity=connectivity, vizualize=vizualize )
    invfilled, islands = get_islands(img,  invfilled=None, lam=lam, connectivity=connectivity, vizualize=vizualize)
    
    #Get indentations and protrusions
    invfilled, indentations = get_indentations(img,  invfilled=invfilled, 
                                               islands=islands, SE=SE, SEhi=SEhi, 
                                               lam=lam, area_factor=area_factor, 
                                               connectivity=connectivity, vizualize=vizualize)
    filled, protrusions = get_protrusions(img, filled=filled, holes=holes, 
                                          SE=SE, SEhi=SEhi, lam=lam, 
                                          area_factor=area_factor, 
                                          connectivity=connectivity, vizualize=vizualize)
    if vizualize:
        helpers.vizualize_elements(img, holes=holes, islands=islands, 
                                   indentations=indentations, protrusions=protrusions)
    return holes, islands, indentations, protrusions