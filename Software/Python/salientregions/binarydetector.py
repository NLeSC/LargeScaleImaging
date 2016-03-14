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
    

def get_holes(img, lam=-1, vizualize=True):
    if(vizualize):
        helpers.show_image(img, 'original')

    #Determine lambda, if necessary
    if(lam < 0) :
        SE, lam = helpers.get_SE(img)
    #retrieve the filled image and the filled small elements
    filled, filled_small = fill_image(img, lam, vizualize)
    #get all the holes (including those that are noise)
    all_the_holes = cv2.bitwise_and(filled, cv2.bitwise_not(img))
    #Substract the noise elements
    theholes = cv2.bitwise_and(all_the_holes, cv2.bitwise_not(filled_small))

    if(vizualize):
        helpers.show_image(all_the_holes, 'holes with noise')
        helpers.show_image(theholes, 'holes without noise')
    
    return filled, theholes
    
    
def get_islands(img, lam=20, vizualize=True):
    invimg = cv2.bitwise_not(img)
    invfilled, islands = get_holes(invimg, lam, vizualize)
    return invfilled, islands