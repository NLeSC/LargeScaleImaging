# -*- coding: utf-8 -*-
import cv2
import helpers
import binarydetector
import numpy as np
from enum import IntEnum


class BinarizationMethod(IntEnum):
    datadriven = 0
    otsu = 1
    levels = 2
    threshold = 3


def get_salient_regions(img,
                        find_holes=True, find_islands=True,
                        find_indentations=True, find_protrusions=True,
                        SE_size_factor=0.15, area_factor=0.05,
                        connectivity=4,
                        binarizationmethod=BinarizationMethod.datadriven,
                        threshold=-1,
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
    binarizationmethod: BinarizationMethod (enum)
        Which method to use for binarizing.
    threshold
        Which threshold to use if binarizationmethod is ´levels´
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
    if binarizationmethod == BinarizationMethod.datadriven:
        _, binarized = helpers.data_driven_binarization(img, lam=lam,
                                                        connectivity=connectivity,
                                                        visualize=visualize)
    elif binarizationmethod == BinarizationMethod.otsu:
        _, binarized = helpers.data_driven_binarization(img, lam=lam,
                                                        connectivity=connectivity,
                                                        otsu_only=True,
                                                        visualize=visualize)
    else:
        binarized = helpers.binarize(img,
                                     threshold=threshold, visualize=visualize)

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
