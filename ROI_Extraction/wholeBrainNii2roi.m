% convert the output functional images from NIFTIGZ to NIFTI format
% linux terminal > find /home/commmunicationlab/Desktop/bids/derivatives/ -name '*_space-MNI152NLin6Asym_res-2_desc-preproc_bold.nii.gz' -exec fslchfiletype NIFTI {} ';'

% matlab
% set the current directory to roiExtraction
clear all

expdir='./'; % linus route should use'/'instead of'\'
froidir='schaefer100';

for si=[48:63]; % x:y means loop sub-x to sub-y
    % find the preprocessed functional images
    subj=sprintf('sub-%02d',si);
    
    % Define the expected file pattern for the subject
    %file_pattern = sprintf('%s/%s*desc-preproc_bold.nii', expdir, subj);
    file_pattern = sprintf('%s/%s*desc-preproc_clean.nii', expdir, subj);

    % Check if the files matching the pattern exist
    if isempty(dir(file_pattern))
        fprintf('Subject %s does not exist. Skipping...\n', subj);
        continue; % Skip to the next subject
    end
    
    %    ms=cellstr(ls([expdir '\mri\bids\derivatives\' subj '\func\*preproc_bold.nii']));
    %ms=cellstr(ls([expdir '/' subj '*desc-preproc_bold.nii']));
    ms=cellstr(ls([expdir '/' subj '*desc-pclean_bold.nii']));
    ms=strrep(ms,'.nii','');

    for mi=1;%1:length(ms);        
        % extract subject number and task name
        m=ms{mi};
        m_short=strsplit(m,{'_space'});
        m_short=m_short{1};

        f= ([expdir  m '.nii']);
        gdata_wholeBrain=nii2mat(f);
        gdata_wholeBrain(gdata_wholeBrain==0)=NaN;

        % according to the paper, we should perform z-score before
        % extrating ROIs!!
        gdata_wholeBrain = zscore(gdata_wholeBrain, 0, 2);

        % load roimask 
        for ri=[001:100]%:length(ls(sprintf('%s/%s/mat/*.mat',expdir,froidir)));
            load(sprintf('%s/%s/mat/roi%03d.mat',expdir,froidir,ri),'roimask');

            % apply the mask
            gdata=gdata_wholeBrain(roimask(:)>0,:);

            save(sprintf(['%s/ROI/%s_roi%03d.mat'],expdir,m_short,ri),'gdata');
            clear gdata
        end
    end
end


