source $SEASHELL_HOME/seashell.sh

import Linux.Distribution[is]
import Linux.Container.LXD
import Linux.Container.LXD.Video
import Linux.Container.LXD.Audio

export container_name="archlinux"

is archlinux

load_host_systemd_pulseaudio $container_name
load_host_xorg $container_name

if [[ -z "`exec_container_command $container_name "which code"`" ]]; then
    install_container_package $container_name "code"
fi

exec_container_command `whoami`@$container_name "code"
