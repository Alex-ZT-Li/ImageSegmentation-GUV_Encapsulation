# GUV-ImageDetection-Encapsulation

## Requirements:
Code requires MATLAB version R2021a or greater with packages:

(1 of 6) Bio-Formats Plugin for MATLAB, version 5.3.4 or greater (External plugin from Open Microscopy Environment)

(2 of 6) Image Processing Toolbox, version 11.3 or greater

(3 of 6) Curve Fitting Toolbox, version 3.5.13 or greater

(4 of 6) Signal Processing Toolbox, version 8.6 or greater

(5 of 6) Statistics and Machine Learning Toolbox, version 12.1 or greater.

(6 of 6) Computer Vision Toolbox, version 10.0 or greater.

(Note: Tested on MATLAB version R2021a)

## Description
Performs image segmentation to detect and analyze giant unilamellar vesicles (GUVs) from fluorescence microscopy images and determines the encapsulation efficiency of individual GUVs using a relative encapsulation method. 

## Instructions

1. Place all .m files (7 total) in the same folders with the .czi image files.

2. Run "Run_All.m" for running the entire processing chain.

3. "Run_all.m" will run through the following codes described here in order:

a) SegmentObjects_RelEncap.m - Will segment all objects in the .czi images and measure both total and core intensity from the objects. Outputs a .mat file per czi image into the generated "Segmented_mat" folder.

b) SelectObjectsAll_CV - Selects likely vesicles from segmented objects using a CV analysis method. Must check lower bound (lb) values to see if selection is accurate for your image conditions. You can check by looking at the montage. Lower bound refers to the minimum CV values necessary to be considered a vesicle. Outputs a mat file per czi image into the generated "Selected_mat_all" folder.

c) GenerateMontageSelectedCV.m - Provides reference images to check processing quality. Outputs a montage images of selected and segmented vesicles, one for each czi image file. Will output a reference image on the left side. On the right side, it will contain the reference image with segmented (white overlay) and selected vesicles (red overlay).
NOTE: This can take considerable amount of time to run. If all processing parameters are known to work, you could consider skipping this processing step.

d) Compile_Encap.m - Compiles all relevant vesicle data from the "Selected_mat_all" folder into one output file "Compiled_data_single.mat" in the "Processed_mat" folder. Note a vesicle diameter minimum value must be set here in the parameters. Defaults to 3 microns. 

Key Parameters for d)
bgshapes 	- list of background intensity values of each czi image.
dia 	 	- list of diameter values in microns for each vesicle.
encap 	 	- list of total encapsulated intensity values (e.g. intensity of the cargo (FITC-BSA))
encapcore 	- list of core encapsulated intensity values
greenpixels 	- list of all pixel intensites for the encapsulated cargo (e.g. FITC-BSA) from each vesicle.
redpixels	- list of all pixel intensities for the lipid channel from each vesicle (e.g. DOPC-RhPE)
red_chan	- list of total intensity values from the lipid channel (e.g. DOPC-RhPE)
pos 		- list of file numbers each vescile comes from (note might not match file names, confirm processing order)
Xscale 		- Xscale value (micron/pixel) determined from the czi metadata.

e) RelEncap.m - Post processing code. Calculations the relative encapsulation for the core intensity and total intensity data. Outputs various figures and a "Rel_Encap_Single.mat" file. 

Key Parameters for e):
dia_all 	- list of all diameters in microns for each vesicle.
rel_encap 	- list of all relative encapsulation values based on total encapsulated intensity.
rel_encapcore 	- list of all relative encapsulation values based on core encapsulated intensity.


4. Optional Code: GenerateMontageSegmented.m performs the same task as GenerateMontageSelectedCV.m but without the selected vesicle data. Usually unnecessary to run both unless troubleshooting something specific.
