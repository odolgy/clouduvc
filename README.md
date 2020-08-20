# Clouduvc

Clouduvc is used to create the simplest video surveillance system based on:
- Linux powered device, such as Raspberry Pi;
- webcam; 
- cloud storage, e.g. Google Drive (optional). 

How it works:
* Clouduvc records videos of a fixed length and saves them to a local storage (such as an external hard drive). Video recording is performed daily at a certain period of time or around the clock. 
* Optionally, the latest video files may be uploaded to the cloud storage. 
* Old files are removed from the local and the cloud storages according to the configured retention periods.

## Dependencies

* [guvcview](http://guvcview.sourceforge.net/) - video capturing software for UVC devices. Thanks to the built-in automatic camera adjustment function, this is a good solution for webcams without auto brightness and auto contrast support.
* [ffmpeg](https://ffmpeg.org/) - guvcview alternative for cameras with built-in auto brightness and auto contrast. Doesn't support camera adjustment, but allows you to control the video compression ratio, achieving better performance on low-end devices.
* [rclone](https://rclone.org/) - cloud storage synchronization software. A list of supported services can be found at [https://rclone.org/](https://rclone.org/).

## Installation

1. Install dependencies. For Debian based distributions:
``` sh
$ sudo apt install rclone ffmpeg
```
or (not preferred)
``` sh
$ sudo apt install rclone guvcview
```
2. Configure rclone (see complete guide at [https://rclone.org/docs/](https://rclone.org/docs/)):
``` sh
$ rclone config
```
Note that rclone also provides a login method for devices without a desktop environment.

3. Download clouduvc:
``` sh
$ wget https://github.com/odolgy/clouduvc/archive/master.zip
$ unzip master.zip && rm master.zip && mv clouduvc-master clouduvc
```
4. Configure the required parameters in "clouduvc_config.sh" file:
``` sh
$ cd clouduvc
$ cp clouduvc_config.example.sh clouduvc_config.sh
$ editor clouduvc_config.sh
```
5. Run and check that everything works:  
``` sh
 $ ./clouduvc_record.sh
```
6. You can check output video resolution, fps and other parameters using [ffprobe](https://ffmpeg.org/ffprobe.html):
``` sh
$ ffprobe video_file.avi 
```
7. Configure autorun. Example for distributions with systemd:
``` sh
$ sudo cp clouduvc.service /etc/systemd/system/
$ sudo editor /etc/systemd/system/clouduvc.service
$ sudo systemctl enable clouduvc.service
```
When using guvcview, you should run "clouduvc_record.sh" as a user who has a home directory, because guvcview uses it to save config files. Otherwise, you can get a Segmentation Fault.

8. Check that everything works:
``` sh
$ sudo systemctl start clouduvc.service
$ systemctl status clouduvc.service
```
