% EEGLAB history file generated on the 25-Dec-2022
% ------------------------------------------------

EEG.etc.eeglabvers = '2021.1'; % this tracks which version of EEGLAB is being used, you may ignore it
EEG = pop_loadbv('F:\New_data\', 'Hu_Hannn_2022-12-06_20-43-00.vhdr', [1 2523333], [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64]);
EEG.setname='XH';
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
EEG = pop_loadset('filename','XH.set','filepath','/Users/max/Desktop/Chan-64/data/XH/');
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Raw_data.set','filepath','/Users/max/Desktop/Chan-64/data/XH/');
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 250);
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Raw_data.set','filepath','/Users/max/Documents/GitHub/SEAP_Demo/data/Sub-1/');
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 200);
EEG = eeg_checkset( EEG );
EEG = pop_loadset('filename','Raw_data.set','filepath','/Users/max/Documents/GitHub/SEAP_Demo/data/Sub-1/');
EEG = eeg_checkset( EEG );
EEG = pop_resample( EEG, 200);
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/Users/max/Documents/0 Max/0 Research/1 Code/1 ToolBox/eeglab13_5_4b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
EEG = eeg_checkset( EEG );
figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
EEG = pop_select( EEG,'nochannel',{'F4' 'FC5' 'FC6' 'CP5' 'CP6' 'AF3' 'AF4' 'F6' 'C5' 'C6' 'P5' 'P6' 'PO5' 'PO6'});
EEG = eeg_checkset( EEG );

%%
EEG = pop_resample( EEG, 200);
EEG = eeg_checkset( EEG );
EEG=pop_chanedit(EEG, 'lookup','/Users/max/Documents/0 Max/0 Research/1 Code/1 ToolBox/eeglab13_5_4b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'nochannel',{'F5' 'F6' 'FC5' 'FC6' 'CP5' 'CP6' 'AF3' 'AF4' 'C5' 'C6' 'P5' 'P6' 'PO5' 'PO6' 'M1' 'M2'});
EEG = eeg_checkset( EEG );


%%