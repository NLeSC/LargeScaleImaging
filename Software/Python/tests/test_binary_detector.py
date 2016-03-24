# -*- coding: utf-8 -*-
"""
Created on Mon Mar 14 13:10:40 2016

@author: dafne
"""
from .context import salientregions as sr
import unittest
import cv2
import os
import scipy.io as sio

class BinaryDetectorTester(unittest.TestCase):
    '''
    Tests for the binary detector
    '''
    
    def setUp(self):
        testdata_path = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../TestData/Binary/'))
        self.image = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_all_types_noise.png')), threshold=128, visualize=False)
        self.holes_true, self.islands_true, self.indents_true,  self.prots_true = \
            sr.read_matfile(os.path.join(testdata_path, 'Binary_all_types_noise_binregions.mat'), visualize=False)
        self.filled_image_true = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_all_types_noise_filled.png')), threshold=128, visualize=False)                
        self.SE = sio.loadmat(os.path.join(testdata_path,"SE_neighb_all_other.mat"))['SE_n']
        self.lam = 50
        self.area_factor = 0.05
            
    def test_holes(self):
        _, holes_my = sr.get_holes(self.image, filled=None, lam=self.lam, 
                                   connectivity=4, visualize=False)
        assert sr.image_diff(self.holes_true, holes_my, visualize=False)
        
    def test_islands(self):
        _, islands_my = sr.get_islands(self.image,  invfilled=None, lam=self.lam, 
                                       connectivity=4, visualize=False)
        assert sr.image_diff(self.islands_true, islands_my, visualize=False)
        
    def test_protrusions(self):
        _, prots_my = sr.get_protrusions(self.image, filled=None, holes=None, 
                                         SE=self.SE, lam=self.lam, 
                                         area_factor=self.area_factor, 
                                         connectivity=4, visualize=False)
        assert sr.image_diff(self.prots_true, prots_my, visualize=False)
        
    def test_indentations(self):
        _, indents_my = sr.get_indentations(self.image, invfilled=None, islands=None, 
                                            SE=self.SE, lam=self.lam,
                                            area_factor=self.area_factor, 
                                            connectivity=4, visualize=False)
        assert sr.image_diff(self.indents_true, indents_my, visualize=False)
        
    def test_fill_image(self):
        filled = sr.fill_image(self.image, visualize=False)
        assert sr.image_diff(self.filled_image_true, filled, visualize= False)