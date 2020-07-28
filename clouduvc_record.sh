#!/bin/bash

# ********** CONFIGURATION ***********
# Camera device
conf_device=/dev/video0
# Cloud use flag.
# Set this parameter to 0 if you don't want to copy videos to the cloud storage.
conf_use_cloud=1
# Directory for local storage.
conf_path_local=/mnt/storage/video_local
# Directory for cloud storage.
# If you don't want to have a separate directory for cloud storage,
# set $conf_path_cloud equal to $conf_path_local. In this case
# all videos will be saved to the cloud and $conf_ret_cloud will not be used.
# You may leave this field blank if conf_use_cloud == 0.
conf_path_cloud=/mnt/storage/video_cloud
# Path for clouduvc_sync.sh script.
# You may leave this field blank if conf_use_cloud == 0.
conf_path_cloud_sync=/home/pi/clouduvc_sync.sh
# Remote path for rclone in format cloud:path.
# You may leave this field blank if conf_use_cloud == 0.
conf_path_remote=mycloud:media/video
# Retention period in minutes for local storage.
# Used to delete files that are too old.
# Set this value to 0 if you don't want to delete files.
conf_ret_local=$(expr 45 \* 24 \* 60)
# Retention period in minutes for cloud storage.
# Used to delete files that are too old.
# Set this value to 0 if you don't want to delete files.
# You may leave this field blank if conf_use_cloud == 0.
conf_ret_cloud=$(expr 8 \* 24 \* 60)
# Recording start time in format "HH:MM".
# Videos will be saved from $conf_start_tm to $conf_end_tm.
# Set $conf_end_tm equal to $conf_start_tm if you want to record videos all day long.
conf_start_tm="05:00"
# Recording end time in format "HH:MM"
conf_end_tm="23:30"
# Max duration of one video in seconds
conf_duration=$(expr 10 \* 60)
# Camera resolution in format WIDTHxHEIGHT
conf_res=320x240
# FPS for guvcview
conf_fps=10
# Codec for guvcview (see available options for guvcview --video_codec param)
conf_codec=mp43
# Output video file extension
conf_ext=avi
# ************************************

# ********** SCRIPT ******************
# Check dependencies
if [[ "$(which guvcview)" == "" ]]; then
    echo "Please, install guvcview."
    exit 1
fi
if [[ conf_use_cloud -ne 0 && "$(which rclone)" == "" ]]; then
    echo "Please, install rclone."
    exit 1
fi

# Create output folders
mkdir -p $conf_path_local
if [[ conf_use_cloud -ne 0 ]]; then
    mkdir -p $conf_path_cloud
fi

while true
do
    # Delete too old files from local storage
    if [[ $conf_ret_local -ne 0 ]]; then
        find $conf_path_local -type f -mmin +$conf_ret_local -delete &
    fi

    # Calculate duration of the next recording
    curr_tm=$(date +%H:%M)
    curr_tm_sec=$(date -d "1970-01-01 $curr_tm Z" +%s)
    end_tm_sec=$(date -d "1970-01-01 $conf_end_tm Z" +%s)
    rec_duration=0
    if [[ $conf_start_tm == $conf_end_tm ]]; then
        rec_duration=$conf_duration
        elif [[ ($conf_start_tm < $conf_end_tm && (! $curr_tm < $conf_start_tm && ! $curr_tm > $conf_end_tm)) ||
                ($conf_start_tm > $conf_end_tm && (! $curr_tm < $conf_start_tm || ! $curr_tm > $conf_end_tm)) ]]; then
        if [[ ! $curr_tm > $conf_end_tm ]]; then
            rec_duration=$(expr $end_tm_sec - $curr_tm_sec + 60)
        else
            rec_duration=$(expr 86400 - $curr_tm_sec + $end_tm_sec + 60)
        fi
        if [[ $rec_duration -gt $conf_duration ]]; then
            rec_duration=$conf_duration
        fi
    fi

    # Start a new recording
    if [[ rec_duration -gt 0 ]]; then
        file_name=$(date +%Y-%m-%d_%H-%M-%S).$conf_ext
        echo -e "\rStarting a new recording: $file_name ($rec_duration seconds)"
        guvcview \
            --video=$conf_path_local/$file_name \
            --video_timer=$rec_duration \
            --video_codec=$conf_codec \
            --resolution=$conf_res \
            --device=$conf_device \
            --fps=$conf_fps \
            --gui=none \
            --audio=none \
            --render=none \
            --exit_on_term

        # Run script that copies new video to the cloud storage
        if [[ conf_use_cloud -ne 0 ]]; then
            $conf_path_cloud_sync \
                $file_name \
                $conf_path_local \
                $conf_path_cloud \
                $conf_ret_cloud \
                $conf_path_remote &
        fi
        # Wait
    else
        sleep 30
    fi
done
# ************************************
