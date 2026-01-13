% EEG Emotion Recognition DL model validation.
% Step 1: Preprocessing SEED VII
% by: Diego Caro López.
% last edited: 23-Dec-2025.
%__________________________________________________________________________
%
% This MATLAB script will preprocess the data from the SEED VII EEG dataset
% and save the data after running ICA, to further manually inspect and
% reject artifacts.

clear
clc
close all
savedata = 'Yes';

%% Step 1: Loading data
tic
folder = 'D:\valid\seed_vii\EEG_raw\';
files = dir(folder);
files = files(~[files.isdir]);

% for id = 1:size(files,1)
for id = 54:size(files,1)
    fprintf('\n===== Step 1: Loading data =====\n\n');
    file = files(id).name;
    sub = split(file,'_');
    sub = sub{1};
    trial = file(end-4);

    EEG = pop_loadcnt([folder file],'dataformat','auto','memmapfile','');
    EEG = pop_resample(EEG,250);

    EEG = pop_chanedit(EEG,'lookup',['C:\Program Files\MATLAB\R2023a' ...
        '\toolbox\eeglab2021.1\plugins\dipfit5.4\standard_BEM\elec' ...
        '\standard_1005.elc']);
    remove = {'M1','M2','HEO','VEO','ECG','CB1','CB2'};
    rem_ids = find(ismember({EEG.chanlocs.labels},remove));

    EEG.ignored = EEG.data(rem_ids,:);
    EEG.data(rem_ids,:) = [];

    EEG.ignored_labels = EEG.chanlocs(rem_ids);
    EEG.chanlocs(rem_ids) = [];
    EEG.nbchan = size(EEG.data,1);

    fprintf('\n Done...\n\n');

    %% Step 2: Bandpass filter @ 1 - 50 Hz
    fprintf('\n===== Step 2: Bandpass filter @ 1-50 Hz =====\n\n');

    EEG = pop_eegfiltnew(EEG,'locutoff',1,'hicutoff',50);

    fprintf('\n Done...\n\n');

    %% Step 3: Common Average Reference
    fprintf('\n===== Step 3: Run CAR =====\n\n');

    EEG = pop_reref(EEG,[]);

    fprintf('\n Done...\n\n')

    %% Step 4: CleanLine at 50 Hz
    fprintf('\n===== Step 4: Cleanline =====\n\n');

    EEG = pop_cleanline(EEG, ...
        'ChanCompIndices',1:EEG.nbchan, ...
        'SignalType','Channels', ...
        'ComputeSpectralPower',true, ...
        'Bandwidth',1, ...
        'SlidingWinStep',0.5, ...
        'SlidingWinLength',4, ...
        'LineFrequencies',[50 100]);

    fprintf('\n Done...\n\n');

    %% Step 5: Independent Component Analysis
    fprintf('\n===== Step 5: Run ICA =====\n\n');

    EEG = pop_runica(EEG,'icatype','runica','extended',1,'interrupt','on');
    fprintf('\n Done...\n\n');

    %% Step 6: Dipole fitting
    fprintf('\n===== Step 9: Run DIPFIT =====\n\n');

    dipfit_obj = class_DIPFIT('input',EEG);
    dipfit_obj.process()

    EEG = dipfit_obj.postEEG;
    EEG = iclabel(EEG,'default');
    % toc

    fprintf('\n Done...\n\n');

    %% Step 7: Save data
    if strcmpi(savedata,'Yes')
        fprintf('\n===== Step 10: Save Output =====\n\n');

        savedir = 'D:\valid\seed_vii\EEG_preprocessed\';
        if str2double(sub) < 10
            name = ['0' sub];
            savename = ['S' name '_T' trial '_preprocessed'];
        else
            name = sub;
            savename = ['S' name '_T' trial '_preprocessed'];
        end
        save([savedir,savename '.mat'],'EEG')

        fprintf('\n Done...\n\n');
    end
end
toc
