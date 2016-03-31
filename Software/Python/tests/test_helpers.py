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
        self.holes_mask = 255-sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_holes.png')), threshold=128, visualize=False)
        self.features_holes = 100.00*np.array([
                [0.637312844759653,   1.872269503546099,   0.000036609265896,   0.000019432485225,   0.000024816969531,   0.010000000000000],
                [1.010000000000000,   0.890000000000000,   0.000016000000000, -0.000000000000000,   0.000017361111111,   0.010000000000000],
                [2.000000000000000,   1.750000000000000,   0.000008650519031,  -0.000000000000000,   0.000051020408163,   0.010000000000000],
                [1.870000000000000,  0.385000000000000,   0.000400000000000,   0.000000000000000,   0.000100000000000,   0.010000000000000]])
        self.islands_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_islands.png')), threshold=128, visualize=False))
        self.features_islands = 100.00*np.array([
                [0.637312844759653,   1.872269503546099,   0.000036609265896,   0.000019432485225,   0.000024816969531,   0.020000000000000],
                [1.010000000000000,   0.890000000000000,   0.000016000000000, -0.000000000000000,   0.000017361111111,   0.020000000000000],
                [2.000000000000000,   1.750000000000000,   0.000008650519031,  -0.000000000000000,   0.000051020408163,   0.020000000000000],
                [1.870000000000000,  0.385000000000000,   0.000400000000000,   0.000000000000000,   0.000100000000000,   0.020000000000000]])
        
        self.indentations_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_indentations_mask.png')), threshold=128, visualize=False))
        self.features_indentations = 100.00*np.array([
            [1.266124260355030,   1.852189349112426,   0.000088587345319,   0.000014395112021,   0.000117514072903,   0.030000000000000],
            [1.422552693208431,   0.454707259953162,   0.000160825502563,  -0.000074977484068,   0.000074120327621,   0.030000000000000]  ])        
        self.protrusions_mask = np.array(sr.binarize(cv2.imread(os.path.join(testdata_path, 'Binary_protrusions_mask.png')), threshold=128, visualize=False))
        self.features_protrusions = 100.00*np.array([
            [1.408666666666667,   1.974148148148148,   0.000230797258120,  -0.000059179970645,   0.000203230519657,   0.040000000000000],
            [1.533061224489796,   0.407891156462585,   0.000167346120798,   0.000050809010498,   0.000388903879202,   0.040000000000000],
            [1.716145833333333,   1.235000000000000,   0.000374319920480,  -0.000049791664982,   0.000303457857298,   0.040000000000000] ])
        
        self.connectivty = 4
        
    def test_region2ellipse(self):
        A, B, C = sr.helpers.region2ellipse(self.major_axis_len, self.minor_axis_len, self.theta)
        coeff = [A,B,C]
        assert sr.helpers.array_diff(self.coeff,coeff)
        
    def test_mask2features_holes(self):
        print "---Testing binary_mask2ellipse_features for holes----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.holes_mask, self.connectivty, 1)
        
        print "MATLAB features:", self.features_holes
        print "Python features:", features
        print 'Difference: ', features - self.features_holes
        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_holes, features)
        
    def test_mask2features_islands(self):
        print "---Testing binary_mask2ellipse_features for islands----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.islands_mask, self.connectivty, 2)
        
        print "MATLAB features:", self.features_islands
        print "Python features:", features
        print 'Difference: ', features - self.features_islands
        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_islands, features)
        
    def test_mask2features_indentaions(self):
        print "---Testing binary_mask2ellipse_features for indentations----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.indentations_mask, self.connectivty, 3)
        
        print "MATLAB features:", self.features_indentations
        print "Python features:", features
        print 'Difference: ', features - self.features_indentations
        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_indentations, features)  
        
    def test_mask2features_protrusions(self):
        print "---Testing binary_mask2ellipse_features for protrusions----------------"
        num_regions, features = sr.helpers.binary_mask2ellipse_features(self.protrusions_mask, self.connectivty, 4)
        
        print "MATLAB features:", self.features_protrusions
        print "Python features:", features
        print 'Difference: ', features - self.features_protrusions
        print '********************************************************************************************'
        assert sr.helpers.array_diff(self.features_protrusions, features)  
        
        