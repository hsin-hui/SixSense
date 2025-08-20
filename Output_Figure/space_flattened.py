import numpy as np
from nilearn import surface, datasets, plotting, image

# Load your statistical map (NIfTI file)
img = image.load_img('/Volumes/Transcend/results_no_filter/rsa/maps/mm_pattern_corr_imp_100_realdiff_dm.nii')

# Load fsaverage surface
fsaverage = datasets.fetch_surf_fsaverage(mesh='fsaverage5')

# Project volumetric data onto the surface
texture_left = surface.vol_to_surf(img, fsaverage.pial_left)
texture_right = surface.vol_to_surf(img, fsaverage.pial_right)

# Set your desired threshold range
vmin = 0.0
vmax = 1.0

# Mask values outside the range
masked_left = np.copy(texture_left)
masked_left[(masked_left < vmin) | (masked_left > vmax)] = np.nan

masked_right = np.copy(texture_right)
masked_right[(masked_right < vmin) | (masked_right > vmax)] = np.nan

# Plot outer surface (lateral)
plotting.plot_surf_stat_map(
    fsaverage.infl_left, masked_left,
    hemi='left', view='lateral',
    title='Left Hemisphere (Lateral)', 
    colorbar=True,
    bg_on_data=True,
    darkness=1,
    vmin=vmin, vmax=vmax
)

plotting.plot_surf_stat_map(
    fsaverage.infl_right, masked_right,
    hemi='right', view='lateral',
    title='Right Hemisphere (Lateral)', 
    colorbar=True,
    bg_on_data=True,
    darkness=1,
    vmin=vmin, vmax=vmax
)

# Plot inner surface (medial)
plotting.plot_surf_stat_map(
    fsaverage.infl_left, masked_left,
    hemi='left', view='medial',
    title='Left Hemisphere (Medial)',
    colorbar=True,
    bg_on_data=True,
    darkness=1,
    vmin=vmin, vmax=vmax
)

plotting.plot_surf_stat_map(
    fsaverage.infl_right, masked_right,
    hemi='right', view='medial',
    title='Right Hemisphere (Medial)',
    colorbar=True,
    bg_on_data=True,
    darkness=1,
    vmin=vmin, vmax=vmax
)

plotting.show()
