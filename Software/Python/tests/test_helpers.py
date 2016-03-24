# -*- coding: utf-8 -*-
"""
Created on Wed Mar 23 16:10:57 2016

@author: elena
"""
from .context import salientregions as sr
import unittest
import cv2
import os

class HelpersTester(unittest.TestCase):
    '''
    Tests for the helper functions
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