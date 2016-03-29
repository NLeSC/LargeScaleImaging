# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

with open('README.md') as f:
    readme = f.read()

setup(
    name='salientregions',
    version='0.0.1',
    description='Package for finding salient regions in images',
    long_description=readme,
    author='Netherlands eScience Center',
    url='https://github.com/NLeSC/LargeScaleImaging',
    packages=find_packages(exclude=('tests'))
)