#
# Module: Linux.Distribution.PackageManager.Ubuntu
#

function install_nvidia_video_driver() {
    echo "apt-get install -y software-properties-common && add-apt-repository -y ppa:graphics-drivers/ppa && apt-get -y update && apt-get -y dist-upgrade && apt-get install -y nvidia-driver-430"
}

function install_intel_video_driver() {
    echo "apt-get -y install xserver-xorg-video-intel"
}
