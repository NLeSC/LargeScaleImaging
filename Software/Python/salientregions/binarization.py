# -*- coding: utf-8 -*-
from abc import ABCMeta, abstractmethod
import cv2
import helpers
import matplotlib.pyplot as plt
import numpy as np


class Binarizer(object):
    """ Abstract class for objects that can binarize an image.
    """
    @abstractmethod
    def binarize(self, img, visualize=True):
        """ Subclasses should implement this method.
        """
        pass


class ThresholdBinarizer(Binarizer):
    """
    Binarizes the image with a given threshold.
    
    Parameters
    ------
    threshold :  int, optional
        Threshold value
    """

    def __init__(self, threshold=127):
        self.threshold = threshold

    def binarize(self, img, visualize=True):
        """
        Binarizes the image according to the threshold.
    
        Parameters
        ------
        img : numpy array
            grayscale image to be binarized.
        visualize: bool, optional
            Option for vizualizing the process
            
        Returns
        ------
        binarized : numpy array
            Binary image with values 0 and 255
        """
        _, binarized = cv2.threshold(img, self.threshold, 255,
                                     cv2.THRESH_BINARY)
        if len(binarized.shape) > 2:
            binarized = binarized[:, :, 0]
        if visualize:
            helpers.show_image(
                binarized, window_name=(
                    'Binarized with threshold %i' %
                    self.threshold))
        return binarized


class OtsuBinarizer(Binarizer):
    """
    Binarizes the image with the Otsu method.
    """
    def binarize(self, img, visualize=True):
        """
        Binarizes the image with the Otsu method.
    
        Parameters
        ------
        img : numpy array
            grayscale image to be binarized.
        visualize: bool, optional
            Option for vizualizing the process
            
        Returns
        ------
        binarized : numpy array
            Binary image with values 0 and 255
        """
        threshold, binarized = cv2.threshold(
            img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        if len(binarized.shape) > 2:
            binarized = binarized[:, :, 0]
        if visualize:
            helpers.show_image(
                binarized, window_name=(
                    'Binarized with threshold %i' %
                    threshold))
        return binarized


class DatadrivenBinarizer(Binarizer):
    """
    Binarizes the image such that the desired number of (large) connected
    components is maximized.

    Parameters
    ------
    lam: float
        lambda, minimumm area of a connected component
    area_factor_large: float, optional
        factor that describes the minimum area of a large CC
    area_factor_verylarge: float, optional
        factor that describes the minimum area of a very large CC
    weights: (float, float, float)
        weights for number of CC, number of large CC
        and number of very large CC respectively.
    offset: int, optional
        The offset (number of gray levels) to search for around the Otsu level
    num_levels: int, optional
        number of gray levels to be considered [1..255],
        the default number 256 gives a stepsize of 1.
    connectivity: int, optional
        What connectivity to use to define CCs
    """

    def __init__(self,
                 lam,
                 area_factor_large=0.001,
                 area_factor_verylarge=0.1,
                 weights=(0.33, 0.33, 0.33),
                 offset=80,
                 num_levels=256,
                 connectivity=4):
        self.area_factor_large = area_factor_large
        self.area_factor_verylarge = area_factor_verylarge
        self.lam = lam
        self.weights = weights
        self.offset = offset
        self.num_levels = num_levels
        self.connectivity = connectivity

    def binarize_withthreshold(self, img, visualize=True):
        """
        Binarizes the image  such that the desired number of (large) connected
        components is maximized. Also returns the optimal threshold.
    
        Parameters
        ------
        img : numpy array
            grayscale image to be binarized.
        visualize: bool, optional
            Option for vizualizing the process
            
        Returns
        ------
        t_opt : int
            Optimal threshold
        binarized : numpy array
            Binary image with values 0 and 255
        """
        t_otsu, binarized_otsu = cv2.threshold(
            img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        t_otsu = int(t_otsu)
        area = img.size
        area_large = self.area_factor_large * area
        area_verylarge = self.area_factor_verylarge * area

        # Initialize the count arrays
        a_nccs = np.zeros(256)
        a_nccs_large = np.zeros(256)
        a_nccs_verylarge = np.zeros(256)

        step = 256 / self.num_levels
        for t in xrange(max(t_otsu - self.offset, 0),
                        min(t_otsu + self.offset, 255),
                        step):
            _, bint = cv2.threshold(img, t, 255,
                                    cv2.THRESH_BINARY)
            nccs, labels, stats, centroids = cv2.connectedComponentsWithStats(
                bint, connectivity=self.connectivity)
            areas = stats[:, cv2.CC_STAT_AREA]
            a_nccs[t] = sum(areas > self.lam)
            a_nccs_large[t] = sum(areas > area_large)
            a_nccs_verylarge[t] = sum(areas > area_verylarge)

        # Normalize
        a_nccs = a_nccs / float(a_nccs.max())
        a_nccs_large = a_nccs_large / float(a_nccs_large.max())
        a_nccs_verylarge = a_nccs_verylarge / float(a_nccs_verylarge.max())
        scores = self.weights[0] * a_nccs + \
            self.weights[1] * a_nccs_large + \
            self.weights[2] * a_nccs_verylarge
        t_opt = scores.argmax()
        _, binarized = cv2.threshold(img, t_opt, 255,
                                     cv2.THRESH_BINARY)
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
            helpers.show_image(
                binarized, window_name=(
                    'Binarized with threshold %i' %
                    t_opt))
        return t_opt, binarized

    def binarize(self, img, visualize=True):
        """
        Binarizes the image  such that the desired number of (large) connected
        components is maximized.
    
        Parameters
        ------
        img : numpy array
            grayscale image to be binarized.
        visualize: bool, optional
            Option for vizualizing the process
            
        Returns
        ------
        binarized : numpy array
            Binary image with values 0 and 255
        """
        _, binarized = self.binarize_withthreshold(img, visualize)
        return binarized
