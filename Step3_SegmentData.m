% EEG Emotion Recognition DL model validation
% Step 3: Segment Data for SEED VII
% by: Diego Caro López
% last edited: 07-Jan-2026.
%__________________________________________________________________________
% 
% This MATLAB script will take the clean EEG data genereated from: 
% 'Step2_ReviewICA.m' and select only the data corresponding to the desired
% emotions.

clear 
clc 
close all
savedata = 'Yes';

%% Step 1: Loading data
% Trial order
R = 1:7;
labels = {'disgust','fear','sad','neutral','happy','anger','surprise'};
T = readcell('D:\valid\seed_vii\emotion_label_and_stimuli_order.xlsx');
[~,T1] = ismember(cellfun(@lower,T(2,2:end),'UniformOutput',false),labels);
[~,T2] = ismember(cellfun(@lower,T(4,2:end),'UniformOutput',false),labels);
[~,T3] = ismember(cellfun(@lower,T(6,2:end),'UniformOutput',false),labels);
[~,T4] = ismember(cellfun(@lower,T(8,2:end),'UniformOutput',false),labels);

% Trial counter
n_disgust = 1;
n_fear = 1;
n_sad = 1;
n_neutral = 1;
n_happy = 1;
n_anger = 1;
n_surprise = 1;

% EEG data
channels = {'FP2','F7','F8','T7','T8','P7','P3','P8'};
folder = 'D:\valid\seed_vii\EEG_clean\';
files = dir([folder '*.mat']);

for id = 1:size(files,1)
    fprintf('\n===== Step 1: Loading data =====\n\n');
    
    % Load EEG data
    file = files(id).name;
    EEG = load([fullfile(folder,file)]).EEG;
    trial = str2double(file(6));
    
    % Select only the accepted channels
    chan_ids = find(ismember({EEG.chanlocs.labels},channels));
    EEG = pop_select(EEG,'channel',chan_ids);
    
    fprintf('\n Done... \n\n')
    
    %% Step 2: Select data
    % According to 'SEED-VII_stimulation.xlsx', the labels are associated with
    % the following responses:
    %   1. Disgust.
    %   2. Fear.
    %   3. Sad. 
    %   4. Neutral. 
    %   5. Happy.
    %   6. Anger. 
    %   7. Surprise. 
    %
    % For the pre-trained model we only consider Disgust, Fear, Neutral &
    % Surprise; but we will also evaluate the other responses to see the result
    % these get. 
    % 
    % Inside the 'EEG.event' structure, the events with labels '1' will be 
    % treated as the start of a stimuli and labels '2' will be the end of the
    % previous stimuli. 
    % 
    % The order of the stimuli is provided by: 
    % "emotion_label_and_stimuli_order.xlsx", and it is different for every
    % group of trials.
    
    fprintf('\n===== Step 2: Select data =====\n\n');
    
    % Use the correct order of stimuli
    switch trial
        case 1
            stimuli = T1;
        case 2
            stimuli = T2;
        case 3
            stimuli = T3;
        case 4
            stimuli = T4;
    end
    
    % Iterate through markers
    for n = 1:2:size(EEG.event,2)-1
        
        % Select data
        data = pop_select(EEG,'time',[EEG.event(n).latency EEG.event(n+1).latency]/EEG.srate);
        
        % Group data in classes
        switch stimuli(round(n/2))
            case 1 
                S.disgust{n_disgust,1} = data.data;
                S.disgust{n_disgust,2} = floor(size(S.disgust{n_disgust,1},2)/(5*EEG.srate)); 
                n_disgust = n_disgust + 1;
            case 2
                S.fear{n_fear,1} = data.data;
                S.fear{n_fear,2} = floor(size(S.fear{n_fear,1},2)/(5*EEG.srate)); 
                n_fear = n_fear + 1;
            case 3
                S.sad{n_sad,1} = data.data;
                S.sad{n_sad,2} = floor(size(S.sad{n_sad,1},2)/(5*EEG.srate)); 
                n_sad = n_sad + 1;
            case 4 
                S.neutral{n_neutral,1} = data.data;
                S.neutral{n_neutral,2} = floor(size(S.neutral{n_neutral,1},2)/(5*EEG.srate)); 
                n_neutral = n_neutral + 1;
            case 5
                S.happy{n_happy,1} = data.data;
                S.happy{n_happy,2} = floor(size(S.happy{n_happy,1},2)/(5*EEG.srate)); 
                n_happy = n_happy + 1;
            case 6
                S.anger{n_anger,1} = data.data;
                S.anger{n_anger,2} = floor(size(S.anger{n_anger,1},2)/(5*EEG.srate)); 
                n_anger = n_anger + 1;
            case 7 
                S.surprise{n_surprise,1} = data.data;
                S.surprise{n_surprise,2} = floor(size(S.surprise{n_surprise,1},2)/(5*EEG.srate)); 
                n_surprise = n_surprise + 1;
        end
    end
    
    fprintf('\n Done... \n\n')
