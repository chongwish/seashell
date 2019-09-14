#
# Module: Linux.Container.LXD
# @Dependency: LXD
#    Please install lxd first, you can read the manual below
#      - https://linuxcontainers.org/lxd/
#      - https://wiki.gentoo.org/wiki/LXD
#      - https://wiki.gentoo.org/wiki/LXC
#      - https://wiki.archlinux.org/index.php/LXD
#      - https://wiki.archlinux.org/index.php/Linux_Containers
#

import Linux.User[get_uid get_gid]
import Linux.Distribution[get_distribution get_shell]
import Linux.Distribution.PackageManager[install upgrade]


# default image name
declare -Ag __SEASHELL_LINUX_CONTAINER_LXD_IMAGES=(
    [archlinux]="images:archlinux"
    [debian]="images:debian/buster"
    [ubuntu]="images:ubuntu/bionic"
    [centos]="images:centos/7"
    [fedora]="images:fedora/30"
    [alpine]="images:alpine/3.10"
)

#############################
#### Mount Section Begin ####
#############################

# Usage:
#     mount_disk $host_path $disk_name@$container_name:$path
function mount_disk() {
    if [ ! -e "$1" ]; then panic FILE_NONEXISTENT "Function mount_disk needs a existed path."; fi
    local disk="${2%:*}"
    lxc config device add "${disk#*@}" "${disk%@*}" disk path="${2#*:}" source="$1"
}

# Usage:
#     umount_disk $disk_name@$container_name
function umount_disk() {
    lxc config device remove "${1#*@}" "${1%@*}"
}

# Usage:
#     remount_disk $disk_name@$container_name
function remount_disk() {
    local path=`lxc config device get "${1#*@}" "${1%@*}" path`
    local source=`lxc config device get "${1#*@}" "${1%@*}" source`
    umount_disk "$1"
    mount_disk "$source" "$1:$path"
}

# Usage:
#     is_disk_mounted $disk_name@$container_name
function is_disk_mounted() {
    lxc config device list "${1#*@}" | grep "^${1%@*}$"
}

###########################
#### Mount Section End ####
###########################


#################################
#### Container Section Begin ####
#################################

function is_container_existed() {
    lxc list -c "n" --format csv | grep "^$1$"
}

function get_container_state() {
    lxc list -c "ns" --format csv | grep "^$1," | awk -F ',' '{print $2}'
}

function start_container() {
    if [[ "`get_container_state $1`" == "STOPPED" ]]; then
        lxc start $1
        wait_container Starting
    fi
}

function stop_container() {
    if [[ "`get_container_state $1`" == "RUNNING" ]]; then
        lxc stop $1
        wait_container Stopping
    fi
}

function restart_container() {
    local state=`get_container_state $1`
    if [[ "$state" == "STOPPED" ]]; then lxc start $1; elif [[ "$state" == "RUNNING" ]]; then lxc restart $1; fi
    wait_container Starting
}

# Usage:
#     wait_container $state
#     The $state has two status: Starting, Stopping
function wait_container() {
    while [ -n "`lxc operation list | grep '$1 container'`" ]; do sleep 1; done
}

# Usage:
#     create_container $container_name
function create_container() {
    lxc launch ${__SEASHELL_LINUX_CONTAINER_LXD_IMAGES[`get_distribution`]} $1
}

# Usage:
#     delete_container $container_name
function delete_container() {
    lxc delete "$1"
}

###############################
#### Container Section End ####
###############################


##############################
#### Device Section Begin ####
##############################

# Usage:
#     create_profile $profile
function create_profile() {
    lxc profile create "$1"
}

# Usage:
#     delete_profile $profile
function delete_profile() {
    lxc profile delete "$1"
}

# Usage:
#     is_profile_existed $profile
function is_profile_existed() {
    lxc profile list --format csv | awk -F ',' '{print $1}' | grep "^$1$"
}

# Usage:
#     get_profile_config $profile $key
function get_profile_config() {
    lxc profile get "$1" "$2"
}

# Usage:
#     save_profile_config $profile $key=$value
function save_profile_config() {
    lxc profile set "$1" "${2%%=*}" "${2#*=}"
}

# Usage:
#     get_profile_device $device@$profile a
function get_profile_device() {
    lxc profile device get "${1#*@}" "${1%@*}" "$2"
}

# Usage:
#     save_profile_device $device:$type@$profile a=b c=d
function save_profile_device() {
    local profile_name="${1#*@}"
    local device="${1%@*}"
    shift
    lxc profile device add "$profile_name" "${device%:*}" "${device#*:}" "$@"
}

