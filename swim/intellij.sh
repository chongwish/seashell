source $SEASHELL_HOME/seashell.sh

import Linux.Distribution[is]
import Linux.Container.LXD
import Linux.Container.LXD.Video
import Linux.Container.LXD.Audio

export container_name="archlinux"

is archlinux

load_host_systemd_pulseaudio $container_name
load_host_xorg $container_name

exec_container_command `whoami`@$container_name "intellij-idea-ultimate-edition"
