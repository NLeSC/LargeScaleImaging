# -*- coding: utf-8 -*-

# -*- coding: utf-8 -*-
from abc import ABCMeta, abstractmethod
import cv2
import helpers
import binarization
#import binarydetector
import numpy as np

class Detector(object):
     '''
    Abstract class for salient region detectors.
    

    Parameters:
    ------
    img_shape: tuple (of min length 2)
        shape of the image. The size of the image 
    SE_size_factor: float, optional
        The fraction of the image size that the structuring element should be
    area_factor: float, optional
        factor that describes the minimum area of a significent CC
    connectivity: int
        What connectivity to use to define CCs
    
    '''
    
    __metaclass__ = ABCMeta
    
    def __init__(self, img_shape, SE_size_factor=0.15, 
                      lam_factor = 5,
                      area_factor=0.05, 
                      connectivity=4):
        self.img_shape = img_shape
        self.SE_size_factor = SE_size_factor
        self.lam_factor = lam_factor
        self.area_factor = area_factor
        self.connectivity = connectivity
        self.get_SE()

    @abstractmethod
    def detect(self, img, find_holes=True, find_islands=True,
               find_indentations=True, find_protrusions=True,
                       visualize=True):
        pass
    
    def get_SE(self):
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
        nrows, ncols = self.img_shape[0], self.img_shape[1]
        ROI_area = nrows * ncols
        SE_size = int(np.round(self.SE_size_factor * np.sqrt(ROI_area / np.pi)))
        SE_dim_size = SE_size * 2 - 1
        self.SE = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,
                                       (SE_dim_size, SE_dim_size))
        self.lam = self.lam_factor * SE_size
    

class SalientDetector(Detector):
    '''
    Find salient regions of all four types, in color or greyscale images.
    
    Parameters
    ------
    img_shape: tuple (of min length 2)
        shape of the image. The size of the image 
    binarizer: Binerizer object, optional
        Binerizer object that handles the binarization.
        By default, we use datadriven binarization
    **kwargs
        Other arguments to pass along to the constructor of the superclass
    '''
    def __init__(self, img_shape, binarizer=None,  **kwargs):
        super(SalientDetector, self).__init__(img_shape, **kwargs)
        self.gray = None
        self.binarized = None
        if binarizer is None:
            self.binarizer = binarization.DatadrivenBinarizer(lam=self.lam,
                                         connectivity=self.connectivity)          
        else:
            self.binarizer = binarizer
        
    
    def detect(self, img, find_holes=True, find_islands=True, find_indentations=True, find_protrusions=True, visualize=True):
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
    

