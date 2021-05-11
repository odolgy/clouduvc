#!/bin/bash

# Defines output file type: video (true) or image (false).
# In video mode, the program will record videos of a specified length,
# while in image mode, it will take photos with a configured delay.
readonly conf_video_mode=true
# Cloud use flag.
# When set to false, videos and images are not uploaded to the cloud.
readonly conf_use_cloud=true
# Camera device
readonly conf_device=/dev/video0
# Directory for local storage used to keep all videos and images.
readonly conf_path_local=/mnt/storage/clouduvc/local
# Directory for cloud storage used to keep symlinks to files from $conf_path_local.
# May be left blank if $conf_use_cloud is false.
readonly conf_path_cloud=/mnt/storage/clouduvc/cloud
# Remote path for rclone in format cloud:path.
# May be left blank if $conf_use_cloud is false.
readonly conf_path_remote=mycloud:media/video
# Retention period in minutes for local storage.
# Used to delete files that are too old.
# Before changing the value, please check that the local storage is large enough.
# When set to false files are not deleted.
readonly conf_ret_local=$((60 * 24 * 45))
# Retention period in minutes for cloud storage.
# Used to delete files (symlinks) that are too old.
# Before changing the value, please check that the cloud storage is large enough.
# When set to false files are not deleted.
# May be left blank if $conf_use_cloud is false.
readonly conf_ret_cloud=$((60 * 36))
# Recording start time in format "HH:MM".
# Videos and images will be saved from $conf_start_tm to $conf_end_tm.
# When $conf_end_tm equals to $conf_start_tm the recording continues all day.
readonly conf_start_tm="05:00"
# Recording end time in format "HH:MM"
readonly conf_end_tm="22:30"
# Max duration of one video or delay between two images in seconds
readonly conf_duration=$((60 * 10))
# Camera resolution in format WIDTHxHEIGHT
readonly conf_res=320x240
# Video FPS
readonly conf_fps=10
# FFmpeg use flag.
# If camera doesn't support auto brightness or auto contrast, use guvcview.
readonly conf_use_ffmpeg=true
# Codec for FFmpeg (see available options for ffmpeg -c:v param).
# Used only in video mode.
readonly conf_codec_ffmpeg=libx264
# Additional options for FFmpeg encoding.
# Change the preset to achieve a balance between performance and output file size.
# Used in video mode only.
readonly conf_ffmpeg_out_options="-preset veryfast -pix_fmt yuv420p"
# Codec for guvcview (see available options for guvcview --video_codec param).
# Used in video mode only.
readonly conf_codec_guvcview=mp43
# Output video file extension
readonly conf_ext_video=avi
# Output image file extension
readonly conf_ext_image=jpeg
