%% SelectObjectsAll_CV: Select for likely GUVs from segmented objects using an CV analysis.

% Notes: Designed for images taken with a 63X 1.4 NA Objective. 
% Lower bound (lb) values may need to be tested and adjusted for different
% environments or lipids.

%Input:     .mat files with regionprops information for vesicles in individual tile scans
%Process:   Identifies unilamellar vesicles and labels tif files
%Output:    .mat files with regionprops information on vesicles classifed as unilamellar

close all, clear all

mat_dir = 'Selected_mat_all';
hist_dir = 'Selected_histogram_all';
mkdir(mat_dir), 
mkdir(hist_dir)
a=pwd;
cd Segmented_mat
files2 = dir('*.mat');

edges = 0:0.02:10;
centers = (edges(1:end-1)+edges(2:end))/2;

%% Parameters
lb = 0.73; %Selected lower bound CV value (check montages to adjust). 
% This lb value was experimentally determined for GUVs labeled with
% Rhodamine PE using a 63x 1.4 NA Oil objective. May need adjustment!

%% Initialize/Reinitalize shape variables for this set
samples = {};
L1_all = {};
i_all = [];
i_cv_all = {};
shapesall = {};
gshapesall = {};
zmaxall = {};
bgint_all = [];


%% Collects all data for current Z position
for j=1:length(files2)
    i_cv = []; %i_cv needs to be reinitalized for each iteration
    samples{j} = files2(j).name(1:end-4);
    data = open(files2(j).name);
    L1_all{j}=data.L1;
    i_px = transpose(data.shapes.PixelValues);
    for k = 1:length(i_px)
        i_cv(k) = std(double(i_px{k}))/mean(double(i_px{k}));
    end
    Xscale = data.Xscale;
    shapesall{j}=data.shapes;
    gshapesall{j} = data.gshapes;
    zmaxall{j}=data.zmean;
    bgint_all(j) = data.bgint;
    i_all = [i_all,i_cv];
    i_cv_all{j} = i_cv;
end

%% Peak fitting

cd(a)
ydata = histcounts(i_all,edges,'Normalization','probability');
[pks,locs, w, p] = findpeaks(ydata,centers,'MinPeakDistance',0.9,'MinPeakHeight',0.1*max(ydata));
if ~ isempty(locs)    

   %Plot histogram
    h=figure; hold on; axis square; set(h, 'Visible', 'on');
    h=histogram(i_all,edges,'Normalization','probability', 'FaceColor','w');
    findpeaks(ydata,centers,'MinPeakDistance',0.9,'MinPeakHeight',0.1*max(ydata),'Annotate', 'Extents');
    plot([lb lb],[0 1],'b'); % plot([ub ub],[0 1],'b');
    legend(strjoin({'peak loc =',num2str(locs)}), strjoin({'width =',num2str(round(w*100)/100)}),...
         strjoin({'lower bound',num2str(round(lb*100)/100)})); %,strjoin({'upper bound',num2str(round(ub*100)/100)})
    legend('Location','NorthEast');
    axis([0 max(i_all) 0 0.5]),title('All images'),xlabel('Intensity'),ylabel('Frequency');
    saveas(gcf,fullfile(a,hist_dir,strcat('hist_Z','.png')));
%     movefile(strcat('hist_Z','.png'),strcat(a,hist_dir));
end

if isempty(locs)
    h=figure; hold on; axis square; set(h, 'Visible', 'on');
    h=histogram(i_all,edges,'Normalization','probability', 'FaceColor','w');
    legend('Location','NorthEast');
    axis([0 0.5 0 0.2]),title('No_Peak'),xlabel('Intensity'),ylabel('Frequency');
    saveas(gcf,fullfile(a,hist_dir,strcat('hist_','No_Peak','.png')));
%     movefile(strcat('hist_','No_Peak','.png'),strcat(a,hist_dir));
end

%% Choose only vesicles
for k=1:length(files2)
    if ~ isempty(locs)
        % Choose only vesicles
        ves_sel = i_cv_all{k} >= lb; %(i_cv_all{k} <= ub) & i_cv_all{k} >= lb);

        diameter_UV = shapesall{k}.EquivDiameter(ves_sel);
        MeanIntensity_UV = shapesall{k}.MeanIntensity(ves_sel);
        EncapInt_UV = gshapesall{k}.MeanIntensity(ves_sel); %added
        EncapCore_UV = gshapesall{k}.MeanIntensityCore(ves_sel); 
        V = cell2mat(shapesall{k}.PixelIdxList(ves_sel));

        redpixels_UV = shapesall{k}.PixelValues(ves_sel); %3/17 Al
        greenpixels_UV = gshapesall{k}.PixelValues(ves_sel); %3/17 AL

        % Identify non-vesicles
        NV = cell2mat(shapesall{k}.PixelIdxList(i_cv_all{k} < lb));

        %relabel label matrix
        L1_all{k}(NV)=8;
        L1_all{k}(V)=3;

        %Identify Background Intensity
        bgint = bgint_all(k);
    end
    shapes = shapesall{k};
    gshapes = gshapesall{k};
    zmax = zmaxall{k};
    L1 = L1_all{k};
    cv = i_cv_all{k};

    save(fullfile(a,mat_dir,strcat(samples{k},'_selected.mat')),'zmax','L1','shapes','Xscale','diameter_UV','MeanIntensity_UV','EncapInt_UV'...
        ,'EncapCore_UV','redpixels_UV','greenpixels_UV','bgint','ves_sel','cv');
end

