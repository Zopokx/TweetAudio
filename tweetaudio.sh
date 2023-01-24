#!/bin/bash
# Original  cmd version by McAlby   [https://www.dropbox.com/s/q28p74krkyalvj1/tomp4.cmd?dl=0]
#          bash version by karawapo [https://gist.github.com/alecrem/847b3c2ac2ac3dab11ca5dd4f30810b8]

audio=$1
image=$2
output=${1%.*}".mp4"
thumbnail="waveform.png"
bgcolor="#1e9eefff"
wavecolor="#ffffffff"

# Check if audio file exists
if [ ! -f "$audio" ]; then
    echo "ERROR: Audio file does not exist"
    echo ""
    echo "USAGE: bash tweetaudio.sh <audio> <image>"
    echo " NOTE: Only <audio> is mandatory"
    exit
fi

# Check if ffmpeg is installed
if [ -z "$(command -v ffmpeg)" ]; then
    echo "Please install 'ffmpeg' and run this script again."
	exit 127
fi

# Check if image file exists
if [ ! -f "$image" ]; then
	ffmpeg -y -i "$audio" -filter_complex "color=c=${bgcolor}[color];aformat=channel_layouts=mono,showwavespic=s=1280x960:colors=${wavecolor}[wave];[color][wave]scale2ref[bg][fg];[bg][fg]overlay=format=auto" -frames:v 1 "$thumbnail"
	if [ ! $? -eq 0 ]; then
		echo "ERROR: Waveform thumbnail cannot be created"
		exit
	fi
	image=$thumbnail
fi

# Create Tweet Audio as a MP4 video
ffmpeg -loop 1 -i "$image" -i "$audio" -shortest -fflags shortest -max_interleave_delta 100M -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p "$output"

# Clean up
rm "$thumbnail"
