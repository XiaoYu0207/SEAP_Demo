function [Patameter comp Recommended_Artifact_Comp] = ChooseComp(data,runs,Comp,Result_file,Method)
% data: the data(Row<Column) to be processed,
% runs: the runs of fastICA
% maxComp: max component we set to run ICA
% nolinear: nolinear function choose
File = [Result_file filesep  ] ;
mkdir(File);
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
end
