#
# Moduel: Linux.User
#

function get_uid() {
    if [ $# == 0 ]; then
        id -u `whoami`
    else
        id -u "$1"
    fi

}

function get_gid() {
    if [ $# == 0 ]; then
        id -g `whoami`
    else
        grep "^$1:" /etc/group | cut -d: -f3
    fi
}
