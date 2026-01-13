# **Preprocessing the SEED VII EEG dataset**
These are the codes I used to preprocess the SEED VII EEG dataset (https://bcmi.sjtu.edu.cn/home/seed/seed-vii.html). 
___________
The preprocessing steps are **(Step1_Preprocessing.m)**: 

    1. Bandpass filter @ 1-50 Hz (pop_eegfiltnew).
    2. Rereference using common average (pop_reref).
    3. Bandstop filter @ 50 Hz (CleanLine).
    4. Independent Component Analysis (runica - infomax extended).
    5. Dipole fitting (dipfit).
    6. ICLabel.
___________
After that, I manually reviewed all components and rejected those suspicious **(Step2_ReviewICA.m)**. You can find the rejected components in **rejected.md**.
___________
Finally I selected the data corresponding to each emotional state from the original dataset **(Step3_SegmentData.m)**:

     1. Disgust.
     2. Fear.
     3. Sad. 
     4. Neutral. 
     5. Happy.
     6. Anger. 
     7. Surprise. 
___________
With the data preprocessed and segmented, I evaluated a pre-trained Neural Network to label the EEG windows with an emotion **(Step4_Evaluation.m)**. 

___________
by: Diego Caro López, 13-Jan-2026.

Queries: dgcarolp@hotmail.com // A00833057@exatec.tec.mx
