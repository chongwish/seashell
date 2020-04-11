#
# Module: Linux.Shell
#

# Usage:
#     depend ffmpeg
function depend() {
    if [ ! -n "`which $1 > /dev/null && echo 1`" ]; then
        panic "Can not find $1, To install $1 first, please!"
    fi
}

# Usage:
#     recurse_process_file_with $(lambda fn) directory_from/ directory_to/ mp4 mp3
function recurse_process_file_with() {
    local fn=$1; shift
    local directory_from=`get_absolute_path $1`; shift
    local directory_to=`get_absolute_path $1`; shift
    declare -a parameters=("find" "$directory_from")
    if [ $# -gt 0 ]; then
        parameters+=("\(")
        for i in {1..$#}; do
            parameters+=("-iname")
            parameters+=("'$1'")
            parameters+=("-o")
            shift
        done
        parameters+=("-iname")
        parameters+=("'$1'")
        parameters+=("\)")
    fi
    parameters+=("-print0")
    eval `echo ${parameters[*]}` | xargs -0 -l1 | while read i; do
        local origin_name="`get_absolute_path "$i"`"
        local target_name="${origin_name/$directory_from/$directory_to}"
        local target_directory="`dirname "$target_name"`"
        local time_from=`date +%s`
        echo "[`date +%Y-%m-%d\ %H:%M:%S`] $origin_name is been processing..."
        if [ ! -d "$target_directory" ]; then mkdir -p "$target_directory"; fi
        $fn "$origin_name" "$target_name"
        echo "[`date +%Y-%m-%d\ %H:%M:%S`] $origin_name has been processed in $((`date +%s` - $time_from))s."
    done
}
