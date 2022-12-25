function [  ] = Remove_IC(EEG,Index_Artifact_Comp,pathname)
%% Remove Artifact ICs
TimeIndex = linspace(0,size(EEG.data,2)/EEG.srate,size(EEG.data,2)) ;
figure
set(gcf,'outerposition',get(0,'screensize'))
subplot(211)
plot(TimeIndex,EEG.data')
plot(TimeIndex,EEG.data')
axis tight
set(gca,'fontsize',18)
ylabel(['Amplitude/','\muV']);
title('Raw EEG waveform')
load([pathname filesep 'ICA_Parameters'])
EEG.icasphere = icasphere;
EEG.icaweights = icaweights;
EEG.icawinv = pinv(EEG.icaweights * EEG.icasphere);
EEG.icachansind = icachansind;
EEG.icaact = eeg_getica(EEG);
EEG = pop_subcomp( EEG, [Index_Artifact_Comp], 0);
EEG = eeg_checkset( EEG );
icaact = eeg_getica(EEG);
EEG.icaact = icaact ;
EEG = eeg_checkset( EEG );
%% Plot Spatial filtered by ICA
subplot(212)
plot(TimeIndex,EEG.data')
axis tight
set(gca,'fontsize',18)
xlabel('Time/Sec')
ylabel(['Amplitude/','\muV']);
title('Spatial filtered ICA')
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
% saveas(gcf,[pwd filesep 'Spatial_filtered_ICA' filesep num2str(isSub)],'png')
EEG = pop_saveset( EEG, 'filename','Spatial_filtered_ICA.set','filepath',[pathname]);
end