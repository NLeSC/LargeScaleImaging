# -*- coding: utf-8 -*-
import cv2
import helpers
import binarydetector
import numpy as np
import binarization


def get_salient_regions(img,
                        find_holes=True, find_islands=True,
                        find_indentations=True, find_protrusions=True,
                        SE_size_factor=0.15, area_factor=0.05,
                        connectivity=4,
                        binarizer=None,
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
    binarizer: Binerizer object, optional
        Binerizer object that handles the binarization.
        By default, we use datadriven binarization
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
    # Convert to grayscale if the image has 3 channels
    if len(img.shape) == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    SE, lam = helpers.get_SE(img, SE_size_factor=SE_size_factor)
    # The default binarizer is the Data Driven binarizer
    if binarizer is None:
        binarizer = binarization.DatadrivenBinarizer(lam=lam,
                                                     connectivity=connectivity)
    # Binarize the image
    binarized = binarizer.binarize(img, visualize)
    
    # Find regions in the binary image
    result = binarydetector.get_salient_regions_binary(binarized,
                                                       find_holes,
                                                       find_islands,
                                                       find_indentations,
                                                       find_protrusions,
                                                       SE_size_factor,
                                                       area_factor,
                                                       connectivity,
                                                       visualize)
    return result