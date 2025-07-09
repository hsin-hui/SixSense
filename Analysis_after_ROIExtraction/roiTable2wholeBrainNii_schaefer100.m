function out=roiTable2wholeBrainNii_schaefer100(roiTable);

atlas=load_nii(['tpl-MNI152NLin6Asym_res-02_atlas-Schaefer2018_desc-100Parcels7Networks_dseg.nii']);
out=atlas;
out.img(:)=NaN; % NaN might cause errors in some program. replace NaN with 0 if necessary.
out.img=double(out.img);
out.hdr.dime.datatype=64;
out.hdr.dime.bitpix=64;

for ri=1:length(roiTable(:,1));
    out.img(atlas.img==roiTable(ri,1))=roiTable(ri,2);
end
save_nii(out,'out.nii');

% Run the following code:
% load Whole_results_C1within.mat
% results_no_pval = results(:, 1:(end-1)); % Exclude the last column (assumed to be p-values) from processing
% r = nanmean(results_no_pval, 2);
% roitable = [(1:length(r))' r];
% out = roiTable2wholeBrainNii_schaefer100(roitable);

