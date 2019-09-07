#
# Module: Linux.Distribution
#

declare -ag __SEASHELL_LINUX_DISTRIBUTIONS=("archlinux" "debian" "ubuntu" "centos" "fedora" "alpine")

declare -Ag __SEASHELL_LINUX_DISTRIBUTION_SHELL_MAP=(
    [archlinux]="/bin/bash"
    [debian]="/bin/bash"
    [ubuntu]="/bin/bash"
    [centos]="/bin/bash"
    [fedora]="/bin/bash"
    [alpine]="/bin/ash"
)

# @todo
# detect the distribution name
function auto_detect_distribution_name() {
    panic "Function auto_detect is unsupported now."
}

# set the distribution name
# Usage:
#     is archlinux
#     is centos
#     ......
function is() {
    for i in "${__SEASHELL_LINUX_DISTRIBUTIONS[@]}"; do
        if [[ "$i" == "$1" ]]; then export __SEASHELL_LINUX_CURRENT_DISTRIBUTION="$i" && return; fi
    done
    panic SYSTEM_DISTRIBUTION_UNSUPPORT "Function is only support these distributions: '${__SEASHELL_LINUX_DISTRIBUTIONS[*]}'."
}

# get the distribution name
function get_distribution() {
    if [[ -z "$__SEASHELL_LINUX_CURRENT_DISTRIBUTION" ]]; then panic SYSTEM_DISTRIBUTION_UNSUPPORT "Function get_distribution need to call the function 'is' first."; fi
    echo "$__SEASHELL_LINUX_CURRENT_DISTRIBUTION"
}

# get the distribution shell
function get_shell() {
    echo "${__SEASHELL_LINUX_DISTRIBUTION_SHELL_MAP[`get_distribution`]}";
}
