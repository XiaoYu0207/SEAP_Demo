    function EEG = setup(EEG, icasphere, icaweights, icachansind)
    EEG.icasphere = icasphere;
    EEG.icaweights = icaweights;
    EEG.icawinv = pinv(EEG.icaweights * EEG.icasphere);
    EEG.icachansind = icachansind;
    EEG.icaact = eeg_getica(EEG);
    end