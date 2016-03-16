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
        self.image = sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_all_types_noise.png')), vizualize=False)
        self.holes_true, self.islands_true, self.indents_true,  self.prots_true = \
            sr.read_matfile(os.path.join(testdata_path, 'Binary_all_types_noise_binregions.mat'), vizualize=False)
        self.SE = sio.loadmat(os.path.join(testdata_path,"Binary_all_types_noise_SE.mat"))['SE_n']
            
    def test_holes(self):
        _, holes_my = sr.get_holes(self.image, lam=108, vizualize=False)
        assert sr.image_diff(self.holes_true, holes_my, vizualize=False)
        
    def test_islands(self):
        _, islands_my = sr.get_islands(self.image, lam=108, vizualize=False)
        assert sr.image_diff(self.islands_true, islands_my, vizualize=False)
        
    def test_protrusions(self):
        _, prots_my = sr.get_protrusions(self.image, SE=self.SE, lam=108, vizualize=False)
        assert sr.image_diff(self.prots_true, prots_my, vizualize=False)
        
    def test_indentations(self):
        _, indents_my = sr.get_indentations(self.image, SE=self.SE, lam=108, vizualize=False)
        assert sr.image_diff(self.indents_true, indents_my, vizualize=False)