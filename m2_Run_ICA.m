clc
clear
close all
tic
%%
pathname = [pwd filesep 'data'] ;
listing = dir(pathname) ;
filename = {listing(3:end).name} ;
filename = filename(~contains(filename, '.DS_Store'));

for isSub = 1:length(filename)
    % Set path
    [num2str(isSub) '-' filename{isSub}]
    runs = 2 ;
    Comp = 15 ;
    EEG = pop_loadset([pwd filesep 'data' filesep filename{isSub} filesep  'FIR_filtered_1Hz.set'] );
    Method = ['InfomaxICA'] ;
    data = EEG.data ;
    Result_file = [ pwd filesep 'data' filesep filename{isSub} filesep 'Re_AVG_Result_'  Method filesep] ;
    [Patameter comp] = ChooseComp(data',runs,Comp,Result_file,Method)
    clearvars -except isSub pathname filename
    close all
end

%%
toc