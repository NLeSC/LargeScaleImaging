% contents.m- contents of directory ..\Testing
%
% topic: Salient regions detection and description testing
% author: Elena Ranguelova, NLeSc
% date: 2016
%
%**************************************************************************
% Functions
%**************************************************************************
% get_test_filenames- obtain test filenames from test_case and detector
% get_filenames_path- obtain filenames from path and detector
%**************************************************************************
% Scripts
%**************************************************************************
% test_mssr_gray_level.m- script to test a single gray-level MSSR detector
% test_mssr_freiburg.m- test an MSSR-like detector on the Freiburg dataset
% parameter_sweep_mssr_binary.m- script to test the MSSR detector with
%                                different parameters

% transform_test_image.m- script to affinely transformation a test image
% test_thresholding_scientific.m- testing gray-level image thresholding for
%                                 scientific images
% test_smssr_scientific.m- testiing SMSSR detector on scientific images
% test_smssr_general.m- script to test the SMSSR detector on general images

% test_dmsr_general.m- script to test the DMSR detector on general images
% test_dmsr_freiburg.m- testing the DMSR detector on Freiburg dataset
% test_dmsr_combined.m- testing the DMSR detector on Combined dataset
% test_dmsr_scientific.m- testing the DMSR detector on Scientific datasets
% test_dmsr_tnt.m- testing the DMSR detector on TNT dataset
%
% test_flusser_moment.m- script for testing Flusser moment computation
% test_scale_moment_invariant.m- script for testing scale moment invariant computation
% test_scale_moment_invariants.m- script for testing scale moment invariants computation
% test_rotation_moment_invariants.m- script for testing rotaiton moment invariants computation
%
% test_rotmi- testing the Flusser's book MATLAB code rotmi function
%                                          (rotaiton translation and scaling)
% test_cafmi- testing the Flusser's book MATLAB code cafmi function
%                                               (affine moment invariants)
% test_matching_mominv- testing matching using the Flusser's affine moment
%                       invariants as descriptors of the salient regions
% test_matching_mominv_affine_dataset- testing matching with Flusser's affine moment
%                       invariants as descriptors of the salient regions
%                       for the oxford dataset
% test_filter_regions.m- script to test filter_regions function
                                           

