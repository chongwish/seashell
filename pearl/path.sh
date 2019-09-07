#
# path.sh
#

# @todo
function get_absolute_path() {
    local file_path="$1"
    if [[ "$file_path" != "/"* ]]; then file_path="$(pwd)/$file_path"; fi
    echo $file_path
}

# Used for package library, it will replace the parameter from the char '::' to the char '/'
# Example:
#     Linux.Container.X => Linux/Container/X
function change_package_name_separator() {
    local package_name=$1
    echo "${package_name//.//}"
}

# Used for package library, it will replace a namespace to a filename
# Example:
#     Linux.Container.X => Linux/Container/X.sh
function get_package_relation_path() {
    echo "$(change_package_name_separator $1).sh"
}

# Get the package seashell had been defined to a filename
# Example:
#     Linux.Container.X => $SEASHELL_WATER/Linux/Container/X.sh
function get_system_package_path() {
    echo "$SEASHELL_WATER/$(get_package_relation_path $1)"
}

# Get the package in the user directory
# Example:
#     Linux.Container.X => $the_script_directory/Linux/Container/X.sh
function get_user_package_path() {
    local path="$(get_absolute_path)$(get_package_relation_path $1)"
    local real_path=""
    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
        real_path=$path:A
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
        real_path=`readlink -f "$path"`
    else
        panic SYSTEM_SHELL_UNSUPPORT "Function get_user_package_path is only supported in the bash/zsh."
    fi
    if [ -z "$real_path" ]; then real_path=$path; fi
    echo $real_path
}
