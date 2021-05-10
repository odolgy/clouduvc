#!/bin/bash

file_name=$1
conf_path_local=$2
conf_path_cloud=$3
conf_ret_cloud=$4
conf_path_remote=$5

# Delete too old files from cloud storage
if [[ conf_ret_cloud -ne 0 ]]; then
    find "$conf_path_cloud" -type l -mmin +"$conf_ret_cloud" -delete
fi

# Create a symlink to the file in the cloud directory.
# '*' is required because guvcview may increment file name.
ln -s "$(readlink -f "$conf_path_local"/"$file_name"*)" "$conf_path_cloud"/"$file_name"

# Empty trash
rclone cleanup "$conf_path_remote"

# Sync cloud storage
rclone --copy-links --delete-before sync "$conf_path_cloud" "$conf_path_remote"
