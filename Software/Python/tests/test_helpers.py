# -*- coding: utf-8 -*-
"""
Created on Wed Mar 23 16:10:57 2016

@author: elena
"""
from .context import salientregions as sr
import unittest
import cv2
import os
import numpy as np

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


        

class HelpersEllipseTester(unittest.TestCase):
    '''
    Tests for the helper functions related to ellipses
    '''
    
    def setUp(self):
        self.major_axis_len = 15
        self.minor_axis_len = 9
        self.theta = 0.52 
        self.coeff = [0.006395179230685, -0.003407029045900, 0.010394944226105]
        
        testdata_path = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../TestData/Binary/'))

        self.ellipse1_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_ellipse1.png')), threshold=128, visualize=False))
        self.features_ellipse1 = 100.00*np.array([2.000000000000000,   1.750000000000000,   0.000008650519031,  -0.000000000000000,   0.000051020408163,   0.020000000000000])    
        
        self.ellipse2_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_ellipse2.png')), threshold=128, visualize=False))
        self.features_ellipse2 = 100.00*np.array([1.870000000000000,   0.385000000000000,   0.000400000000000,   0.000000000000000,   0.000100000000000,   0.020000000000000])
        
        self.ellipse3_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_ellipse3.png')), threshold=128, visualize=False))
        self.features_ellipse3 = 100.00*np.array([1.019717800289436,   0.904095513748191,   0.000017518811785,  -0.000000901804067,   0.000022518036288,   0.020000000000000])
        
        self.ellipse4_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_ellipse4.png')), threshold=128, visualize=False))
        self.features_ellipse4 = 100.00*np.array([0.653333333333333,   1.860687093779016,   0.000040675758984,   0.000022724787475,   0.000031250940690,   0.020000000000000])

        self.connectivty = 4
        self.rtol = 2 # default for np.allclose is 1e-05!!
        self.atol = 1e-04 # default for np.allclose is 1e-08
        
    def test_region2ellipse(self):
        A, B, C = sr.helpers.region2ellipse(self.major_axis_len, self.minor_axis_len, self.theta)
        coeff = [A,B,C]
        assert sr.helpers.array_diff(self.coeff,coeff)
        
        
    def test_mask2features_ellipse1(self):
       # print "---Testing binary_mask2ellipse_features for ellipse1----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.ellipse1_mask, self.connectivty, 2)
        
#        print "MATLAB features:", self.features_ellipse1
#        print "Python features:", features
#        print 'Difference: ', features - self.features_ellipse1
#        print 'Max abs. difference: ',  np.max(np.max( np.abs(features - self.features_ellipse1)))
#        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_ellipse1, features, self.rtol, self.atol)   
        
    def test_mask2features_ellipse2(self):
        #print "---Testing binary_mask2ellipse_features for ellipse2----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.ellipse2_mask, self.connectivty, 2)
        
        #print "MATLAB features:", self.features_ellipse2
        #print "Python features:", features
        #print 'Difference: ', features - self.features_ellipse2
        #print 'Max abs.difference: ',  np.max(np.max( np.abs(features - self.features_ellipse2)))
        #print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_ellipse2, features, self.rtol, self.atol)        
            
    def test_mask2features_ellipse3(self):
        #print "---Testing binary_mask2ellipse_features for ellipse3----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.ellipse3_mask, self.connectivty, 2)
        
#        print "MATLAB features:", self.features_ellipse3
#        print "Python features:", features
#        print 'Difference: ', features - self.features_ellipse3
#        print 'Max abs. difference: ',  np.max(np.max( np.abs(features - self.features_ellipse3)))
#        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_ellipse3, features, self.rtol, self.atol)    
        
    def test_mask2features_ellipse4(self):
        #print "---Testing binary_mask2ellipse_features for ellipse4----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.ellipse4_mask, self.connectivty, 2)
        
#        print "MATLAB features:", self.features_ellipse4
#        print "Python features:", features
#        print 'Abs.Difference: ', np.abs(features - self.features_ellipse4)
#        print 'Max abs. difference: ',  np.max(np.max( np.abs(features - self.features_ellipse4)))
#        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_ellipse4, features, self.rtol, self.atol)    