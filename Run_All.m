%% Run_all.m: Image Processing for Relative Encapsulation Experiments.

% Notes: This code runs the entire processing chain.

run SegmentObjects_RelEncap.m
run SelectObjectsAll_CV.m
run GenerateMontageSelectedCV.m
run Compile_Encap.m
run RelEncap.m

%% Other
% run GenerateMontageSegmented.m %Optional if you want to check segmentation quality.
