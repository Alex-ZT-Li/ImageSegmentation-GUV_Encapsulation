%% GenerateMontageSelectedCV.m
% Notes: Use to create labelmatrix montage for checking selection quality.

close all, clear
savedir = 'Selected_montage';
mkdir(savedir)
c=pwd;
cd 'Selected_mat_all'
files2 = dir('*.mat');


for k=1:length(files2)
    samples = files2(k).name(1:end-4);
    data = open(files2(k).name);
    mask = label2rgb(data.L1,'hot',[0 0 0]);
    D = imfuse(data.zmax,mask,'blend');
%     D1 = insertText(D,data.shapes.Centroid,round(data.shapes.EquivDiameter*data.Xscale),'FontSize',16,...
%           'TextColor','white','BoxOpacity',0,'AnchorPoint','RightCenter'); %Diasabled: Annotates diameter values into selected GUVs    
    cv1 = data.cv;
    cv1(isnan(cv1)) = -0.1;
    D1 = insertText(D,data.shapes.Centroid,round(cv1,2),'FontSize',16,...
          'TextColor','white','BoxOpacity',0,'AnchorPoint','RightCenter');
    E = imfuse(data.zmax,D1,'montage');
    imwrite(E,fullfile(c,savedir,strcat(samples,'.png')),'compression','lzw');
    
end

cd ../
