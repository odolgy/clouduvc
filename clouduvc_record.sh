#!/bin/bash

# Include configuration file
if [[ ! -e "clouduvc_config.sh" ]]; then
    echo "File \"clouduvc_config.sh\" not found. If the file exists, change the working directory."
    exit 1
fi
source clouduvc_config.sh

# Check configuration
if [[ ! ($conf_start_tm =~ ^[0-2]{1}[0-9]{1}:[0-5]{1}[0-9]{1}$ && $conf_start_tm < "24:00") ]]; then
    echo "Bad start time format"
    exit 1
fi
if [[ ! ($conf_end_tm =~ ^[0-2]{1}[0-9]{1}:[0-5]{1}[0-9]{1}$ && $conf_end_tm < "24:00") ]]; then
    echo "Bad end time format"
    exit 1
fi

# Check dependencies
if [[ conf_use_ffmpeg -ne 0 ]]; then
    if [[ "$(which ffmpeg)" == "" ]]; then
        echo "Please, install ffmpeg."
        exit 1
    fi
else
    if [[ "$(which guvcview)" == "" ]]; then
        echo "Please, install guvcview."
        exit 1
    fi
fi
if [[ conf_use_cloud -ne 0 ]]; then
    if [[ "$(which rclone)" == "" ]]; then
        echo "Please, install rclone."
        exit 1
    fi
    if [[ ! -e "clouduvc_sync.sh" ]]; then
        echo "File \"clouduvc_sync.sh\" not found. If the file exists, change the working directory."
        exit 1
    fi
fi

# Create output folders
mkdir -p "$conf_path_local"
if [[ conf_use_cloud -ne 0 ]]; then
    mkdir -p "$conf_path_cloud"
fi

while true
do
    # Delete too old files from local storage
    if [[ conf_ret_local -ne 0 ]]; then
        find "$conf_path_local" -type f -mmin +"$conf_ret_local" -delete &
    fi

    # Calculate duration of the next recording
    curr_tm=$(date +%H:%M)
    curr_tm_sec=$(date -d "1970-01-01 $curr_tm Z" +%s)
    end_tm_sec=$(date -d "1970-01-01 $conf_end_tm Z" +%s)
    rec_duration=0
    if [[ $conf_start_tm == "$conf_end_tm" ]]; then
        rec_duration="$conf_duration"
    elif [[ ($conf_start_tm < $conf_end_tm && (! $curr_tm < $conf_start_tm && ! $curr_tm > $conf_end_tm)) ||
            ($conf_start_tm > $conf_end_tm && (! $curr_tm < $conf_start_tm || ! $curr_tm > $conf_end_tm)) ]]; then
        if [[ ! $curr_tm > $conf_end_tm ]]; then
            rec_duration=$(expr "$end_tm_sec" - "$curr_tm_sec" + 60)
        else
            rec_duration=$(expr 86400 - "$curr_tm_sec" + "$end_tm_sec" + 60)
        fi
        if [[ $rec_duration -gt $conf_duration ]]; then
            rec_duration=$conf_duration
        fi
    fi

    # Start a new recording
    if [[ rec_duration -gt 0 && -e "$conf_device" ]]; then
        file_name=$(date +%Y-%m-%d_%H-%M-%S)
        echo -e "\rStarting a new recording: $file_name ($rec_duration sec)"

        if [[ conf_video_mode -ne 0 ]]; then
            full_file_name=$conf_path_local/"$file_name"."$conf_ext_video"

            if [[ conf_use_ffmpeg -ne 0 ]]; then
                ffmpeg -y \
                    -i "$conf_device" \
                    -t "$rec_duration" \
                    -r "$conf_fps" \
                    -s "$conf_res" \
                    -c:v "$conf_codec_ffmpeg" \
                    $conf_ffmpeg_out_options \
                    -loglevel error \
                    -hide_banner \
                    "$full_file_name"
            else
                guvcview \
                    --video="$full_file_name" \
                    --video_timer="$rec_duration" \
                    --video_codec="$conf_codec_guvcview" \
                    --resolution="$conf_res" \
                    --device="$conf_device" \
                    --fps="$conf_fps" \
                    --gui=none \
                    --audio=none \
                    --render=none \
                    --exit_on_term
            fi
        else
            full_file_name=$conf_path_local/"$file_name"."$conf_ext_image"

            if [[ conf_use_ffmpeg -ne 0 ]]; then
                ffmpeg -y \
                    -i "$conf_device" \
                    -s "$conf_res" \
                    -frames:v 1 \
                    -loglevel error \
                    -hide_banner \
                    "$full_file_name"
            else
                guvcview \
                    --image="$full_file_name" \
                    --resolution="$conf_res" \
                    --device="$conf_device" \
                    --photo_timer=1 \
                    --photo_total=1 \
                    --gui=none \
                    --audio=none \
                    --render=none \
                    --exit_on_term
            fi

            sleep $rec_duration
        fi

        # Run script that copies new file to the cloud storage
        if [[ conf_use_cloud -ne 0 ]]; then
            ./clouduvc_sync.sh \
                "$file_name" \
                "$conf_path_local" \
                "$conf_path_cloud" \
                "$conf_ret_cloud" \
                "$conf_path_remote" &
        fi
    # Wait
    else
        sleep 30
    fi
done
