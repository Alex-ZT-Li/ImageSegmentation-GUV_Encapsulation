%% Compiles all segmented/selected mats files
% Notes: For compiling together data from relative encapsulation mat files.
% Output: Compiled_data_single.mat

clear all
close all

%% Input Parameters
low = 3;             % Minimum vesicle diameter in microns to be included, set to 0 for all (Note: <1 dia. are not considered GUVs)

%% Compile
a=pwd;
mkdir('Processed_mat')
cd 'Selected_mat_all'
files = dir('*mat'); 

% Initalizing variables
dia = [];
encap = [];
encapcore = [];
pos = [];
red_chan = [];
redshapes = [];
redpixels = [];
bgshapes = [];
greenpixels = [];

for k=1:length(files)
    filename{k,1} = files(k).name;
    data =      open(filename{k});
    Xscale =    data.Xscale;
    dia =   vertcat(dia, data.diameter_UV*Xscale);
    encap = vertcat(encap, data.EncapInt_UV);
    encapcore = vertcat(encapcore, data.EncapCore_UV);
    red_chan = vertcat(red_chan, data.MeanIntensity_UV);
    pos = vertcat(pos,k.* ones(length(data.diameter_UV),1));
    redpixels = vertcat(redpixels, data.redpixels_UV);
    greenpixels = vertcat(greenpixels, data.greenpixels_UV);
    bgshapes = vertcat(bgshapes, data.bgint);

end

%Keep only vesicle sizes within a certain range size range based on z height and slice thickness
encap = encap(dia>=low);
encapcore = encapcore(dia>=low);
red_chan = red_chan(dia>=low);
redpixels = redpixels(dia>=low);
greenpixels = greenpixels(dia>=low);
pos = pos(dia>=low);
dia = dia(dia>=low);

cd(a)
t = 0:0.5:(length(encap(1,:))-1)/2;

outputFileNameMAT1 = 'Compiled_data_single.mat';
save(outputFileNameMAT1,'t','Xscale','dia','encap','encapcore','red_chan'...
    ,'redpixels','bgshapes','greenpixels','pos');
movefile(outputFileNameMAT1,strcat(a,'\Processed_mat'));