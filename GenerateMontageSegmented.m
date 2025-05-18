%% GenerateMontageSegmented.m

%%IMPORTANT: RENAME THE FIRST FILE OF THE TILESCAN SERIES TO 1.CZI SO THAT BFOPEN DOES NOT TRY TO RELOAD ALL FILES AT EACH ITERATION

% Note that it doesn't have to be "1.czi", as long as the name is not
% consistent with the rest of the images it won't open all images together as a stack.

% Input: 	.czi images of z-stacks of extracted vesicles with metadata
% Process:  Performs watershed segmentation on image files
% Update:   stores tiling positions and relabels images by tiling


close all
clear all
mkdir('Segmented_montage');

b=pwd;
cd 'Segmented_mat'
files1 = dir('*.mat');

for k=1:length(files1)
    filename = files1(k).name;
     
    samples = files1(k).name(1:end-4);
    data = open(files1(k).name);
         mask = boundarymask(data.L1); %Define mask to allow checking
         RGB = label2rgb(data.L1, 'jet', [0 0 0], 'shuffle');
         B = imoverlay(RGB,mask,'k');
         C = imfuse(data.zmean,B,'blend');
         D = insertText(C,data.shapes.Centroid,round(data.shapes.EquivDiameter*data.Xscale),'FontSize',16,...
          'TextColor','white','BoxOpacity',0,'AnchorPoint','RightCenter');
         D1 = imfuse((data.zmean),D,'montage');
         outputFileName2=(strcat(filename(1:end-1),'_zaa',num2str(k),'_montage.tif'));
         imwrite(D1,outputFileName2,'compression','lzw');
         movefile(outputFileName2,strcat(b,'\Segmented_montage'));
 end
    
cd ../