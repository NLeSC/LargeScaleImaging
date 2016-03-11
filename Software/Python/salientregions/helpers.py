# -*- coding: utf-8 -*-
import cv2
import numpy as np

def show_image(img, window_name='image'):
    '''
    Display the image for 10 seconds.
    When a key is pressed, the window is closed
    '''
    cv2.namedWindow(window_name)
    cv2.startWindowThread()
    cv2.imshow(window_name, img)
    cv2.waitKey(10000)
    cv2.destroyAllWindows()
    

def binarize(img, threshold=127, vizualize=True):
    '''
    Binarize the image according to a given threshold.
    Returns a one-channel image with only values of 0 and 255.
    '''
    ret, binarized = cv2.threshold(img, threshold, 255, cv2.THRESH_BINARY)
    binarized = binarized[:,:,0]
    if(vizualize):
        show_image(binarized)
    return binarized