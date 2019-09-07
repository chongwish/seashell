#
# Module: Linux.Container.LXD.Video
#

import Linux.User[get_uid get_gid]
import Linux.Container.LXD
import Linux.Service.Xorg[get_xauth_path]
import Linux.Distribution[get_distribution get_shell]
import Linux.Distribution.PackageManager[install get_xorg_packages]

function create_video_profile() {
    local profile_name="$1"
    local uid=`get_uid`
    local gid=`get_gid`

    if [ -z "`is_profile_existed $profile_name`" ]; then
        create_profile $profile_name
    fi

    save_profile_config $profile_name raw.idmap="both $uid $gid"
    save_profile_config $profile_name raw.lxc='lxc.mount.entry="tmp tmp tmpfs create=dir 0 0"'

    save_profile_device gpu0:gpu@$profile_name uid=$uid gid=$gid
}

# Usage:
#     add_user_to_video_group $user_name@$container
function add_user_to_video_group() {
    reset_container_gid video@${1#*@} `get_gid video`
    exec_container_command ${1#*@} "gpasswd -a ${1%@*} video"
}

# Usage:
#     add_host_user_to_video_group $container
function add_host_user_to_video_group() {
    add_user_to_video_group `whoami`@$1
}

# Usage:
#     install_video_package $container
function install_video_package() {
    exec_container_command $1 "echo `hostname` > /etc/hostname"
    install_container_package $1 "`get_xorg_packages`"
}


# Usage:
#     load_host_xorg $container
function load_host_xorg() {
    local xorg_xauth_file=`get_xauth_path`
    local xorg_target_xauth_file=/tmp/.xorg-xauth
    local xorg_socket_directory=/tmp/.X11-unix
    if [ -z "`is_container_device_existed xorg-xauth@$1`" ]; then
        mount_disk $xorg_xauth_file xorg-xauth@${1}:$xorg_target_xauth_file
    else
        if [ -z "`exec_container_command $1 "ls $xorg_target_xauth_file 2>/dev/null"`" ]; then
            remount_disk xorg-xauth@$1
        fi
    fi

    if [ -z "`is_container_device_existed xorg-socket@$1`" ]; then
        mount_disk $xorg_socket_directory xorg-socket@${1}:$xorg_socket_directory
    else
        if [ -z "`exec_container_command $1 "ls -d $xorg_socket_directory/X0 2>/dev/null"`" ]; then
            remount_disk xorg-socket@$1
        fi
    fi
}
