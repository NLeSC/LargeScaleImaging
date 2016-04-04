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


def get_salient_regions_MSSR(img,
                             find_holes=True, find_islands=True,
                             find_indentations=True, find_protrusions=True,
                             SE_size_factor=0.15, area_factor=0.05,
                             connectivity=4,
                             binarizer=None,
                             perc=0.7,
                             min_thres=0,
                             max_thres=255,
                             step=1,
                             visualize=True):
    '''
    Find salient regions of all four types using MSSR.
    This is considerably slower then the DMSR-type detector,
    because it will perform detection for a range of threshold values.

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
    perc: float, optional
        The percentile at which the threshold for the final regions is taken
    min_thres: int, optional
        Minimum threshold level
    max_thres: int, optional
        Maximum threshold level
    step: int, optional
        stepsize for looping through threshold levels
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

    result = {}
    if find_holes:
        result['holes'] = np.zeros(img.shape, dtype='uint8')
    if find_islands:
        result['islands'] = np.zeros(img.shape, dtype='uint8')
    if find_indentations:
        result['indentations'] = np.zeros(img.shape, dtype='uint8')
    if find_protrusions:
        result['protrusions'] = np.zeros(img.shape, dtype='uint8')

    # Remember image from previous theshold
    previmg = np.zeros_like(img, dtype='uint8')
    regions = {}
    for t in xrange(min_thres, max_thres, step):
        _, bint = cv2.threshold(img, t, 255, cv2.THRESH_BINARY)
        # Only search for regions if the thresholded image is not different:
        if not helpers.image_diff(bint, previmg, visualize=False):
            regions = binarydetector.get_salient_regions_binary(
                bint,
                find_holes,
                find_islands,
                find_indentations,
                find_protrusions,
                SE_size_factor,
                area_factor,
                connectivity,
                visualize=False)
        for regtype in regions.keys():
            result[regtype] += np.array(1 *
                                        (regions[regtype] > 0), dtype='uint8')
        previmg = bint

    for regtype in result.keys():
        if visualize:
            helpers.show_image(
                result[regtype],
                regtype + " before thresholding")
        result[regtype] = threshold_cumsum(result[regtype], perc=perc)
        if visualize:
            helpers.show_image(
                result[regtype],
                regtype + " after thresholding")

    return result


def threshold_cumsum(data, perc=0.7, maxvalue=255):
    '''
    Thresholds an image based on a percentile of the non-zero pixel values.

    Parameters:
    ------
    data: 2-dimensional numpy array
        the image to threshold
    perc: float, optional
        The percentile at which the threshold is taken
    maxvalue: int, optional
        The value that the thresholded pixels are set to

    Returns:
    ------
    binarized: 2-dimensional numpy array
        Thresholded image
    '''
    data_values = data[data > 0]
    thres = np.percentile(data_values, int(perc * 100))
    _, binarized = cv2.threshold(data, thres, maxvalue, cv2.THRESH_BINARY)
    return binarized
