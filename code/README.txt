Extracts HOG2 and performs training/testing using the liblinear SVM implmentation

Usage:
data and HOG2 features are stored in MSRGesture3D.mat
run script_computeHOG2 to extract HOG2 features (usually I use 8 orientation bins both spatially and temporally and 4 or 6 cells in x and y direction)
main provides a demo for training/testing using a linear SVM. It produces a 93.03% on the MSR-Hand Gesture dataset. 

The code is only given for research purposes. 
the code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. 
You are free to use, modify, or redistribute this code in any way you want for non-commercial purposes. 
If you do so, I would appreciate it if you refer to the original paper.

@inproceedings{ohnbar13,
title={Joint Angles Similiarities and {HOG^2} for Action Recognition},
author={Eshed Ohn-Bar and Mohan M. Trivedi},
booktitle={Computer Vision and Pattern Recognition Workshops-HAU3D}, 
year={2013}
}
    
Feel free to contact me at eohnbar@ucsd.edu if you have questions.
