end

%% Step 3: 5 sec windows
fprintf('\n===== Step 3: Create windows =====\n\n');

disgust = cell(sum([S.disgust{:,2}]),1);
fear = cell(sum([S.fear{:,2}]),1);
sad = cell(sum([S.sad{:,2}]),1);
neutral = cell(sum([S.neutral{:,2}]),1);
happy = cell(sum([S.happy{:,2}]),1);
anger = cell(sum([S.anger{:,2}]),1);
surprise = cell(sum([S.surprise{:,2}]),1);

% Trial counter
n_disgust = 1;
n_fear = 1;
n_sad = 1;
n_neutral = 1;
n_happy = 1;
n_anger = 1;
n_surprise = 1;

for i = 1:size(fields(S),1)
    fl = fields(S);
    for j = 1:size(S.(fl{i}),1)
        start_eeg = 1;
        end_eeg = start_eeg + 5*EEG.srate - 1;
        for k = 1:S.(fl{i}){j,2}
            switch fl{i}
                case 'disgust'
                    disgust{n_disgust} = S.disgust{j}(:,start_eeg:end_eeg);
                    n_disgust = n_disgust + 1;
                case 'fear'
                    fear{n_fear} = S.fear{j}(:,start_eeg:end_eeg);
                    n_fear = n_fear + 1;
                case 'sad'
                    sad{n_sad} = S.sad{j}(:,start_eeg:end_eeg);
                    n_sad = n_sad + 1;
                case 'neutral'
                    neutral{n_neutral} = S.neutral{j}(:,start_eeg:end_eeg);
                    n_neutral = n_neutral + 1;
                case 'happy'
                    happy{n_happy} = S.happy{j}(:,start_eeg:end_eeg);
                    n_happy = n_happy + 1;
                case 'anger'
                    anger{n_anger} = S.anger{j}(:,start_eeg:end_eeg);
                    n_anger = n_anger + 1;
                case 'surprise'
                    surprise{n_surprise} = S.surprise{j}(:,start_eeg:end_eeg);
                    n_surprise = n_surprise + 1;
            end
            start_eeg = end_eeg + 1;
            end_eeg = start_eeg + 5*EEG.srate - 1;
        end
    end
end

fprintf('\n Done... \n\n')

%% Step 4: Save data
if strcmpi(savedata,'Yes')
    fprintf('\n===== Step 4: Save Data =====\n\n');
    
    savedir = 'D:\valid\seed_vii\EEG_windows';
    save([savedir '\disgust.mat'],'disgust')
    save([savedir '\fear.mat'],'fear')
    save([savedir '\sad.mat'],'sad')
    save([savedir '\neutral.mat'],'neutral')
    save([savedir '\happy.mat'],'happy')
    save([savedir '\anger.mat'],'anger')
    save([savedir '\surprise.mat'],'surprise')

    fprintf('\n Done... \n\n')
end

