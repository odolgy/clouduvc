#!/bin/bash

file_name=$1
conf_path_local=$2
conf_path_cloud=$3
conf_ret_cloud=$4
conf_path_remote=$5

if [[ $conf_path_cloud != "$conf_path_local" ]]; then
    # Delete too old files from cloud storage
    if [[ $conf_ret_cloud -ne 0 ]]; then
        find "$conf_path_cloud" -type f -mmin +"$conf_ret_cloud" -delete
    fi

    # Copy video to the cloud directory.
    # '*' is required because guvcview may increment file name.
    cp "$conf_path_local"/"$file_name"* "$conf_path_cloud"/
fi

# Sync cloud storage
rclone sync "$conf_path_cloud" "$conf_path_remote"
