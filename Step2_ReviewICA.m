% EEG Emotion Recognition DL model validation.
% Step 2: Review ICA for SEED VII
% by: Diego Caro López.
% last edited: 29-Dec-2025.
%__________________________________________________________________________
% 
% This MATLAB script will open the preprocessed files saved from: 
% 'Step1_Preprocessing.m' and reject artifact components.

clear
clc
close all
savedata = 'No';

%% Step 1: Loading data
fprintf('\n===== Step 1: Loading data =====\n\n');

folder = 'D:\valid\seed_vii\EEG_preprocessed';
files = dir(folder);
files = files(~[files.isdir]);

id = 1;
EEG = load([fullfile(folder,files(id).name)]).EEG;
savename = [files(id).name(1:7) 'clean'];

fprintf('\n Done...\n\n');

%% Step 2: Label components
fprintf('\n===== Step 2: Label Components =====\n\n');

EEG = pop_iclabel(EEG,'default');
pop_viewprops(EEG,0,1:size(EEG.icaact,1),{'freqrange',[1 50]},{},1,'ICLabel');
reject = [];

fprintf('\n Done...\n\n');

%% Step 3: See results
fprintf('\n===== Step 3: Reject artifacts =====\n\n');

preEEG = EEG;
EEG = pop_subcomp(EEG,reject,0,0);
vis_artifacts(EEG,preEEG);

fprintf('\n Done...\n\n');

%% Step 4: Save results
if strcmpi(savedata,'Yes')
    fprintf('\n===== Step 4: Save Output =====\n\n');
    
    savedir = 'D:\valid\seed_vii\EEG_clean\';
    save([savedir,savename '.mat'],'EEG')

    fprintf('\n Done...\n\n');
end
