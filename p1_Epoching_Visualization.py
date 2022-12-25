import mne
from os import listdir
import os
import numpy as np
import matplotlib.pyplot as plt

#%% load data
pathname = os.path.join(os.getcwd(),'data')
filename = listdir(pathname)
filename.remove('.DS_Store')

for isSub in range(1): #range(len(filename)):
    isSub = 0
    print(isSub)
    SF = mne.io.read_raw_eeglab(os.path.join(pathname,filename[isSub],'Spatial_filtered_ICA.set'))
    # set montage or referer to as load channel locations
    montage = mne.channels.make_standard_montage('standard_1020')
    SF.set_montage(montage)
    events, event_id = mne.events_from_annotations(SF)
    tmin = -0.1
    tmax = 0.6
    baseline = (None, 0)
    epochs = mne.Epochs(SF,events=events,event_id=event_id,
                        tmin=tmin,tmax=tmax,baseline=baseline,preload=True)
    #%% Removing paired epochs using threshold
    Full_epochs = epochs.copy()
    epochs.drop_bad(reject=dict(eeg=100e-6))
    # epochs.plot_drop_log()
    Bad_Epc_Idx = [n for n, dl in enumerate(epochs.drop_log) if len(dl)]
    # case1: If it is a deviant stimulus, remove it and the proceeding and following standard stimuli;
    # case2: If it is a standard stimulus proceeding a deviance, remove it and
    # the following deviance;
    Bad_Epc_Idx_Append = np.array([]).astype(int)
    for is_Bad_Epc_Idx in range(len(Bad_Epc_Idx)):
        if Full_epochs.events[Bad_Epc_Idx[is_Bad_Epc_Idx],2] == 2:
            Bad_Epc_Idx_Append = np.append(Bad_Epc_Idx_Append,[Bad_Epc_Idx[is_Bad_Epc_Idx]-1,Bad_Epc_Idx[is_Bad_Epc_Idx]+1])
        elif (Full_epochs.events[Bad_Epc_Idx[is_Bad_Epc_Idx],2] == 1) & (Full_epochs.events[Bad_Epc_Idx[is_Bad_Epc_Idx]+1,2] == 2):
            Bad_Epc_Idx_Append = np.append(Bad_Epc_Idx_Append,[Bad_Epc_Idx[is_Bad_Epc_Idx]+1])

    Full_epochs.drop(Bad_Epc_Idx[:] + Bad_Epc_Idx_Append.tolist())
    del epochs
    #%% Extracting Epochs
    FFR_ASSR = Full_epochs['s11']
    DEV = Full_epochs['s12']

    All_STD_Idx = np.asarray(np.where(Full_epochs.events[:,2] == 1)).squeeze()
    DEV_Idx = np.asarray(np.where(Full_epochs.events[:,2] == 2)).squeeze()
    STD_ProC_DEV = Full_epochs[DEV_Idx-1]
    STD_N1_P2 = Full_epochs[np.setdiff1d(All_STD_Idx, (DEV_Idx+1))]
    #%% Visualization of Waveform
    STD_N1_P2.average().plot()
    STD_N1_P2.average().plot_joint()
    STD_N1_P2.average().plot(gfp=True)

    DEV.average().plot()
    DEV.average().plot_joint()
    DEV.average().plot(gfp=True)
    #%% Plot waveforms of STD, DEV and Difference Waveforms
    DW_ST = DEV.copy()
    DW_ST._data = DEV._data - STD_ProC_DEV._data
    evokeds = dict(STD=list(STD_N1_P2.iter_evoked()),
                   DEV=list(DEV.iter_evoked()),
                   DIFF=list(DW_ST.iter_evoked()) )
    # Waveforms
    fig = plt.figure()
    ax1 = fig.add_subplot(2, 1, 1)
    mne.viz.plot_compare_evokeds(evokeds, picks='FCz',ylim=(dict(eeg=[-5, 5])),show_sensors=True,axes=ax1)
    # Topographies
    ax2 = fig.add_subplot(2, 3, 4)
    ax3 = fig.add_subplot(2, 3, 5)
    ax4 = fig.add_subplot(2, 3, 6)
    STD_N1_P2.average().plot_topomap(0.11,sensors=False,size=2,axes=ax2,colorbar=False,vlim=(-2,2))
    ax2.set_title('N1')
    STD_N1_P2.average().plot_topomap(0.16,sensors=False,size=2,axes=ax3,colorbar=False,vlim=(-2,2))
    ax3.set_title('P2')
    DEV.average().plot_topomap(0.5,sensors=False,size=2,axes=ax4,colorbar=False,vlim=(-2,2))
    ax4.set_title('MMN')