import os
from pathlib import Path
import subprocess

# ==== Configuration ====
fwhm = 7  # target global smoothness
base_dir = Path('/home/commmunicationlab/Desktop/SixSense_bids/derivatives/filter')  # source from regression # or smoothing before filter depends on the process
output_root = Path('/home/commmunicationlab/Desktop/SixSense_Version02/derivatives_smoothing/derivatives_smoothing')  # new target

subjects = [f"sub-{i:02d}" for i in range(1, 64) if i not in [5, 10, 14, 25, 42, 58]]
space = 'MNI152NLin6Asym'

# ==== Loop over subjects ====
for subj in subjects:
    input_dir = base_dir / subj / 'func'
    output_dir = output_root / subj / 'func'
    output_dir.mkdir(parents=True, exist_ok=True)

    # Search for all desc-clean BOLD files
    bold_files = sorted(input_dir.glob(f"{subj}_task-movie*_space-{space}_res-2_desc-clean_bold.nii"))
    
    if not bold_files:
        print(f"[WARNING] No clean BOLD files found for {subj}, skipping...")
        continue

    for bold_file in bold_files:
        mask_file = input_dir / bold_file.name.replace("desc-clean_bold.nii", "desc-brain_mask.nii")
        if not mask_file.exists():
            print(f"[WARNING] Missing mask: {mask_file.name}, skipping...")
            continue

        smoothed_file = output_dir / bold_file.name.replace("desc-clean", f"desc-sm{fwhm}")

        if smoothed_file.exists():
            print(f"[INFO] Smoothed file exists: {smoothed_file.name}, skipping.")
            continue

        cmd = [
            "3dBlurToFWHM",
            "-mask", str(mask_file),
            "-FWHM", str(fwhm),
            "-input", str(bold_file),
            "-prefix", str(smoothed_file),
            "-blurmaster", str(bold_file),
            "-detrend",
            "-bmall"
        ]

        print(f"[RUNNING] Smoothing {bold_file.name} → {smoothed_file.name}")
        try:
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError:
            print(f"[ERROR] Smoothing failed for {bold_file.name}")
            continue

print("\n✅ All smoothing completed.")
