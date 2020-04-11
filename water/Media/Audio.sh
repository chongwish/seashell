#
# Module: Media.Audio
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
#      detect_code demo.m4a
function detect_code() {
    depend_ffprobe
    ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$1"
}

# Usage:
#     convert_to_m4a origin_file target_file
#
function convert_to_m4a() {
    depend_ffmpeg
    local ext="${2##*.}"
    if [[ "$ext" == "m4a" ]]; then
        cp "$1" "$2"
    else
        local name="${2%.*}"
        ffmpeg -loglevel error -i "$1" -ab 256k -c:v copy "$name.m4a" < /dev/null
    fi
}
