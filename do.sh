#!/bin/bash
#
# Automatically save all Docker images as tar files and store them in /root/dcc directory.
# This script assumes Docker is installed and configured properly.
#

# Directory to store tar files
save_dir="/root/dcc"

# Ensure the save directory exists
mkdir -p "$save_dir"

# Get a list of all Docker images
images=$(docker images --format "{{.Repository}}:{{.Tag}}")

# Loop through each image and save it as a tar file
for image in $images; do
    # Replace '/' and ':' in image name to generate a valid filename
    tar_filename=$(echo "$image" | tr '/:' '_').tar
    echo "Saving $image as $tar_filename"
    docker save -o "$save_dir/$tar_filename" "$image"
done

echo "All Docker images saved to $save_dir"
