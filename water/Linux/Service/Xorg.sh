#
# Module: Linux.Service.Xorg
#

function get_xauth_path() {
    xauth info | head -1 | awk '{print $3}'
}

function detect_video_card_type() {
    local message=`lspci | grep VGA`
    if [ -n "`cat $message | grep -i intel`"]; then
        echo "intel"
    elif [ -n "`cat $message | grep -i nvidia`"]; then
        echo "nvidia"
    else
        panic "Can not detect what the video driver is."
    fi
}
