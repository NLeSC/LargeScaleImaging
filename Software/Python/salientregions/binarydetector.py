import cv2
import helpers
import numpy as np


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
        # Get holes and islands
        if find_holes:
            regions['holes'] = self.get_holes()

        # Islands are just holes of the inverse image
        if find_islands:
            regions['islands'] = self.get_islands()

        # Get indentations and protrusions
        if find_indentations:
            regions['indentations'] = self.get_indentations()

        if find_protrusions:
            regions['protrusions'] = self.get_protrusions()

        if visualize:
            helpers.visualize_elements(
                img, holes=regions.get(
                    'holes', None), islands=regions.get(
                    'islands', None), indentations=regions.get(
                    'indentations', None), protrusions=regions.get(
                    'protrusions', None))
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

    def get_holes(self):
        '''
        Get salient regions of type 'hole'
        '''
        if self.holes is None:
            # Fill the image
            self._filled = self.fill_image(self._img)

            # Detect the holes
            self.holes = self.detect_holelike(
                img=self._img, filled=self._filled)
        return self.holes

    def get_islands(self):
        '''
        Get salient regions of type 'island'
        '''
        if self.islands is None:
            # Get the inverse image
            self._invimg = cv2.bitwise_not(self._img)
            # Fill the inverse image
            self._invfilled = self.fill_image(self._invimg)
            self.islands = self.detect_holelike(
                img=self._invimg, filled=self._invfilled)
        return self.islands

    def get_protrusions(self):
        '''
        Get salient regions of type 'protrusion'
        '''
        if self.protrusions is None:
            holes = self.get_holes()
            self.protrusions = self.detect_protrusionlike(
                self._img, self._filled, holes)
        return self.protrusions

    def get_indentations(self):
        '''
        Get salient regions of type 'indentation'
        '''
        if self.indentations is None:
            islands = self.get_islands()
            self.indentations = self.detect_protrusionlike(
                self._invimg, self._invfilled, islands)
        return self.indentations

    def detect_holelike(self, img, filled):
        '''
        Detect hole-like salient regions, using the image and its filled version

        Parameters:
        ------
        img: 2-dimensional numpy array with values 0/255
            image to detect holes
        filled: 2-dimensional numpy array with values 0/255, optional
            precomputed filled image

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
                                              remove_border_elements=True)
        return theholes

    def detect_protrusionlike(self, img, filled, holes):
        '''
        Detect 'protrusion'-like salient regions

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

        prots1_nonoise = self.remove_small_elements(prots1, connectivity=8)

        # Now get indentations of significant holes
        nccs2, labels2, stats2, centroids2 = cv2.connectedComponentsWithStats(
            holes, connectivity=self.connectivity)
        for i in xrange(1, nccs2):
            area = stats2[i, cv2.CC_STAT_AREA]
            ccimage = np.array(255 * (labels2 == i), dtype='uint8')
            ccimage_filled = self.fill_image(ccimage)
            # For the significant CCs, perform tophat
            if area > min_area:
                bth = cv2.morphologyEx(
                    ccimage_filled, cv2.MORPH_BLACKHAT, self.SE)
                prots2 += bth

        prots2_nonoise = self.remove_small_elements(prots2, connectivity=8)

        prots = cv2.add(prots1_nonoise, prots2_nonoise)
        return prots

    def remove_small_elements(
            self,
            elements,
            connectivity=None,
            remove_border_elements=True,
            visualize=False):
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
        if connectivity is None:
            connectivity = self.connectivity
        result = elements.copy()
        nr_elements, labels, stats, _ = cv2.connectedComponentsWithStats(
            elements, connectivity=connectivity)

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

    @staticmethod
    def fill_image(img):
        '''
        Fills all holes in connected components in the image.

        Parameters:
        ------
        img: 2-dimensional numpy array with values 0/255
            image to fill

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

        return filled
