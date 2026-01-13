    % EEG Emotion Recognition DL model validation
% Step 4: Model Evaluation 
% by: Diego Caro López
% last edited: 09-Jan-2025
%__________________________________________________________________________
% 
% This MATLAB script will read the 5-second EEG windows generated with: 
% 'Step3_SegmentData.m' and pass them through the model: 'dcaro_net'. This
% model is a CNN + LSTM trained onle the DEAP EEG dataset. 
% 
% This new validation data comes from the SEEDVII EEG dataset and consists
% of 7 emotional states: 
%   1. Disgust.
%   2. Fear.
%   3. Sad. 
%   4. Neutral. 
%   5. Happy.
%   6. Anger. 
%   7. Surprise. 
% 
% 'dcaro_net' was trained to predict only 4 emotional states: 
%   1. Relief.
%   2. Surprise.
%   3. Fear.
%   4. Disgust. 
% 
% The 'Neutral' state from the SEED VII dataset will be taken as the
% 'Relief' label for 'dcaro_net'.

clear 
clc
close all

%% Step 1: Load data
fprintf('\n===== Step 1: Loading data =====\n\n');

% Load EEG data
folder = 'D:\valid\seed_vii\EEG_windows';
files = dir([folder '\*.mat']);
for i = 1:size(files,1)
    load(fullfile(folder,files(i).name))
end

% Load DL model
load('C:\Users\dgcar\OneDrive\Documents\Aura\mat_tests\Models\CrossVal\CVModels.mat')
% load('D:\valid\seed_vii\19-Nov-2025.mat');
dcaro_net = models{10};

fprintf('\n Done... \n\n')

%% Step 2: Testing
fprintf('\n===== Step 2: Testing model =====\n\n');

data1 = [disgust;fear;neutral;surprise];
data2 = [sad;happy;anger];
labels1 = [ones(size(disgust,1),1);
           ones(size(fear,1),1)*2;
           ones(size(neutral,1),1)*3;
           ones(size(surprise,1),1)*4];
labels1 = categorical(labels1);
labels2 = [ones(size(sad,1),1);
           ones(size(happy,1),1)*2;
           ones(size(anger,1),1)*3];
labels2 = categorical(labels2);
n = numel(data1);

emotions1 = {'Disgust','Fear','Neutral','Surprise'};
emotions2 = {'Sad','Happy','Anger'};

YTest = classify(dcaro_net,data1);
YTest2 = classify(dcaro_net,data2);
acc = mean(YTest==labels1);

fprintf('\n Done... \n\n')

%% Step 3: Results
fprintf('\n===== Step 3: Confusion chart =====\n\n');

h = confusionchart(labels1,YTest);
title('Confusion chart: traning emotions')

fprintf('\n Done... \n\n')

%% Step 4: Test other emotions
fprintf('\n===== Step 4: Test addidional emotions =====\n\n');

h2 = confusionchart(labels2,YTest2);
title('Confusion chart: additional emotions')

fprintf('\n Done... \n\n')
