#
# Module: Linux.Distribution.PackageManager.Archlinux
#

function install_nvidia_video_driver() {
    echo "pacman -S --noconfirm nvidia"
}

function install_intel_video_driver() {
    echo "pacman -S --noconfirm xf86-video-intel"
}
