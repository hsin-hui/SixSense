% pattern similarity analysis in cortical brain parcels (Schaefer et al 2018)
% written by Asieh Zadbood
% for lopping rois: 
    % Loop through all ROIs 1 to 100
    % for rr = 1:100
    %     fprintf('\n--- Running RSA for ROI #%d ---\n', rr);
    %     rsa_parcel(rr);
    % end
function rsa_parcel(rr) 
rand('state', sum(100*clock));
rng(sum(100*clock)+rr,'twister');

%% setting up
cond1=1; % spoiled
cond2=2; % twist
cond3=3; % no-twist

% which events
impscenes = [1 4 5 6 9 12 16];

% setting paths
basepath = '/Volumes/Transcend/'; addpath(basepath);
addpath('/Volumes/Transcend/ROI');addpath('/Volumes/Transcend/schaefer100');
addpath('/Volumes/Transcend/sixthsense-main');

% loading rois score
roi_fnames = 'Schaefer_100_icm152'; 
roi_mask = load_nii(fullfile(basepath,'schaefer100',[roi_fnames '.nii']));
mask = reshape(roi_mask.img,[],1);
fprintf([' rois read from : ' roi_fnames '\n']);

% read event info
load(fullfile(basepath,'movie_events.mat'));
fid = fopen(fullfile(basepath,'testnames_cleanmotion.txt'));
data = textscan(fid,'%s%s%s%s','HeaderLines',0,'CollectOutput',1);
data = data{:};
fclose(fid);
mevents = movie_events;
mevents(end,end)=2266; % cut movie end before the final scene for all groups

%keyboard % this is used to pause the script and ckeck the workspace

% create name lists for each condition
conds = str2double(data(:,3)); % gpt said that this method is better
names1 = data(conds == cond1, 2);
names2 = data(conds == cond2, 2);
names3 = data(conds == cond3, 2);
%names1 = data(str2num(cell2mat(data(:,3)))==cond1,2); 
%names2 = data(str2num(cell2mat(data(:,3)))==cond2,2);
%names3 = data(str2num(cell2mat(data(:,3)))==cond3,2);

%% read TR by TR and avg movie data, avg all for no-twist to get the G
for subj=1:length(names1) % spoiled condition
    S = load(fullfile(basepath, 'ROI', [names1{subj} '_task-movie_roi' sprintf('%03d', rr) '.mat']));
    subj_tcc = double(S.gdata);  % convert to double if needed
    %load(fullfile(basepath,'ROI', [names1{subj} '_task-movie_roi' sprintf('%03d', rr) '.mat'])); %loading roi data

    for e=1:length(impscenes)
        avgdata(:,e) = mean(subj_tcc(:,mevents(impscenes(e),1):mevents(impscenes(e),2)),2); % selecting events and average timecourse within events
    end
    mgroup1_tr{subj} = subj_tcc;  % because subjects' timecouse are different
    %mgroup1_tr(:,:,subj) = subj_tcc; % keep the entire timecourse data
    mgroup1_avg(:,:,subj) = avgdata; % keep the scene averaged data
end

for subj=1:length(names2) % twist condition
    S = load(fullfile(basepath, 'ROI', [names2{subj} '_task-movie_roi' sprintf('%03d', rr) '.mat']));
    subj_tcc = double(S.gdata);  % convert to double if needed
    %load(fullfile(basepath,'ROI', [names2{subj} '_task-movie_roi' sprintf('%03d', rr) '.mat'])); %loading roi data

    for e=1:length(impscenes)
        avgdata(:,e) = mean(subj_tcc(:,mevents(impscenes(e),1):mevents(impscenes(e),2)),2); % selecting events and average timecourse within events
    end
    mgroup1_tr{subj} = subj_tcc;  % because subjects' timecouse are different
    %mgroup2_tr(:,:,subj) = subj_tcc; % keep the entire timecourse data
    mgroup2_avg(:,:,subj) = avgdata; % keep the scene averaged data
end

for subj=1:length(names3) % no-twist condition
    S = load(fullfile(basepath, 'ROI', [names3{subj} '_task-movie_roi' sprintf('%03d', rr) '.mat']));
    subj_tcc = double(S.gdata);  % convert to double if needed
    %load(fullfile(basepath,'ROI', [names3{subj} '_task-movie_roi' sprintf('%03d', rr) '.mat'])); %loading roi data
    
    for e=1:length(impscenes)
        avgdata(:,e) = mean(subj_tcc(:,mevents(impscenes(e),1):mevents(impscenes(e),2)),2); % selecting events and average timecourse within events
    end
    mgroup1_tr{subj} = subj_tcc;  % because subjects' timecouse are different
    %mgroup3_tr(:,:,subj) = subj_tcc; % keep the entire timecourse data
    mgroup3_avg(:,:,subj) = avgdata; % keep the scene averaged data
    clear subj_tcc
end
fprintf(' movie data read \n');

%% correlations

% %%%%%%%%%%%%%% MOVIE %%%%%%%%%%%%%%%%%%
[all.mm.diag_sub_m2m3,all.mm.pval_m2m3] = corr_one2avgofothers(mgroup2_avg,mgroup3_avg,1,0,'m2m3'); % avg of all others
[all.mm.diag_sub_m2m1,all.mm.pval_m2m1] = corr_one2avgofothers(mgroup2_avg,mgroup1_avg,1,0,'m2m1'); % avg of all others
[all.mm.realdiff, all.mm.pvaldiff] = non_param_t(all.mm.diag_sub_m2m3,all.mm.diag_sub_m2m1,1); % based on vec1-vec2, type=1 paired,type2=unpaired
[all.mm.realdiff_z, all.mm.pvaldiff_z] = non_param_t(atanh(all.mm.diag_sub_m2m3),atanh(all.mm.diag_sub_m2m1),1); % based on vec1-vec2, type=1 paired,type2=unpaired

save(fullfile(basepath,'results','rsa','rois',['pattern_corr_imp_' roi_fnames '_' sprintf('%03d', rr) '.mat']),'all');



