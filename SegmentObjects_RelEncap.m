%% SegmentObjects_RelEncap: Segmentation for Relative Encapsulation Experiments

% Notes: Includes background correction (toggleable). Designed for Images
% taken with a 63X 1.4 NA objective 

close all
clear all

%% Parameters
BGcorr = 1; % 1(on) or 0(off) for background correction by surface fit

%% Directory
files1 = dir('*.czi');
a=pwd;
mkdir('Segmented_mat')
mkdir('Background Correction')
threshotsu=[];
ntiles = length(files1); 

for k=1:ntiles %ntiles
    filename = files1(k).name;
    data= bfopen(filename);          %loads file
    omeMeta1 = data{1,4};            %loads metadata
    Xscale = double(omeMeta1.getPixelsPhysicalSizeX(0).value()); %scale in x-dim 10x0.3=0.397 63X1.4=0.0852; 
    Xdim=omeMeta1.getPixelsSizeX(0).getValue(); %image Size X, in pixels
    Ydim=omeMeta1.getPixelsSizeY(0).getValue();
    %% Split red and green channels
    red_data = data{1,1}(1:2:length(data{1,1}(:,1)),1);
    green_data = data{1,1}(2:2:length(data{1,1}(:,1)),1);
    
    %% Segmentation
    for s=1:length(red_data) %For each 
        zmean = red_data{s};
        I2 = zmean;  %medfilt2(I1,[2 2]);%Filter image to reduce noise
        I2 = imsharpen(I2,'Radius',5,'Amount',3);        
        I2 = imfill(I2,'holes');
%         I2 = imadjust(I2,[0 0.4],[]); %Disabled: Can be used to adjust image brightness
        thresh = multithresh(I2,4);     %Adjust numerical for thresholding
        threshotsu{k} = double(thresh(1))/255;
        I3 = imbinarize(I2,(threshotsu{k}));%Threshold 
        %I4 = imerode(I3,strel('disk',3));  %Disabled: Erode to remove unconnected noise pixels and nanotubes
        %I4 = imdilate(I4,strel('disk',3)); %Disabled: dilate to restore boundary pixels that have been eroded
        I5 = -bwdist(~I3); 
        I5(~I5) = -Inf;
        I6 = imhmin(I5,1);
        L0 = watershed(I6);

        %% Region properties
        bgshape = regionprops('table',L0,zmean,'Area');
        bgobj = find(bgshape.Area == max(bgshape.Area)); %Object with largest area registered is registered as the background
        
        LBG = uint16(L0 == bgobj); %Set background
        L0a = imclearborder(L0); %Remove background connected objects
        L0b = L0a~=0; %create binary image
        L1 = bwlabel(L0b); %relabel binary image to prevent NaNs
        
        shapes = regionprops('table',L1,zmean,'Area','EulerNumber','FilledArea',...
            'Eccentricity','EquivDiameter','Centroid','BoundingBox',...
            'MeanIntensity','PixelValues', 'PixelList', 'Image', 'Perimeter','PixelIdxList');
        
        bgshape1 = regionprops('table',LBG,green_data{s},'MeanIntensity',...
            'PixelValues','PixelIdxList');
        
        %% BG Correction
        if BGcorr == 1
            BG = zeros(size(L1));
            E2 = cell2mat(bgshape1.PixelIdxList);
            BG(E2)=cell2mat(bgshape1.PixelValues);
            BG(BG==0) = NaN;
            [xData, yData, zData] = prepareSurfaceData(1:Xdim,1:Ydim,BG);
            ft = fittype( 'poly22' );
            [fitresult, gof] = fit( [xData, yData], zData, ft, 'Normalize', 'off' );
            cf=coeffvalues(fitresult);
            x1=1:Xdim;
            y1=1:Ydim;
            [x1,y1]=meshgrid(x1,y1);
            z2 = cf(1) + cf(2)*x1 + cf(3)*y1 + cf(4)*x1.^2 + cf(5)*x1.*y1 + cf(6)*y1.^2;
            o1 = max(z2,[],'all');  %Maximum height on fitted
            z3=o1./z2;              %Determine correction factor. 
            green_corr = double(green_data{s}).*z3; %Correcting the original data;

            BG_gauss = imgaussfilt(green_data{s},5);

            h = figure; set(h,'Visible','off')
            subplot(2,2,1); h = surf(z2); set(h,'LineStyle','none'); 
            title('Surface Fit'); colorbar;
            subplot(2,2,2); h = surf(z3); set(h,'LineStyle','none'); 
            title('Correction Factor'); colorbar;
            subplot(2,2,3); h = surf(BG_gauss); set(h,'LineStyle','none');
            title('Original Intensity'); zlim([min(BG_gauss,[],'all')*0.9 max(BG_gauss,[],'all')*1.1]); colorbar;
            subplot(2,2,4); h = surf(imgaussfilt(green_corr,5)); set(h,'LineStyle','none');
            title('Corrected Intensity'); zlim([min(BG_gauss,[],'all')*0.9 max(BG_gauss,[],'all')*1.1]); colorbar;

            saveas(h,strcat('BG_Correction_',num2str(k),'_Z',num2str(s),'.png'))
            movefile(strcat('BG_Correction_',num2str(k),'_Z',num2str(s),'.png'),strcat(pwd,'/Background Correction'))
            close
        else
            green_corr = green_data{s};
        end
        %% BG Corrected Seg
        gshapes = regionprops('table',L1,green_corr,'Area','EulerNumber','FilledArea',...
        'Eccentricity','EquivDiameter','Centroid','BoundingBox',...
        'MeanIntensity','PixelValues', 'PixelList', 'Image', 'Perimeter','PixelIdxList');
        
        bgshapes2 = regionprops('table',LBG,green_corr,'MeanIntensity','PixelIdxList','PixelValues');

        bgint = bgshapes2.MeanIntensity;
        
        %% Measure center of the vesicles
        J1 = zeros(size(L1));
        A = gshapes.PixelList;
        B = num2cell(gshapes.Centroid,2);
        C = cellfun(@minus,A,B,'UniformOutput',false);
        C1 = ones(size(C))*2;
        C2 = cellfun(@power,C,num2cell(C1),'UniformOutput',false); %Can probably combine these into one function
        C3 = cellfun(@transpose,C2,'UniformOutput',false);
        C3 = cellfun(@sum,C3,'UniformOutput',false);
        C3 = cellfun(@transpose,C3,'UniformOutput',false);
        D = gshapes.EquivDiameter * (1/3);
        D1 = cellfun(@le,C3,num2cell(D),'UniformOutput',false);
        D2 = gshapes.PixelValues;
        D3 = cellfun(@(D2,D1)D2(D1==1),D2,D1,'UniformOutput',false); %Only keep pixel values close to centroid
        D4 = cellfun(@(x)sum(x)/length(x),D3);
        gshapes.PixelValuesCore = D3;
        gshapes.MeanIntensityCore = D4;
      
      
        
        %% Save Files
        outputFileNameMAT1 = strcat(filename(1:end-4),'_Z',num2str(s),'.mat');
        save(outputFileNameMAT1,'shapes','gshapes','bgint','bgshapes2'...
            ,'zmean','Xscale','L1','LBG'); %,'cc2'
        movefile(outputFileNameMAT1,strcat(a,'\Segmented_mat'));
    end
end %end of iteration through k files