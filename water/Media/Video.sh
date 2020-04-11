#
# Module: Media.Video
#

import Linux.Shell[depend]

# Need ffmpeg command
function depend_ffmpeg() {
    depend ffmpeg
}

# Need ffprobe command
function depend_ffprobe() {
    depend ffprobe
}

# Usage:
#      detect_code demo.mp4
function detect_code() {
    depend_ffprobe
    ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1"
}

# Usage:
#     convert_to_x264 origin_file target_file
#
function convert_to_x264() {
    depend_ffmpeg
    local name="${2%.*}"
    if [[ `detect_code "$1"` == "x264" ]]; then
        cp "$1" "$name.mp4"
    else
        ffmpeg -loglevel error -i "$1" -vcodec libx264 "$name.mp4" < /dev/null
    fi
}
