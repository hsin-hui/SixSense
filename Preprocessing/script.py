
import os
import subprocess
from pathlib import Path

# User inputs
bids_root_dir = Path(r"/home/commmunicationlab/Desktop/SixSense_bids")
subjects = [f"{i:02d}" for i in [1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 59, 60, 61, 62, 63]]
#subjects = [str(01)]
#[str(i) for i in range(35, 36)]
#str(i) for i in range(1, 63)
nthreads = 20
mem_gb = 28  # GB
container = "docker"  # docker or singularity
owner_user = "commmunicationlab"
owner_group = "commmunicationlab"

# Debug: Print paths
print(f"BIDS root directory: {bids_root_dir}")
print(f"Subjects: {subjects}")
print(f"Number of threads: {nthreads}")
print(f"Memory: {mem_gb} GB")
print(f"Container: {container}")

# Convert virtual memory from GB to MB
if not isinstance(mem_gb, int):
    print("Error: Memory input is not a valid number.")
    exit(1)
mem_mb = int(mem_gb * 1000)  # Corrected conversion

# Ensure bids_root_dir exists
if not bids_root_dir.is_dir():
    print(f"Error: BIDS root directory '{bids_root_dir}' does not exist.")
    exit(1)

# Ensure FS_LICENSE file exists
fs_license_file = Path("/home/commmunicationlab/Downloads/license.txt")
if not fs_license_file.is_file():
    print(f"Error: FreeSurfer license file '{fs_license_file}' does not exist.")
    exit(1)

# Validate container input
if container not in ["docker", "singularity"]:
    print("Error: Container must be either 'docker' or 'singularity'.")
    exit(1)

# Create output directory if it doesn't exist
output_dir = bids_root_dir / "derivatives"
output_dir.mkdir(parents=True, exist_ok=True)

# Define the latest output spaces
output_spaces = "MNI152NLin6Asym:res-2"

# Function to run commands
def run_command(command):
    try:
        result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print(result.stdout.decode())
    except subprocess.CalledProcessError as e:
        print(f"Command failed with error: {e.stderr.decode()}")
        exit(1)

# Loop through each subject and run fmriprep
for subj in subjects:
    print(f"Processing subject: {subj}")

    if container == "singularity":
        singularity_image = Path("/home/commmunicationlab/fmriprep.simg")
        if not singularity_image.is_file():
            print(f"Error: Singularity image '{singularity_image}' does not exist.")
            exit(1)
        
        # Construct singularity command
        singularity_cmd = [
            "singularity", "run",
            "-B", "/home/communicationlab/.cache/templateflow:/opt/templateflow",
            str(singularity_image),
            str(bids_root_dir), str(output_dir),
            "participant",
            "--participant-label", subj,
            "--skip-bids-validation",
            "--me-output-echos",
            "--md-only-boilerplate",
            f"--fs-license-file={fs_license_file}",
            "--fs-no-reconall",
            "--output-spaces", output_spaces,
            f"--nthreads={nthreads}",
            "--stop-on-first-crash",
            f"--mem-mb={mem_mb}",
              # Enable fieldmap-less correction
            "-w", "/home/om"
        ]
        run_command(singularity_cmd)
        
    else:  # Assuming container == "docker"
        docker_image = "nipreps/fmriprep:latest"
        
        # Construct docker command with sudo
        docker_cmd = [
            "sudo", "docker", "run", "--rm",
            "-v", f"{bids_root_dir}:{bids_root_dir}",
            "-v", f"{output_dir}:{output_dir}",
            "-v", f"{fs_license_file}:/opt/freesurfer/license.txt",
            "-v", "/home/communicationlab/.cache/templateflow:/opt/templateflow",
            docker_image,
            str(bids_root_dir), str(output_dir),
            "participant",
            "--participant-label", subj,
            "--skip-bids-validation",
            "--me-output-echos",
            "--md-only-boilerplate",
            f"--fs-license-file=/opt/freesurfer/license.txt",
            "--fs-no-reconall",
            "--output-spaces", output_spaces,
            f"--nthreads={nthreads}",
            "--stop-on-first-crash",
            f"--mem-mb={mem_mb}",
              # Enable fieldmap-less correction
            "-w", "/tmp"
        ]
        run_command(docker_cmd)
    
    # Set permissions and ownership for output directory
    try:
        # Change ownership
        subprocess.run(["sudo", "chown", "-R", f"{owner_user}:{owner_group}", str(output_dir)], check=True)
        # Adjust permissions (read, write, execute for owner; read, execute for group and others)
        subprocess.run(["sudo", "chmod", "-R", "755", str(output_dir)], check=True)
        print(f"Permissions and ownership for '{output_dir}' updated successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Permission or ownership change failed with error: {e}")
        exit(1)

print("Processing completed successfully.")


