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
        testdata_path = os.path.normpath(
            os.path.join(
                os.path.dirname(
                    os.path.abspath(__file__)),
                '../../../TestData/Binary/'))
        self.image_noise = sr.binarize(
            cv2.imread(
                os.path.join(
                    testdata_path,
                    'Binary_all_types_noise.png')),
            threshold=128,
            visualize=False)
        self.image_nested = sr.binarize(
            cv2.imread(
                os.path.join(
                    testdata_path,
                    'Binary_nested.png')),
            threshold=128,
            visualize=False)
        self.holes_true, self.islands_true, self.indents_true, self.prots_true = sr.read_matfile(
            os.path.join(testdata_path, 'Binary_all_types_noise_binregions.mat'), visualize=False)
        self.filled_image_noise_true = sr.binarize(
            cv2.imread(
                os.path.join(
                    testdata_path,
                    'Binary_all_types_noise_filled.png')),
            threshold=128,
            visualize=False)
        self.filled_image_nested_true = sr.binarize(
            cv2.imread(
                os.path.join(
                    testdata_path,
                    'Binary_nested_filled.png')),
            threshold=128,
            visualize=False)

        SE = sio.loadmat(
            os.path.join(
                testdata_path,
                "SE_neighb_all_other.mat"))['SE_n']
        lam = 50
        area_factor = 0.05
        connectivity = 4
        self.binarydetector = sr.BinaryDetector(
            SE=SE, lam=lam, area_factor=area_factor, connectivity=connectivity)

    def test_holes(self):
        results = self.binarydetector.detect(
            self.image_noise,
            find_holes=True,
            find_islands=False,
            find_indentations=False,
            find_protrusions=False,
            visualize=False)
        holes_my = results['holes']
        assert sr.image_diff(self.holes_true, holes_my, visualize=False)

    def test_islands(self):
        results = self.binarydetector.detect(
            self.image_noise,
            find_holes=False,
            find_islands=True,
            find_indentations=False,
            find_protrusions=False,
            visualize=False)
        islands_my = results['islands']
        assert sr.image_diff(self.islands_true, islands_my, visualize=False)

    def test_protrusions(self):
        results = self.binarydetector.detect(
            self.image_noise,
            find_holes=False,
            find_islands=False,
            find_indentations=False,
            find_protrusions=True,
            visualize=False)
        prots_my = results['protrusions']
        assert sr.image_diff(self.prots_true, prots_my, visualize=False)

    def test_indentations(self):
        results = self.binarydetector.detect(
            self.image_noise,
            find_holes=False,
            find_islands=False,
            find_indentations=True,
            find_protrusions=False,
            visualize=False)
        indents_my = results['indentations']
        assert sr.image_diff(self.indents_true, indents_my, visualize=False)

    def test_fill_image_noise(self):
        filled = sr.BinaryDetector.fill_image(self.image_noise)
        assert sr.image_diff(
            self.filled_image_noise_true,
            filled,
            visualize=False)

    def test_fill_image_nested(self):
        filled = sr.BinaryDetector.fill_image(self.image_nested)
        assert sr.image_diff(
            self.filled_image_nested_true,
            filled,
            visualize=False)
