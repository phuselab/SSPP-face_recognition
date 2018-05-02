clear
close all

% DEMO for face recognition by klimaps

disp('Loading data...');
load('data/fds_Dicts_50Sbj_72feats_12dict.mat'); 

% create Tester object and run test
tsr = Tester(fds,'test');
tsr.classify_LFW_MF_TestAugmented();

fds.disp

tsr.disp