class BinaryDetector(object):
    
    def __init__(self, SE, lam, area_factor, connectivity):    
        self.SE = SE
        self.lam = lam
        self.area_factor = area_factor
        self.connectivity = connectivity
        self._img = None
        self._invimg = None
        self._filled = None
        self._invfilled = None
        self.holes = None
        self.islands = None
        self.indentations = None
        self.protrusions = None
        
    def detect(self, img, find_holes=True, find_islands=True,
               find_indentations=True, find_protrusions=True, visualize=True):
        regions = {}
        self.reset()
        self._img = img
        #Get holes and islands
        if find_holes or find_protrusions:
            self._filled = self.fill_image(self._img, visualize)
            self.holes = self.get_holes(img=self._img, filled=self._filled, visualize=visualize)
            if find_holes:
                regions['holes'] = self.holes
    
        # Islands are just holes of the inverse image
        if find_islands or find_indentations:
            self._invimg = cv2.bitwise_not(self._img)
            self._invfilled = self.fill_image(self._invimg, visualize=visualize)
            islands = self.get_holes(self._invimg, self._invfilled, visualize=visualize)
            if find_islands:
                regions['islands'] = islands
    
        # Get indentations and protrusions
        if find_indentations:
            self.indentations = self.get_protrusions(self._invimg,
                                                  filled=self._invfilled,
                                                  holes=self.islands,
                                                 visualize=visualize)
            regions['indentations'] = self.indentations
    
        if find_protrusions:
            self.protrusions = self.get_protrusions(self._img,
                                                  filled=self._filled,
                                                  holes=self.holes,
                                                 visualize=visualize)
            regions['protrusions'] = self.protrusions
    
        if visualize:
            helpers.visualize_elements(img,
                                       holes=self.holes,
                                       islands=self.islands,
                                       indentations=self.indentations,
                                       protrusions=self.protrusions)
        return regions
        
    def reset(self):
        self._img = None
        self._invimg = None
        self._filled = None
        self._invfilled = None
        self.holes = None
        self.islands = None
        self.indentations = None
        self.protrusions = None
    
    def get_holes(self, img, filled, visualize=True):
        '''
        Find salient regions of type 'hole'
    
        Parameters:
        ------
        img: 2-dimensional numpy array with values 0/255
            image to detect holes
        filled: 2-dimensional numpy array with values 0/255, optional
            precomputed filled image
        visualize: bool, optional
            option for vizualizing the process
    
        Returns:
        ------
        filled:  2-dimensional numpy array with values 0/255
            The filled image
        holes: 2-dimensional numpy array with values 0/255
            Image with all holes as foreground.
        '''
        
        # Get all the holes (including those that are noise)
        all_the_holes = cv2.bitwise_and(filled, cv2.bitwise_not(img))
        # Substract the noise elements
        theholes = self.remove_small_elements(all_the_holes,
                                         remove_border_elements=True,
                                         visualize=visualize)
    
        if visualize:
            helpers.show_image(all_the_holes, 'holes with noise')
            helpers.show_image(theholes, 'holes without noise')
        return theholes
    
    
    def get_protrusions(self, img, filled, holes, visualize=True):
        '''
        Find salient regions of type 'protrusion'
    
        Parameters:
        ------
        img: 2-dimensional numpy array with values 0/255
            image to detect holes
        filled: 2-dimensional numpy array with values 0/255, optional
            precomputed filled image
        holes: 2-dimensional numpy array with values 0/255
            The earlier detected holes
        visualize: bool, optional
            option for vizualizing the process
    
        Returns:
        ------
        filled:  2-dimensional numpy array with values 0/255
            The filled image
        protrusions: 2-dimensional numpy array with values 0/255
            Image with all protrusions as foreground.
        '''
    
        # Calculate minimum area for connected components
        min_area = self.area_factor * img.size
    
        # Initalize protrusion image
        prots1 = np.zeros(img.shape, dtype='uint8')
        prots2 = np.zeros(img.shape, dtype='uint8')
    
        # Retrieve all connected components
        nccs, labels, stats, centroids = cv2.connectedComponentsWithStats(
            filled, connectivity=self.connectivity)
        for i in xrange(1, nccs):
            area = stats[i, cv2.CC_STAT_AREA]
            # For the significant CCs, perform tophat
            if area > min_area:
                ccimage = np.array(255 * (labels == i), dtype='uint8')
                wth = cv2.morphologyEx(ccimage, cv2.MORPH_TOPHAT, self.SE)
                prots1 += wth
                if visualize:
                    helpers.show_image(wth, 'Top hat')
    
        prots1_nonoise = self.remove_small_elements(prots1, visualize=visualize)
    
        # Now get indentations of significant holes
        nccs2, labels2, stats2, centroids2 = cv2.connectedComponentsWithStats(
            holes, connectivity=self.connectivity)
        for i in xrange(1, nccs2):
            area = stats2[i, cv2.CC_STAT_AREA]
            ccimage = np.array(255 * (labels2 == i), dtype='uint8')
            ccimage_filled = self.fill_image(ccimage, visualize=False)
            # For the significant CCs, perform tophat
            if area > min_area:
                bth = cv2.morphologyEx(ccimage_filled, cv2.MORPH_BLACKHAT, self.SE)
                prots2 += bth
                if visualize:
                    helpers.show_image(bth, 'Black Top hat')
    
        prots2_nonoise = self.remove_small_elements(prots2, connectivity=8,
                                               visualize=visualize)
    
        prots = cv2.add(prots1_nonoise, prots2_nonoise)
        return prots
        
    
    def remove_small_elements(self, elements, connectivity=None, remove_border_elements=True,
                               visualize=True):
        '''
        Remove elements (Connected Components) that are smaller
        then a given threshold
    
        Parameters:
        ------
        img: 2-dimensional numpy array with values 0/255
            binary image with elements
        lam: float, optional
            lambda, minimumm area of a salient region
        remove_border_elements: bool, optional
            Also remove elements that are attached to the border
        visualize: bool, optional
            option for vizualizing the process
    
        Returns:
        ------
        result: 2-dimensional numpy array with values 0/255
            Image with all elements larger then lam
        '''
        if connectivity < 0 :
            connectivity = self.connectivity
        result = elements.copy()
        nr_elements, labels, stats, _ = cv2.connectedComponentsWithStats(
            elements, connectivity=self.connectivity)
    
        leftborder = 0
        rightborder = elements.shape[1]
        upperborder = 0
        lowerborder = elements.shape[0]
        for i in xrange(1, nr_elements):
            area = stats[i, cv2.CC_STAT_AREA]
            if area < self.lam:
                result[[labels == i]] = 0
    
            if remove_border_elements:
                xmin = stats[i, cv2.CC_STAT_LEFT]
                xmax = stats[i, cv2.CC_STAT_LEFT] + stats[i, cv2.CC_STAT_WIDTH]
                ymin = stats[i, cv2.CC_STAT_TOP]
                ymax = stats[i, cv2.CC_STAT_TOP] + stats[i, cv2.CC_STAT_HEIGHT]
                if xmin <= leftborder \
                        or xmax >= rightborder \
                        or ymin <= upperborder \
                        or ymax >= lowerborder:
                    result[[labels == i]] = 0
        if visualize:
            helpers.show_image(result, 'small elements removed')
        return result
    
    

    
    def fill_image(self, img, visualize=False):
        '''
        Fills all holes in connected components in the image.
    
        Parameters:
        ------
        img: 2-dimensional numpy array with values 0/255
            image to fill
        visualize: bool, optional
            option for vizualizing the process
    
        Returns:
        ------
        filled:  2-dimensional numpy array with values 0/255
            The filled image
        '''
    
        filled = img.copy()
        _, contours, hierarchy = cv2.findContours(filled,
                                                  cv2.RETR_CCOMP,
                                                  cv2.CHAIN_APPROX_SIMPLE)
        for cnt in contours:
            # Fill the original image for all the contours
            cv2.drawContours(filled, [cnt], 0, 255, -1)
    
        filled = cv2.bitwise_or(filled, img)
        if visualize:
            helpers.show_image(filled, 'filled image')
    
        return filled