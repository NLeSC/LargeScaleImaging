# -*- coding: utf-8 -*-
from .context import salientregions as sr
from .context import salientregions_detectors as srd
import unittest
import cv2
import os
import numpy as np


class DetectorForTesting(srd.Detector):

    def detect(self):
        pass


class SETester(unittest.TestCase):

    def setUp(self):
        self.SE_true = np.array([[0, 0, 1, 0, 0],
                                 [1, 1, 1, 1, 1],
                                 [1, 1, 1, 1, 1],
                                 [1, 1, 1, 1, 1],
                                 [0, 0, 1, 0, 0]],
                                dtype='uint8')
        self.lam_true = 15
        self.detector = DetectorForTesting(SE_size_factor=0.05,
                                           lam_factor=5,
                                           area_factor=0.05,
                                           connectivity=4)

    def test_getSE(self):
        self.detector.get_SE(100 * 110)
        SE = self.detector.SE
        assert np.all(SE == self.SE_true)

    def test_getlam(self):
        self.detector.get_SE(100 * 110)
        lam = self.detector.lam
        assert lam == self.lam_true
