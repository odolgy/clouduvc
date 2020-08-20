#!/bin/bash

# Camera device
conf_device=/dev/video0
# Cloud use flag.
# Set this parameter to 0 if you don't want to upload videos to the cloud.
conf_use_cloud=1
# Directory for local storage which contains all video files.
conf_path_local=/mnt/storage/video_local
# Directory for cloud storage which contains symlinks to video files from 
# $conf_path_local. 
# You may leave this field blank if conf_use_cloud == 0.
conf_path_cloud=/mnt/storage/video_cloud
# Remote path for rclone in format cloud:path.
# You may leave this field blank if conf_use_cloud == 0.
conf_path_remote=mycloud:media/video
# Retention period in minutes for local storage.
# Used to delete files that are too old.
# Check that the local storage is large enough.
# Set this value to 0 if you don't want to delete files.
conf_ret_local=$(expr 60 \* 24 \* 45)
# Retention period in minutes for cloud storage.
# Used to delete files (symlinks) that are too old.
# Check that the cloud storage is large enough.
# Set this value to 0 if you don't want to delete files.
# You may leave this field blank if conf_use_cloud == 0.
conf_ret_cloud=$(expr 60 \* 36)
# Recording start time in format "HH:MM".
# Videos will be saved from $conf_start_tm to $conf_end_tm.
# Set $conf_end_tm equal to $conf_start_tm if you want to record videos all day long.
conf_start_tm="05:00"
# Recording end time in format "HH:MM"
conf_end_tm="22:30"
# Max duration of one video in seconds
conf_duration=$(expr 60 \* 10)
# Camera resolution in format WIDTHxHEIGHT
conf_res=320x240
# Video FPS
conf_fps=10
# FFmpeg use flag.
# If your camera doesn't support auto brightness or auto contrast, use guvcview.
conf_use_ffmpeg=1
# Codec for ffmpeg (see available options for ffmpeg -c:v param)
conf_codec_ffmpeg=libx264
# Additional options for ffmpeg encoding.
# Change the preset to achieve a balance between performance and output file size.
conf_ffmpeg_out_options="-preset veryfast -pix_fmt yuv420p"
# Codec for guvcview (see available options for guvcview --video_codec param)
conf_codec_guvcview=mp43
# Output video file extension
conf_ext=avi