# Usage:
#     remove_profile_device $device@$profile
function remove_profile_device() {
    lxc profile device remove "${1#*@}" "${1%@*}"
}

# Usage:
#     is_profile_device_existed $device@$profile
function is_profile_device_existed() {
    lxc profile device list "${1#*@}" | grep "^${1%@*}$"
}

# Usage:
#     get_container_device $device@$container a
function get_container_device() {
    lxc config device get "${1#*@}" "${1%@*}" "$2"
}

# Usage:
#     save_container_device $device:$type@$container a=b c=d
function save_container_device() {
    local container_name="${1#*@}"
    local device="${1%@*}"
    shift
    lxc config device add "$container_name" "${device%:*}" "${device#*:}" "$@"
}

# Usage:
#     remove_container_device $device@$container
function remove_container_device() {
    lxc config device remove "${1#*@}" "${1%@*}"
}

# Usage:
#     is_container_device_existed $device@$container
function is_container_device_existed() {
    lxc config device list "${1#*@}" | grep "^${1%@*}$"
}

# Usage:
#     add_container_profile $container $profile
function add_container_profile() {
    lxc profile add "$1" "$2"
}

# Usage:
#     remove_container_profile $container $profile
function remove_container_profile() {
    lxc profile remove "$1" "$2"
}

############################
#### Device Section End ####
############################


###############################
#### Command Section Begin ####
###############################

# Usage:
#     exec_container_command $container $command
function exec_container_command() {
    if [[ "${1//@/}" == "$1" ]]; then
        lxc exec "$1" -- `get_shell` -c "$2"
    else
        lxc exec "${1#*@}" -- su - "${1%@*}" -c "`get_shell` -c '$2'"
    fi
}

# Usage:
#     install_container_package $container vim emacs
function install_container_package() {
    local container_name="$1"
    shift
    exec_container_command $container_name "`install $@`"
}

function upgrade_container_package() {
    exec_container_command $1 "`upgrade`"
}

#############################
#### Command Section End ####
#############################


############################
#### User Section Begin ####
############################

# Usage:
#     create_container_user $user_name@$container
#     create_container_user $user_name:$uid@$container
#     create_container_user $user_name::$gid@$container
#     create_container_user $user_name:$uid:$gid@$container
function create_container_user() {
    local user=`echo "${1%@*}" | tr ':' ' '`
    local user_name=`echo $user | awk '{print $1}'`
    local uid=`echo $user | awk '{print $2}'`
    local gid=`echo $user | awk '{print $3}'`
    local command="useradd -m"
    local user_name_result=`exec_container_command "${1#*@}" "awk -F ':' '{if (\\\$1 == \"$user_name\") print }' /etc/passwd"`

    if [ -n "$user_name_result" ]; then
        panic "Function create_container_user can not create a user had been existed."
    fi

    if [ -n "$uid" ]; then command="$command -u $uid"; fi
    if [ -n "$gid" ]; then command="$command -g $gid" && exec_container_command "${1#*@}" "groupadd -g $gid $user_name"; fi

    exec_container_command "${1#*@}" "$command $user_name"
}

# Usage:
#     mirror_host_user_to_container $container
function mirror_host_user_to_container() {
    create_container_user `whoami`:`get_uid`:`get_gid`@$1
}

# Usage:
#     mount_home_as_host_user $container $mount_endpoint
function mount_home_as_host_user() {
    mount_disk $2 `whoami`@${1}:/home/`whoami`
    exec_container_command $1 "chown `whoami`:`whoami` /home/`whoami`"
}

# Usage:
#     reset_container_gid $group_name@$container $gid
function reset_container_gid() {
    exec_container_command "${1#*@}" "sed -ri 's/^(${1%@*}):([^:]*):[0-9]+:(.*)/\1:\2:${2}:\3/g' /etc/group"
}

##########################
#### User Section End ####
##########################


##############################
#### System Section Begin ####
##############################

# Usage:
#     configure_container_base_system $container
function configure_systemd_container_base_system() {
    # resolv
    exec_container_command $1 "rm -rf /etc/resolv.conf"
    exec_container_command $1 "ln -sfn /run/systemd/resolve/resolv.conf /etc/resolv.conf"

    # update && upgrade
    upgrade_container_package $1

    # locales
    install_container_package $1 "locales"
    exec_container_command $1 'echo LANG=\"en_US\" > /etc/locale.conf'
    exec_container_command $1 "sed -ri 's/^([^#]+)/#\1/g' /etc/locale.gen"
    exec_container_command $1 'echo -e "en_US ISO-8859-1\nen_US.utf8 UTF-8" >> /etc/locale.gen && locale-gen'
}

############################
#### System Section End ####
############################
