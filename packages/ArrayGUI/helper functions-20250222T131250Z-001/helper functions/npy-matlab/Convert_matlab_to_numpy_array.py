# -*- coding: utf-8 -*-
"""
Created on Tue Feb  4 10:01:24 2025

@author: KRAMAC4
"""
import scipy.io
import numpy as np
mat_file={} # Load your matfile

npz_file={} # name your mpz file how you want. 

# Load .mat file
mat_data = scipy.io.loadmat(mat_file)

# Create a dictionary to hold the numpy arrays
npz_data = {}

# Convert each variable in the .mat file to a numpy array
for key in mat_data:
    # Skip metadata keys like '__header__', '__version__', and '__globals__'
    if key.startswith('__'):
        continue
    npz_data[key] = mat_data[key]

# Save the data to a .npz file
np.savez(npz_file, **npz_data)
print(f"Conversion successful! Data saved to {npz_file}")
