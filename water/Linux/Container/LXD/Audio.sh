#
# Module: Linux.Container.LXD.Audio
#
import Linux.User[get_uid get_gid]
import Linux.Container.LXD

# Usage:
#     add_user_to_audio_group $user_name@$container
function add_user_to_audio_group() {
    reset_container_gid audio@${1#*@} `get_gid audio`
    exec_container_command ${1#*@} "gpasswd -a ${1%@*} audio"
}

# Usage:
#     add_host_user_to_audio_group $container
function add_host_user_to_audio_group() {
    add_user_to_audio_group `whoami`@$1
}

# Usage:
#     load_host_systemd_pulseaudio $container
function load_host_systemd_pulseaudio() {
    local pulse_socket_file="/run/user/`id -u`/pulse/native"
    local pulse_target_socket_file=/tmp/.pulse-socket
    local pulse_config_directory=~/.config/pulse
    if [ -z "`is_container_device_existed pulse-socket@$1`" ]; then
        mount_disk $pulse_socket_file pulse-socket@${1}:$pulse_target_socket_file
    else
        if [ -z "`exec_container_command $1 "ls $pulse_target_socket_file 2>/dev/null"`" ]; then
            remount_disk pulse-socket@$1
        fi
    fi

    if [ -z "`is_container_device_existed pulse-config@$1`" ]; then
        mount_disk $pulse_config_directory pulse-config@${1}:$pulse_config_directory
    else
        if [ -z "`exec_container_command $1 "ls -d $pulse_config_directory 2>/dev/null"`" ]; then
            remount_disk pulse-config@$1
        fi
    fi
}
