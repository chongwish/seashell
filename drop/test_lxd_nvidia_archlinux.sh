source $SEASHELL_HOME/seashell.sh

import Linux.Distribution[is]
import Linux.Distribution.PackageManager.Archlinux[install_nvidia_video_driver]
import Linux.Container.LXD
import Linux.Container.LXD.Video
import Linux.Container.LXD.Audio

export mount_name=~/VMs/LXD/home/archlinux
export container_name=archlinux
export video_profile_name="video"

is archlinux

create_video_profile $video_profile_name

create_container $container_name
add_container_profile $container_name $video_profile_name
restart_container $container_name

mirror_host_user_to_container $container_name
mount_home_as_host_user $container_name $mount_name

#change to a quickly mirror
exec_container_command $container_name 'echo -e "DNS=202.96.128.166" >> /etc/systemd/resolved.conf'
exec_container_command $container_name 'echo -e "FallbackDNS=8.8.8.8" >> /etc/systemd/resolved.conf'
sleep 3
exec_container_command $container_name 'echo -e "nameserver 202.96.128.166\nnameserver 8.8.8.8" > /run/systemd/resolve/resolv.conf'
exec_container_command $container_name 'echo -e "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist'

configure_systemd_container_base_system $container_name

# chinese
exec_container_command $container_name 'echo -e "zh_CN.utf8 UTF-8\nzh_CN.gb18030 GB18030\nzh_CN.gbk GBK\nzh_CN GB2312" >> /etc/locale.gen && locale-gen'
install_container_package $container_name "ttf-dejavu wqy-microhei wqy-zenhei"

install_video_package $container_name
exec_container_command $container_name "`install_nvidia_video_driver`"

install_container_package $container_name "pulseaudio"

add_host_user_to_video_group $container_name
add_host_user_to_audio_group $container_name

exec_container_command `whoami`@$container_name 'echo -e "export XAUTHORITY=/tmp/.xorg-xauth\nexport DISPLAY=:0\nexport PULSE_SERVER=/tmp/.pulse-socket\nexport LANG=\"en_US.UTF-8\"\nexport LC_CTYPE=\"zh_CN.UTF-8\"\nexport XMODIFIERS=\"@im=fcitx\"\nexport XIM=fcitx\nexport XIM_PROGRAM=fcitx\nexport GTK_IM_MODULE=xim\nexport QT_IM_MODULE=xim" > ~/.profile'

restart_container $container_name
