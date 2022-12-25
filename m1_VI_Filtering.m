clc
clear
close all
tic
%% Readme
% For saving memory, we down-sampled data as 200Hz, and reomove following
% channels: {'F5' 'F6' 'FC5' 'FC6' 'CP5' 'CP6' 'AF3' 'AF4' 'C5' 'C6' 'P5' 'P6' 'PO5' 'PO6' 'M1' 'M2'}
pathname = [pwd filesep 'data'] ;
listing = dir(pathname) ;
filename = {listing(3:end).name} ;
filename = filename(~contains(filename, '.DS_Store'));
mkdir([pwd filesep 'Fig' filesep 'Filtering'])
for isSub = 1:length(filename)
    [num2str(isSub) '-' filename{isSub}]
    EEG = pop_loadset('filename',['Raw_data.set'],'filepath',[pathname filesep filename{isSub} filesep]);
    EEG = pop_select( EEG,'nochannel',{'EOG'}); % Drop Useless channels
    EEG = eeg_checkset( EEG );
    figure('visible','off')
    set(gcf,'outerposition',get(0,'screensize'))
    subplot(311)
    plot(EEG.times./EEG.srate,EEG.data')
    set(gca,'fontsize',16)
    xlim([0 max(EEG.times./EEG.srate)])
    xlabel('Time/Sec')
    ylabel(['Magnitude'])
    title(['Raw Waveform of '  filename{isSub}])
    axis tight
    %% Visual Inspection
    if  strcmp(filename{isSub},'Sub-1')
        EEG = eeg_eegrej( EEG, [1 25*EEG.srate; 2500*EEG.srate size(EEG.data,2)] );
    elseif strcmp(filename{isSub},'Sub-2')
        EEG = eeg_eegrej( EEG, [1 15*EEG.srate; 2490*EEG.srate size(EEG.data,2)] );
    end
    EEG = eeg_checkset( EEG );

    subplot(312)
    plot(EEG.times./EEG.srate,EEG.data')
    set(gca,'fontsize',16)
    xlim([0 max(EEG.times./EEG.srate)])
    xlabel('Time/Sec')
    ylabel(['Magnitude'])
    title(['VI Waveform of '  filename{isSub}])
    axis tight
    %% Filtering
    freqLow = 1;
    %     freqHigh = 250 ;
    EEG  = pop_basicfilter( EEG,  1:size(EEG.data,1) , 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180, 'RemoveDC', 'on' ); % GUI: 15-May-2020 15:58:29
    EEG = eeg_checkset( EEG );
    EEG  = pop_basicfilter( EEG,  1:size(EEG.data,1) , 'Boundary', 'boundary', 'Cutoff',  freqLow, 'Design', 'fir', 'Filter', 'highpass', 'Order',  2048, 'RemoveDC', 'on' ); % GUI: 15-May-2020 16:00:18
    EEG = eeg_checkset( EEG );
    %     EEG  = pop_basicfilter( EEG,  1:size(EEG.data,1) , 'Boundary', 'boundary', 'Cutoff',  freqHigh, 'Design', 'fir', 'Filter', 'lowpass', 'Order',  2048, 'RemoveDC', 'on' ); % GUI: 15-May-2020 16:02:04
    %     EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'lookup',which('standard-10-5-cap385.elp'));
    EEG = eeg_checkset( EEG );
    %% Re-reference to Average
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG )

    subplot(313)
    plot(EEG.times./EEG.srate,EEG.data')
    set(gca,'fontsize',16)
    xlim([0 max(EEG.times./EEG.srate)])
    xlabel('Time/Sec')
    ylabel(['Magnitude'])
    title(['Filtered Waveform of '  filename{isSub}])
    axis tight
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
    saveas(gcf,[pwd filesep 'Fig' filesep 'Filtering' filesep num2str(isSub)],'png')
    close all
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',['FIR_filtered_1Hz.set'],'filepath',[pwd filesep 'data' filesep filename{isSub} filesep ]);
    clearvars -except isSub pathname filename label
end
%%
toc