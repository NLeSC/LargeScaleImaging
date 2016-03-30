# Python software for image processing

This folder contains Python software implementation of the MATLAB salient region detection code as part of the [image processing part of eStep](https://www.esciencecenter.nl/technology/expertise/computer-vision). The software conforms with the [eStep standarts](https://github.com/NLeSC/estep-checklist).

It contains sub-folders:

## Notebooks
SeveraliPython notebooks testing and illustrating major functionality.

## salientregions
The code implementing salient region detection functionality.

## tests
Unit tests for the code in salientregions.

# Installation
## Prerequisites
* Python 2.7
* pip
* [conda](http://conda.pydata.org/docs/) . If you don't want to use conda, you need to build and install [opencv 3.1.0](http://opencv-python-tutroals.readthedocs.org/en/latest/py_tutorials/py_setup/py_table_of_contents_setup/py_table_of_contents_setup.html#py-table-of-content-setup) manually. 


## Installing the package
If desired, activate an virtual environment. To build the package, type the following command in the current directory (`Software/Python/`):

`make`

To install the package `salientregions`  in your environment:

`make install`

If you want to run tests, you need to pull the test images from this git repository using [git lfs](https://git-lfs.github.com/). To perform tests:

`make test`