import os
from pathlib import Path
import subprocess

# ==== Configuration ====
fwhm = 7  # target global smoothness (in mm)
base_dir = Path('/home/commmunicationlab/Desktop/sixSense_roiExtraction')  # <<== CHANGE to your actual project root
input_dir = base_dir  # Input files (desc-clean_bold.nii) are all here
output_dir = base_dir / 'derivatives_smoothing'  # Output smoothed files saved here
output_dir.mkdir(parents=True, exist_ok=True)

# ==== Loop over all cleaned BOLD files ====
clean_files = sorted(input_dir.glob("*desc-clean_bold.nii"))

if not clean_files:
    print("[WARNING] No desc-clean_bold.nii files found in base dir.")

for bold_file in clean_files:
    # Determine corresponding brain mask
    mask_file = bold_file.with_name(bold_file.name.replace("desc-clean_bold.nii", "desc-brain_mask.nii"))
    if not mask_file.exists():
        print(f"[WARNING] Mask file missing for {bold_file.name}, skipping...")
        continue

    # Define output file name
    smoothed_file = output_dir / bold_file.name.replace("desc-clean", f"desc-sm{fwhm}")

    if smoothed_file.exists():
        print(f"[INFO] Smoothed file already exists: {smoothed_file.name}, skipping.")
        continue

    # Construct smoothing command
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
    subprocess.run(cmd, check=True)

print("\n✅ Smoothing completed for all files.")