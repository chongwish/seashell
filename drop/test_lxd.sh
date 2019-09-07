source $SEASHELL_HOME/seashell.sh

import Linux.Distribution[is]
import Linux.Container.LXD

export mount_name=/tmp/seashell_test_lxd
export container_name="container-test"
export profile_name="profile-test"

is ubuntu

mkdir $mount_name

create_container $container_name
is_container_existed $container_name
get_container_state $container_name

stop_container $container_name
start_container $container_name
restart_container $container_name

create_profile $profile_name

save_profile_config $profile_name raw.idmap="both 1000 1000"
get_profile_config $profile_name raw.idmap

save_profile_device eth-test:nic@$profile_name nictype=macvlan name=enp0s25 parent=enp0s25
is_profile_device_existed eth-test@$profile_name
get_profile_device eth-test@$profile_name nictype

remove_profile_device eth-test@$profile_name

save_container_device eth-test:nic@$container_name nictype=macvlan name=enp0s25 parent=enp0s25
get_container_device eth-test@$container_name nictype
remove_container_device eth-test@$container_name

add_container_profile $container_name $profile_name
remove_container_profile $container_name $profile_name

mount_disk $mount_name test@${container_name}:$mount_name
remount_disk test@$container_name
is_disk_mounted test@$container_name
umount_disk test@$container_name

stop_container $container_name
delete_container $container_name

delete_profile $profile_name

rmdir $mount_name
