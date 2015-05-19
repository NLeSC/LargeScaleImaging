% conversion_ellipse.m- function to obtain the parameters of an MSER
% ellipse equivalent to am saliency gray detector ellipse (unrotating)

%**************************************************************************
% [A, B, C] = conversion_ellipse(a, b, theta);
%
% author: Elena Ranguelova
% date created: 12/09/06
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% a- MajorAxisLength/2
% b- MinorAxisLength/2
% theta- Orientation of the major axis (in radians)
%**************************************************************************
% OUTPUTS:
% A, B, C- polynomial coefficients for an MSER ellipse (see Readme.txt)
%**************************************************************************
% EXAMPLES USAGE:
%**************************************************************************

function [A, B, C] = conversion_ellipse(a, b, theta)

% trigonometric functions
sin_theta = sin(theta);
cos_theta = cos(theta);
sin_cos_theta = sin_theta*cos_theta;

%squares
a_sq = a*a;
b_sq = b*b;
sin_theta_sq = sin_theta*sin_theta;
cos_theta_sq = cos_theta*cos_theta;

%common denominator
denom = a_sq*b_sq;

A = (b_sq*cos_theta_sq + a_sq*sin_theta_sq)/denom;
B = ((b_sq - a_sq)*sin_cos_theta)/denom;
C = (b_sq*sin_theta_sq + a_sq*cos_theta_sq)/denom;