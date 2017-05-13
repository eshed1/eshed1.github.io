clear, clc, close all;

pmtroot ='path to pdollar toolbox';   %SET PIOTR'S TOOLBOX PATH
addpath(genpath(pmtroot));

kittiroot = 'path to kitti object devkit. with function readlabels';   %SET DEVELOPMENT KIT FOR KITTI   
addpath(genpath(kittiroot));

kittiobjectroot = 'set path to kitti object dataset'; %Where 'image_2' and 'label_2' are

dataDir = 'set path to save train/validation split in subcat format'; % Saves the PMT version of the dataset
resDir = 'set path to save trained models'; 


rootlabels = fullfile(kittiobjectroot,'label_2');
rootims = fullfile(kittiobjectroot,'image_2');

%We use `moderate' settings in training. 
minboxheight = 25;
occlusionLevel = [0:1]; % [0:2] 0 = fully visible, 1 = partly occlud 2 = largely occluded, 3 = unknown
Maxtruncation = 0.3; % Percentage, from 0 to 1.
labels = {'Car'}; %can do {'Car','Truck','Van'} for adding these to training, but not needed for KITTI evaluation
B = 25; %Number of orientation clusters. Up to 20-25 should increase performance.