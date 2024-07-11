#!/bin/bash
#
# This script imports Docker images from tar files stored in a specified directory.
# It assumes Docker is installed and configured properly.
#

# Prompt user to enter directory containing image tar files
read -p "Enter the directory path where image tar files are stored: " image_dir

# Check if the directory exists
if [ ! -d "$image_dir" ]; then
    echo "Error: Directory '$image_dir' not found."
    exit 1
fi

# Change directory to where the tar files are stored
cd "$image_dir" || exit

# Loop through each tar file and import Docker image
for tar_file in *.tar; do
    echo "Importing image from $tar_file"
    docker load -i "$tar_file"
done

echo "All images imported into Docker successfully."
