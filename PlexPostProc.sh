#!/bin/sh

#****************************************************************************** 
#****************************************************************************** 
#
#            Plex DVR Post Processing w/Handbrake (H.264) Script
#
#****************************************************************************** 
#****************************************************************************** 
#  
#  Version: 1.0
#
#  Pre-requisites: 
#     HandBrakeCLI
#
#
#  Usage: 
#     'PlexPostProc.sh %1'
#
#  Description:
#      My script is currently pretty simple.  Here's the general flow:
#
#      1. Creates a temporary directory in the home directory for 
#      the show it is about to transcode.
#
#      2. Uses Handbrake (could be modified to use ffmpeg or other transcoder, 
#      but I chose this out of simplicity) to transcode the original, very 
#      large MPEG2 format file to a smaller, more manageable H.264 mp4 file 
#      (which can be streamed to my Roku boxes).
#
#	   3. Copies the file back to the original filename for final processing
#
#****************************************************************************** 

#****************************************************************************** 
#  Do not edit below this line
#****************************************************************************** 

if [ ! -z "$1" ]; then 
# The if selection statement proceeds to the script if $1 is not empty.

   FILENAME=$1 	# %FILE% - Filename of original file

   TEMPFILENAME="$(mktemp)"  # Temporary File for transcoding

   LOCKFILENAME="/tmp/PlexPostProcLock"

   # Uncomment if you want to adjust the bandwidth for this thread
   #MYPID=$$	# Process ID for current script
   # Adjust niceness of CPU priority for the current process
   #renice 19 $MYPID

   # Ensures no more than 1 convert process running at a time.
   # Keeps CPU happy.
   while [ -f "$LOCKFILENAME" ]; do sleep 10; done;
   touch "$LOCKFILENAME"

   echo "********************************************************"
   echo "Transcoding, Converting to H.264 w/Handbrake"
   echo "********************************************************"
   HandBrakeCLI -i "$FILENAME" -f mkv --aencoder copy -e qsv_h264 --x264-preset veryfast --x264-profile auto -q 16 --maxHeight 720 --decomb bob -o "$TEMPFILENAME"

   echo "********************************************************"
   echo "Cleanup / Copy $TEMPFILENAME to $FILENAME"
   echo "********************************************************"

   rm -f "$FILENAME"
   mv -f "$TEMPFILENAME" "$FILENAME"
   chmod 777 "$FILENAME" # This step may no tbe neccessary, but hey why not.

   # Let next conversion run.
   rm -f "$LOCKFILENAME"

   echo "Done.  Congrats!"
else
   echo "PlexPostProc by nebhead"
   echo "Usage: $0 FileName"
fi
