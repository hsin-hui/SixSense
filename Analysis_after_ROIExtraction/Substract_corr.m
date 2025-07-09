nii1_name='out.nii';
nii2_name='out_2.nii';
nii1=load_nii(nii1_name);
nii2=load_nii(nii2_name);
out=nii1;
out.img=(nii2.img-nii1.img);
save_nii(out,'out_substract.nii')
