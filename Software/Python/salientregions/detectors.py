# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*-
from abc import ABCMeta, abstractmethod
import cv2
import helpers
import binarization
#import binarydetector
import numpy as np
from binarydetector import BinaryDetector

class Detector(object):
    '''
    Abstract class for salient region detectors.
    

    Parameters:
    ------
    SE_size_factor: float, optional
        The fraction of the image size that the structuring element should be
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    
    '''
    
    __metaclass__ = ABCMeta
    
    def __init__(self, SE_size_factor=0.15, 
                      lam_factor = 5,
                      area_factor=0.05, 
                      connectivity=4):
        self.SE_size_factor = SE_size_factor
        self.lam_factor = lam_factor
        self.area_factor = area_factor
        self.connectivity = connectivity

    @abstractmethod
    def detect(self, img, find_holes=True, find_islands=True,
               find_indentations=True, find_protrusions=True,
                       visualize=True):
        '''
        This method should be implemented to return a 
         dictionary with the salientregions.
        Calling this function from the superclass makes sure the 
         structuring elemnt and lamda are created.
        
        '''
        nrows, ncols = self.img_shape[0], self.img_shape[1]
        self.get_SE(nrows*ncols)
    
    def get_SE(self, imgsize):
        '''
        Get the structuring element en minimum salient region area for this image.
        The standard type of binarization is Datadriven (as in DMSR),
        but it is possible to pass a different Binarizer.
    
        Returns:
        ------
        SE: 2-dimensional numpy array of shape (k,k)
            The structuring element to use in processing the image
        lam: float
            lambda, minimumm area of a salient region
        '''
        
        SE_size = int(np.round(self.SE_size_factor * np.sqrt(imgsize / np.pi)))
        SE_dim_size = SE_size * 2 - 1
        self.SE = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,
                                       (SE_dim_size, SE_dim_size))
        self.lam = self.lam_factor * SE_size
        return self.SE, self.lam
    

class SalientDetector(Detector):
    '''
    Find salient regions of all four types, in color or greyscale images.
    The image is first binarized using the specified binarizer, 
    then a binary detector is used.
    
    Parameters
    ------
    binarizer: Binerizer object, optional
        Binerizer object that handles the binarization.
        By default, we use datadriven binarization
    **kwargs
        Other arguments to pass along to the constructor of the superclass Detector
    '''
    def __init__(self, binarizer=None,  **kwargs):
        super(SalientDetector, self).__init__(**kwargs)
        self.gray = None
        self.binarized = None
        if binarizer is None:
            self.binarizer = binarization.DatadrivenBinarizer(lam=self.lam,
                                         connectivity=self.connectivity)          
        else:
            self.binarizer = binarizer
        
    
    def detect(self, img, find_holes=True, find_islands=True, find_indentations=True, find_protrusions=True, visualize=True):
        '''
        Find salient regions of the types specified.
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
        visualize: bool, optional
            option for vizualizing the process
        Returns:
        ------
        dictionary with the following possible items:
        holes: 2-dimensional numpy array with values 0/255
            Image with all holes as foreground.
        islands: 2-dimensional numpy array with values 0/255
            Image with all islands as foreground.
        indentations: 2-dimensional numpy array with values 0/255
            Image with all indentations as foreground.
        protrusions: 2-dimensional numpy array with values 0/255
            Image with all protrusions as foreground.
        '''        
        super(Detector, self).detect(img, find_holes=find_holes, find_islands=find_islands, 
                                     find_indentations=find_indentations, find_protrusions=find_protrusions, 
                                     visualize=visualize)
        if len(img.shape) == 3:
            self.gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        else:
            self.gray = img.copy()
        # The default binarizer is the Data Driven binarizer
        

        # Binarize the image
        self.binarized = self.binarizer.binarize(self.gray, visualize)
    
        # Find regions in the binary image
        bindetector = BinaryDetector(SE=self.SE, lam=self.lam, 
                                     area_factor=self.area_factor,
                                     connectivity=self.connectivity)
        result = bindetector.detect(self.binarized,
                                   find_holes,
                                   find_islands,
                                   find_indentations,
                                   find_protrusions,
                                   visualize)
        return result
    
