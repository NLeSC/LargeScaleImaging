# -*- coding: utf-8 -*-
"""
Created on Wed Mar 23 16:10:57 2016

@author: elena
"""
from .context import salientregions as sr
import unittest
import cv2
import numpy as np
import os

class HelpersImageTester(unittest.TestCase):
    '''
    Tests for the helper functions related to images
    '''

    def setUp(self):
        testdata_path = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../TestData/Gray/'))
        self.image = cv2.imread(os.path.join(testdata_path, 'Gray_scale.png'))
        self.binarized_true_175 = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binarized_thresh175.png')), threshold=128, visualize=False)
        self.threshold175 = 175
        self.binarized_true_57 = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binarized_thresh57.png')), threshold=128, visualize=False)
        self.threshold57 = 57
        self.binarized_true_0 = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binarized_thresh0.png')), threshold=128, visualize=False)
        self.threshold0 = 0
        self.binarized_true_255 = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binarized_thresh255.png')), threshold=128, visualize=False)
        self.threshold255 = 255

    def test_binarize175(self):
        binarized = sr.binarize(self.image, self.threshold175, visualize=False)
        assert sr.image_diff(self.binarized_true_175, binarized, visualize=False)

    def test_binarize57(self):
        binarized = sr.binarize(self.image, self.threshold57, visualize=False)
        assert sr.image_diff(self.binarized_true_57, binarized, visualize=False)

    def test_binarize0(self):
        binarized = sr.binarize(self.image, self.threshold0, visualize=False)
        assert sr.image_diff(self.binarized_true_0, binarized, visualize=False)

    def test_binarize255(self):
        binarized = sr.binarize(self.image, self.threshold255, visualize=False)
        assert sr.image_diff(self.binarized_true_255, binarized, visualize=False)


class HelpersSETester(unittest.TestCase):
    '''
    Test for functions related to the SE
    '''
    def setUp(self):
        self.SE_true = np.array([[0, 0, 1, 0, 0],
                                [1, 1, 1, 1, 1],
                                [1, 1, 1, 1, 1],
                                [1, 1, 1, 1, 1],
                                [0, 0, 1, 0, 0]],
                                dtype='uint8')
        self.lam_true = 15
        self.SE_size_factor = 0.05
        self.lam_factor = 5
        self.img = np.zeros((100,110), dtype='uint8')
        
    def test_getSE(self):
        SE, lam = sr.get_SE(self.img, 
                            SE_size_factor=self.SE_size_factor, 
                            lam_factor=self.lam_factor)
        assert np.all(SE == self.SE_true)
        
    def test_getlam(self):
        SE, lam = sr.get_SE(self.img, 
                            SE_size_factor=self.SE_size_factor, 
                            lam_factor=self.lam_factor)
        assert lam == self.lam_true
        

class HelpersArrayTester(unittest.TestCase):
    '''
    Tests for the helper functions related to arrays
    '''

    def setUp(self):
        self.major_axis_len = 15
        self.minor_axis_len = 9
        self.theta = 0.52
        self.coeff = [0.006395179230685, -0.003407029045900, 0.010394944226105]


    def test_region2ellipse(self):
        A, B, C = sr.helpers.region2ellipse(self.major_axis_len, self.minor_axis_len, self.theta)
        coeff = [A,B,C]
        assert sr.helpers.array_diff(self.coeff,coeff)