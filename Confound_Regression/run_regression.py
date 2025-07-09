#filter-3

import os
from os.path import basename, exists, join
from os import chdir
from subprocess import run
from glob import glob

# -------- CONFIGURATION -------- #
base_dir = '/media/commmunicationlab/My Passport/SixSense_bids/derivatives'
space = 'MNI152NLin6Asym'
afni_pipe = 'filter'
subjects = [f"sub-{i:02d}" for i in range(1, 63) if i != [5, 10, 14, 25, 42, 58]]  # sub-01 to sub-12, skip sub-07
# -------------------------------- #

for subject in subjects:
    input_dir = join(base_dir, subject, 'func')
    afni_dir = join(base_dir, afni_pipe, subject, 'func')

    print(f"\n[INFO] Subject: {subject}, Space: {space}, Pipeline: {afni_pipe}")

    if not exists(input_dir):
        print(f"[WARNING] Input directory not found: {input_dir}")
        continue
    if not exists(afni_dir):
        print(f"[WARNING] AFNI output directory not found: {afni_dir}")
        continue

    chdir(afni_dir)

    bold_fns = glob(join(input_dir, f"{subject}_task-movie*_space-{space}_res-2_desc-preproc_bold.nii"))
    if not bold_fns:
        print(f"[WARNING] No BOLD files found in {input_dir}")
        continue
    else:
        print(f"[INFO] Found {len(bold_fns)} BOLD files")

    for bold_fn in bold_fns:
        print(f"\n[INFO] Processing BOLD: {basename(bold_fn)}")
        filename = basename(bold_fn)

        model_fn = join(afni_dir, filename.split('_space')[0] + '_desc-model_timeseries.1D')
        if not exists(model_fn):
            print(f"[ERROR] Missing model file: {model_fn}")
            continue
        print(f"[DEBUG] Using model file: {model_fn}")

        #clean_fn = join(afni_dir, filename.replace('desc-preproc', 'desc-clean'))
        output_dir = join('/media/commmunicationlab/My Passport/SixSense_postregression_cleanfile', subject)
        os.makedirs(output_dir, exist_ok=True)
        clean_fn = join(output_dir, filename.replace('desc-preproc', 'desc-clean'))

        task = [s for s in filename.split('_') if s.startswith('task-')][0].replace('task-', '')
        mask_files = glob(join(input_dir, f"{subject}_task-movie*_space-{space}_res-2_desc-brain_mask.nii.gz"))
        if not mask_files:
            print(f"[ERROR] Missing brain mask for: {subject}")
            continue
        mask_fn = mask_files[0]  # pick the first match
        print(f"[DEBUG] Using mask file: {mask_fn}")

        #mask_fn = glob(join(input_dir, f"{subject}_task-movie*_space-{space}_res-2_desc-brain_mask.nii.gz"))
        #if not exists(mask_fn):
        #    print(f"[ERROR] Missing brain mask: {mask_fn}")
        #    continue
        #print(f"[DEBUG] Using mask file: {mask_fn}")

        print(f"[INFO] Running 3dTproject on {filename}")
        result = run(f"3dTproject -input {bold_fn} -ort {model_fn} -mask {mask_fn} "
                     f"-prefix {clean_fn} -polort 2 -overwrite", shell=True)

        if result.returncode != 0:
            print(f"[ERROR] 3dTproject failed for {filename}")
        else:
            print(f"[DONE] Created: {basename(clean_fn)}")
