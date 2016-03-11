# -*- coding: utf-8 -*-
import cv2
import helpers
import numpy as np

def fill_image(img, lam=20, vizualize=True):
    filled = img.copy()
    filled_small = np.zeros(img.shape, dtype='uint8')
    img2, contours, hierarchy = cv2.findContours(filled,cv2.RETR_CCOMP,cv2.CHAIN_APPROX_SIMPLE)
    for cnt in contours:
        #Fill the original image for all the contours
        cv2.drawContours(filled, [cnt], 0, 255, -1)
        #If it's a small contour, draw it to the noise-image
        if cv2.contourArea(cnt) < lam:
            cv2.drawContours(filled_small, [cnt], 0, 255, -1)
            
    if(vizualize):
        helpers.show_image(filled, 'filled image')
        helpers.show_image(filled_small, 'filled small elements')
    
    return filled, filled_small
    

