function [Patameter comp Recommended_Artifact_Comp] = Run_ICA_ICASSO(EEG,runs,Comp,Result_file,Method)
% data: the data(Row<Column) to be processed,
% runs: the runs of fastICA
% maxComp: max component we set to run ICA
% nolinear: nolinear function choose
File = [Result_file filesep 'Result_' Method filesep ] ;
mkdir(File);
data = EEG.data' ;
%%
try
    [coeff, score, latent] = princomp(data);
catch
    [coeff, score, latent] = pca(data);
end
%%
save([File 'PCA'],'coeff','score','latent','-v7.3');
mkdir([File 'Iq/']);
mkdir([File 'sR/']);
mkdir([File 'A/']);
mkdir([File 'W/']);
mkdir([File 'S/']);
mkdir([File 'step/']);
for comp = Comp
    X=score(:,1:comp)';
    %       X=score(1:comp,:)';
    switch Method
        case 'FastICA'
            [sR,step]=icassoEst('both', X,runs, 'lastEig', comp, 'g','tanh', ...
                'approach', 'symm');
        case 'InfomaxICA'
            [sR step]=icassoEst_infomaxICA('both',X ,runs, 'lastEig', comp, 'g', 'tanh', ...
                'approach', 'symm');
        otherwise
            disp('Unknow method.');
    end
    %%
    sR=icassoExp(sR);
    [iq,A,W,S] = icassoShow(sR,'colorlimit',[0.1 0.3 0.5 0.7 0.9],'L',Comp);
    save([File 'sR/',int2str(comp)],'sR');
    save([File 'A/',int2str(comp)],'A');
    save([File 'W/',int2str(comp)],'W');
    save([File 'S/',int2str(comp)],'S');
    save([File 'step/',int2str(comp)],'step');
    save([File 'Iq/',int2str(comp)],'iq');
    Patameter(comp,1) = nanmean(iq);
    Patameter(comp,2) = nanstd(iq);
    Patameter(comp,3) = nanmean(step(step<100));
    Patameter(comp,4) = nanstd(step(step<100));
    Patameter(comp,5) = size(step(step<100),2);
    Patameter(comp,6) = sum(latent(1:comp))/sum(latent);
    %%
    NumChans = size(EEG.data,1) ;
    icachansind = 1:NumChans ;
    icasphere = eye(NumChans,NumChans) ;
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
    %% Plot Figures
    fs = EEG.srate ;
    chanlocs = EEG.chanlocs ;
    window = 3*fs ;
    noverlap = 2*fs ;
    nfft = 5*fs ;
    timeIndex = linspace(0,size(S,2)/fs,size(S,2)) ;
    mkdir([File filesep 'ICs_Figure'])
    for isComp = 1:Comp
        h = waitbar(isComp/Comp)
        figure('visible','off')
        set(gcf,'outerposition',get(0,'screensize'))
        subplot(231)
        set(gca,'fontsize',14)
        topoplot(A(:,isComp),chanlocs)
        colorbar
        title([Comp_Classification{isComp}])
        subplot(232)
        f_psd(double(S(isComp,:)),fs)
        set(gca,'fontsize',14)
        title(['PSD of Comp#' num2str(isComp)])
        subplot(233)
        spectrogram(double(S(isComp,:)),window,noverlap,nfft,fs)
        set(gca,'fontsize',14)
        xlim([0 60])
        title(['T-F of Comp#' num2str(isComp)])
        subplot(2,3,[4:6])
        plot(timeIndex,S(isComp,:))
        axis tight
        set(gca,'fontsize',14)
        xlabel('Time/Sec')
        ylabel(['Magnitude'])
        title(['Waveform of Comp#' num2str(isComp)])
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 16 9])
        saveas(gcf,[File filesep 'ICs_Figure' filesep 'Comp# ' num2str(isComp)],'png')
        close
    end
    close(h)
    %%
    pop_viewprops(EEG, 0, [1:Comp], [1 40]) ;
    Recommended_Artifact_Comp = find(Comp_Classification_Index == 3) ;
    save ([Result_file filesep 'ICA_Parameters'],'Recommended_Artifact_Comp','icasphere','icaweights','icachansind')
end
