#!/bin/bash

# Set the source directory where the .config files are located
CONFIG_DIR="$1"

# Check if the source directory is provided and exists
if [ -z "$CONFIG_DIR" ]; then
    echo "Usage: $0 <path_to_config_directory>"
    exit 1
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Directory '$CONFIG_DIR' does not exist."
    exit 1
fi

# Iterate over each .config file in the source directory
for config_file in "$CONFIG_DIR"/*.config; do
    if [ -f "$config_file" ]; then
        # Copy each .config file to the current directory
        cp "$config_file" .
        echo "Copied $config_file to the current directory."
    fi
done
