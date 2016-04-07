# -*- coding: utf-8 -*-
import cv2
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
import math


def show_image(img, window_name='image'):
    '''
    Display the image.
    When a key is pressed, the window is closed

    Parameters:
    ------
    img: multidimensional numpy array
        image
    window_name: str, optional
        name of the window
    '''
    fig = plt.figure()
    plt.axis("off")
    if len(img.shape) == 3:
        plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    else:
        plt.imshow(cv2.cvtColor(img, cv2.COLOR_GRAY2RGB))
    fig.canvas.set_window_title(window_name)
    plt.gcf().canvas.mpl_connect('key_press_event',
                                 lambda event: plt.close(event.canvas.figure))
    plt.show()


def visualize_elements(img,
                       holes=None, islands=None,
                       indentations=None, protrusions=None,
                       visualize=True,
                       display_name='salient regions'):
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



    Returns:
    ------
    img_to_show: 3-dimensional numpy array
        image with the colored regions
    '''
    # colormap bgr
    colormap = {'holes': [255, 0, 0],  # BLUE
                'islands': [0, 255, 255],  # YELLOW
                'indentations': [0, 255, 0],  # GREEN
                'protrusions': [0, 0, 255]  # RED
                }

    # if the image is grayscale, make it BGR:
    if len(img.shape) == 2:
        img_to_show = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    else:
        img_to_show = img.copy()
    if holes is not None:
        img_to_show[[holes > 0]] = colormap['holes']
    if islands is not None:
        img_to_show[[islands > 0]] = colormap['islands']
    if indentations is not None:
        img_to_show[[indentations > 0]] = colormap['indentations']
    if protrusions is not None:
        img_to_show[[protrusions > 0]] = colormap['protrusions']

    if visualize:
        show_image(img_to_show, window_name=display_name)
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
        _, binarized = cv2.threshold(
            img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    else:
        _, binarized = cv2.threshold(img, threshold, 255, cv2.THRESH_BINARY)

    # If the image still has three channels, only pick one
    if len(binarized.shape) > 2:
        binarized = binarized[:, :, 0]
    if visualize:
        show_image(
            binarized, window_name=(
                'Binarized with threshold %i' %
                threshold))
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
    regions = matfile['saliency_masks'] * 255
    holes = regions[:, :, 0]
    islands = regions[:, :, 1]
    indentations = regions[:, :, 2]
    protrusions = regions[:, :, 3]
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
        second image to compare
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


def array_diff(arr1, arr2, rtol=1e-05, atol=1e-08):
    '''
    Compares two arrays. Useful for testing purposes.

    Parameters:
    ------
    arr1: 2-dimensional numpy, first array to compare
    arr2: 2-dimensional numpy, second array to compare

    Returns:
    ------
    is_close: bool
        True if elemetns of the two arrays are close within the defaults tolerance
        (see numpy.allclose documentaiton for tolerance values)
    '''
    return np.allclose(arr1, arr2, rtol, atol)


def data_driven_binarization(img,
                             area_factor_large=0.001,
                             area_factor_verylarge=0.1,
                             lam=-1, SE_size_factor=0.15,
                             weights=(0.33, 0.33, 0.33),
                             offset=80,
                             num_levels=256, otsu_only=False,
                             connectivity=4, visualize=True):
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
        weights for number of CC, number of large CC
        and number of very large CC respectively.
    offset: int, optional
        The offset (number of gray levels) to search for around the Otsu level
    num_levels: int, optional
        number of gray levels to be considered [1..255],
        the default number 256 gives a stepsize of 1.
    otsu_only: bool, optional
        Option to only perform otsu binarization
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
    t_otsu, binarized_otsu = cv2.threshold(img, 0, 255,
                                           cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    t_otsu = int(t_otsu)
    if otsu_only:
        return t_otsu, binarized_otsu
    area = img.size
    if lam == -1:
        _, lam = get_SE(img)
    area_large = area_factor_large * area
    area_verylarge = area_factor_verylarge * area

    # Initialize the count arrays
    a_nccs = np.zeros(256)
    a_nccs_large = np.zeros(256)
    a_nccs_verylarge = np.zeros(256)

    step = 256 / num_levels
    for t in xrange(max(t_otsu - offset, 0), min(t_otsu + offset, 255), step):
        bint = binarize(img, threshold=t, visualize=False)
        nccs, labels, stats, centroids = cv2.connectedComponentsWithStats(
            bint, connectivity=connectivity)
        areas = stats[:, cv2.CC_STAT_AREA]
        a_nccs[t] = sum(areas > lam)
        a_nccs_large[t] = sum(areas > area_large)
        a_nccs_verylarge[t] = sum(areas > area_verylarge)

    # Normalize
    a_nccs = a_nccs / float(a_nccs.max())
    a_nccs_large = a_nccs_large / float(a_nccs_large.max())
    a_nccs_verylarge = a_nccs_verylarge / float(a_nccs_verylarge.max())
    scores = weights[0] * a_nccs + \
        weights[1] * a_nccs_large + \
        weights[2] * a_nccs_verylarge
    t_opt = scores.argmax()
    binarized = binarize(img, threshold=t_opt, visualize=visualize)
    if visualize:
        fig = plt.figure()
        fig.canvas.set_window_title('Number of CCs per threshold level')
        plt.plot(scores)
        plt.axvline(x=t_opt, color='red')
        plt.axvline(x=t_otsu, color='green')
        plt.xlim(0, 255)
        plt.gcf().canvas.mpl_connect(
            'key_press_event',
            lambda event: plt.close(
                event.canvas.figure))
        plt.show()
    return t_opt, binarized


def region2ellipse(half_major_axis, half_minor_axis, theta):
    ''' Conversion of elliptic parameters to polynomial coefficients.

    Parameters:
    ------
    half_major_axis: float
        Half of the length of the ellipse's major axis
    half_minor_axis: float
        Half of the length of the ellipse's minor axis
    theta: float
        The ellipse orientation angle (radians) between the major and the x axis

    Returns:
    ------
    A, B, C: floats
        The coefficients of the polynomial equation of an ellipse Ax^2 + Bxy + Cy^2 = 1
    '''

    # trigonometric functions
    sin_theta = np.sin(theta)
    cos_theta = np.cos(theta)
    sin_cos_theta = sin_theta * cos_theta

    # squares
    a_sq = half_major_axis * half_major_axis
    b_sq = half_minor_axis * half_minor_axis
    sin_theta_sq = sin_theta * sin_theta
    cos_theta_sq = cos_theta * cos_theta

    # common denominator
    denom = a_sq * b_sq

    # polynomial coefficients
    A = (b_sq * cos_theta_sq + a_sq * sin_theta_sq) / denom
    B = ((b_sq - a_sq) * sin_cos_theta) / denom
    C = (b_sq * sin_theta_sq + a_sq * cos_theta_sq) / denom

    return A, B, C


def binary_mask2ellipse_features(binary_mask, connectivity=4, saliency_type=1):
    ''' Conversion of binary regions to ellipse features.

    Parameters:
    ------
    binary_mask: 2-D numpy array
        Binary mask of the detected salient regions of the given saliency type
    connectivity: int
        Neighborhood connectivity
    saliency_type: int
        Type of salient regions. The code  is:
        1: holes
        2: islands
        3: indentaitons
        4: protrusions

    Returns:
    ------
    num_regions: int
        The number of saleint regions of saliency_type
    features: 2-D numpy array with he equivalnet ellipse features
        Every row corresponds to a single region/ellipse ans is of format
        x0 y0 A B C saliency_type ,
        where (x0,y0) are the coordinates of the ellipse centroid and A, B and C
        are the polynomial coefficients from the ellipse equation Ax^2 + Bxy + Cy^2 = 1
    '''

    #num_regions, labels, stats, centroids = cv2.connectedComponentsWithStats(binary_mask, connectivity=connectivity)
    _, contours, _ = cv2.findContours(
        binary_mask, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_SIMPLE)

    num_regions = len(contours)
    features = np.zeros((num_regions, 6), float)
    index_regions = 0

    for cnt in contours:

        index_regions = index_regions + 1

        # fit an ellipse to the contour
        (x, y), (MA, ma), angle = cv2.fitEllipse(cnt)
       # print "x,y: ", x, y
        # ellipse parameters
        a = np.fix(MA / 2)
        b = np.fix(ma / 2)

        if ((a > 0) and (b > 0)):
            x0 = x
            y0 = y
            if (angle == 0):
                angle = 180
            angle_rad = angle * math.pi / 180

            # compute the elliptic polynomial coefficients, aka features
            [A, B, C] = region2ellipse(a, b, -angle_rad)
            features[index_regions - 1, ] = ([x0, y0, A, B, C, saliency_type])
        else:
            features[index_regions - 1,
                     ] = ([np.nan,
                           np.nan,
                           np.nan,
                           np.nan,
                           np.nan,
                           saliency_type])

    return num_regions, features
