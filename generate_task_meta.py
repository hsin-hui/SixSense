#filter-1

import os
import json
from glob import glob
from collections import defaultdict

# Adjust these paths for your dataset
fmriprep_dir = '/media/commmunicationlab/My Passport/SixSense_bids/derivatives'
smooth_dir = '/media/commmunicationlab/My Passport/SixSense_bids/derivatives/afni-nosmooth'
output_json = '/media/commmunicationlab/My Passport/SixSense_bids/derivatives/task_meta.json'

task_meta = defaultdict(dict)

for subj in sorted(os.listdir(fmriprep_dir)):
    if not subj.startswith('sub-'):
        continue

    func_dir = os.path.join(fmriprep_dir, subj, 'func')
    if not os.path.exists(func_dir):
        continue

    # Search for all tasks present for this subject
    confound_paths =glob(os.path.join(func_dir, f"{subj}_task-movie*_desc-confounds_timeseries.tsv"))

    for confound_file in confound_paths:
        filename = os.path.basename(confound_file)
        task = filename.split('_')[1].replace('task-', '')

        if subj not in task_meta[task]:
            task_meta[task][subj] = {
                'bold': {
                    'MNI152NLin6Asym': {'preproc': [], 'sm6': []}
                },
                'confounds': [],
                'condition': 'n/a'
            }

        # Add confounds
        task_meta[task][subj]['confounds'].append(confound_file)

        # BOLD files - MNI
        mni_preproc = glob(os.path.join(func_dir, f"{subj}_task-movie*_space-MNI152NLin6Asym*_desc-preproc_bold.nii"))
        mni_sm6 = glob(os.path.join(smooth_dir, subj, 'func', f"{subj}_task-movie*_space-MNI152NLin6Asym*_desc-sm6_bold.nii"))

        task_meta[task][subj]['bold']['MNI152NLin6Asym']['preproc'].extend(mni_preproc)
        task_meta[task][subj]['bold']['MNI152NLin6Asym']['sm6'].extend(mni_sm6)

     
# Save JSON
with open(output_json, 'w') as f:
    json.dump(task_meta, f, indent=2)

print(f"Saved task_meta.json to {output_json}")
