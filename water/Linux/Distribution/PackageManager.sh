#
# Module: Linux.Distribution.PackageManager
#

import Linux.Distribution[get_distribution get_shell]

declare -Ag __SEASHELL_LINUX_DISTRIBUTION_PACKAGE_MANAGER_MAP=(
    [archlinux]="pacman -S --noconfirm"
    [debian]="apt-get install -y"
    [ubuntu]="apt-get install -y"
    [centos]="yum install -y"
    [fedora]="dnf install -y"
    [alpine]="apk add -y"
)

declare -Ag __SEASHELL_LINUX_DISTRIBUTION_UPGRADE_MAP=(
    [archlinux]="pacman -Syu --noconfirm"
    [debian]="apt-get -y update && apt-get -y upgrade"
    [ubuntu]="apt-get -y update && apt-get -y upgrade"
    [centos]="yum -y update && yum -y upgrade"
    [fedora]="dnf -y update && dnf -y upgrade"
    [alpine]="apk update && apk upgrade"
)

declare -Ag __SEASHELL_LINUX_DISTRIBUTION_XORG_MAP=(
    [archlinux]="xorg"
    [debian]="xserver-xorg"
    [ubuntu]="xserver-xorg"
    [centos]="xorg"
    [fedora]="xorg"
    [alpine]="xorg-server"
)

# Install software by distribution package manager
# Usage:
#     install emacs vim
function install() {
    echo "${__SEASHELL_LINUX_DISTRIBUTION_PACKAGE_MANAGER_MAP[`get_distribution`]} $@"
}

function upgrade() {
    echo "${__SEASHELL_LINUX_DISTRIBUTION_UPGRADE_MAP[`get_distribution`]}"
}

function get_xorg_packages() {
    echo "${__SEASHELL_LINUX_DISTRIBUTION_XORG_MAP[`get_distribution`]}"
}
