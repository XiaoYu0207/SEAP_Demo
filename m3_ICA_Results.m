clc
clear
close all
tic
%%
pathname = [pwd filesep 'data'] ;
listing = dir(pathname) ;
filename = {listing(3:end).name} ;
filename = filename(~contains(filename, '.DS_Store'));
mkdir([pwd filesep 'Fig' filesep 'Spatial_FIltered_ICA'])
addpath([pwd filesep 'ICA_Toolbox'])
for isSub = 1%:length(filename)
    [num2str(isSub) '-' filename{isSub}]
    Comp = 15 ;
    EEG = pop_loadset([pwd filesep 'data' filesep filename{isSub} filesep  'FIR_filtered_1Hz.set'] );
    Fs = EEG.srate ;
    chanlocs = EEG.chanlocs ;
    Method = ['InfomaxICA'] ;
    pth = [ pwd filesep 'data' filesep filename{isSub} filesep 'Re_AVG_Result_' Method filesep ] ;
    NumChans = size(EEG.data,1) ;
    icachansind = 1:NumChans ;
    icasphere = eye(NumChans,NumChans) ;
    %% ICA Parameter Configuration
    load([pth 'PCA.mat'])
    load([pth 'S' filesep num2str(Comp) '.mat'])
    load([pth 'W' filesep num2str(Comp) '.mat'])
    mkdir([pth 'ICA_Comp'])
    B = inv(W) ;
    icaweights = W*coeff(:,1:Comp)' ; %W*coeff(:,1:Comp)' ;
    A = coeff(:,1:Comp)*B ;
    EEG = setup_ICA_parameters(EEG, icasphere, icaweights, icachansind) ;
    EEG.icaact = eeg_getica(EEG);
    EEG = eeg_checkset( EEG );
    EEG = pop_iclabel(EEG, 'default');
    %% ICs Classification
    classes  = (EEG.etc.ic_classification.ICLabel.classes) ;
    Probability = (EEG.etc.ic_classification.ICLabel.classifications) ;
    for isComp = 1:Comp
        [C,I] = max(squeeze(Probability(isComp,:))) ;
        Comp_Classification_Index(isComp,:) = I ;
        Comp_Classification{isComp,:} = classes{I} ;
    end
    % Manually check and automatically recognize IC using by IClabel Toolbox
    if  strcmp(filename{isSub},'Sub-3')
        Recommended_Artifact_Comp = [ 1 3];
    else
        Recommended_Artifact_Comp = find(Comp_Classification_Index == 3 | Comp_Classification_Index == 4) ;
    end
    Artifact_Comp{isSub,:} = Recommended_Artifact_Comp ;
    %% Visualizing each IC
    window = 3*Fs ;
    noverlap = 2*Fs ;
    nfft = 5*Fs ;
    for isComp = 1:Comp
        isComp
        figure('visible','off')
        set(gcf,'outerposition',get(0,'screensize'))
        subplot(231)
        set(gca,'fontsize',12)
        topoplot(A(:,isComp),chanlocs);
        colorbar
        title([Comp_Classification{isComp}])
        subplot(232)
        f_psd(double(S(isComp,:)),Fs);
        title(['PSD of Comp#' num2str(isComp)])
        subplot(233)
        spectrogram(double(S(isComp,:)),window,noverlap,nfft,Fs);
        xlim([0 60])
        title(['T-F of Comp#' num2str(isComp)])
        subplot(2,3,[4:6])
        plot(EEG.times./EEG.srate,S(isComp,:))
        axis tight
        set(gca,'fontsize',12)
        xlabel('Time/Sec')
        ylabel(['Magnitude'])
        title(['Waveform of Comp#' num2str(isComp)])
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
        saveas(gcf,[pth 'ICA_Comp' filesep 'Comp# ' num2str(isComp)],'png')
    end
    close all
    %% Comparison of ICA effects
    % Waveform of before ICA
    temp_data = EEG.data;
    figure
    set(gcf,'outerposition',get(0,'screensize'))
    subplot(211)
    plot(EEG.times./EEG.srate,temp_data')
    set(gca,'fontsize',16)
    xlim([0 max(EEG.times./EEG.srate)])
    xlabel('Time/Sec')
    ylabel(['Magnitude'])
    title(['Waveform of before ICA'])
    axis tight
    EEG = pop_subcomp( EEG, [Recommended_Artifact_Comp], 0);
    EEG = eeg_checkset( EEG );
    icaact = eeg_getica(EEG);
    EEG.icaact = icaact ;
    EEG = eeg_checkset( EEG );
    clear Recommended_Artifact_Comp

    % Waveform of after ICA
    temp_Clean_data = EEG.data ;
    subplot(212)
    plot(EEG.times./EEG.srate,temp_Clean_data')
    set(gca,'fontsize',16)
    xlim([0 max(EEG.times./EEG.srate)])
    xlabel('Time/Sec')
    ylabel(['Magnitude'])
    title(['Waveform of after ICA'])
    axis tight
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
    saveas(gcf,[pwd filesep 'Fig' filesep 'Spatial_FIltered_ICA' filesep num2str(isSub)],'png')
    close
    EEG = pop_saveset( EEG, 'filename','Spatial_filtered_ICA.set','filepath',[pwd filesep 'data' filesep filename{isSub} filesep]);
    clearvars -except  pathname filename isSub Artifact_Comp
end
save Artifact_Comp Artifact_Comp
%%
toc