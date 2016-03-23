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
        self.binarized_true = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binarized_thresh128.png')), threshold=128, visualize=False)
        self.threshold = 128
        
        
    def test_binarize(self):
        binarized = sr.binarize(self.image, self.threshold, visualize=False)
        assert sr.image_diff(self.binarized_true, binarized, visualize=False)