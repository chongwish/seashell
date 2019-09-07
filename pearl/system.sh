#
# system.sh
#   Log Section
#   Error Section
#   Function Section
#   Archive Section
#

###########################
#### Log Section Begin ####
###########################

# Display a message to terminal, and it will has some more additional function.
function seashell_log() {
    echo "$@" > /dev/tty
}

#########################
#### Log Section End ####
#########################



#############################
#### Error Section Begin ####
#############################

# Exit this main script
function seashell_exit() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        seashell_log "Return $1"
    fi
    if [ -n "$SEASHELL_PID" ]; then kill -9 $SEASHELL_PID; fi
}

# Exit this main script with some reason
# Usage:
#   1. panic ERROR_TYPE "some reason"
#   2. panic "some reason"
# ERROR_TYPE is refered at the file ./status.sh
function panic() {
    local parameters=("$@")
    local n=${#parameters[*]}

    if [ $n -eq 0 -o -z "$1" ]; then
        seashell_log "Function panic needs one more parameter!"
        seashell_exit ${SEASHELL_ERROR_STATUS["PARAMETER_MISSING"]}
    fi

    local error_type=${SEASHELL_ERROR_STATUS["UNKNOWN"]}
    local message="Unknown error!"

    if [ -n "${SEASHELL_ERROR_STATUS[$1]}" ]; then
        if [ $n -eq 1 ]; then
            error_type=${SEASHELL_ERROR_STATUS["PARAMETER_MISSING"]}
            message="Function panic needs one more parameter!"
        elif [ $n -eq 2 ]; then
            error_type=${SEASHELL_ERROR_STATUS[$1]}
            message=$2
        else
            error_type=${SEASHELL_ERROR_STATUS["PARAMETER_TOO_MANY"]}
            message="There are parameter more than function panic needs!"
        fi
    else
        message=$1
    fi

    seashell_log $message
    seashell_exit $error_type
}

###########################
#### Error Section End ####
###########################



################################
#### Function Section Begin ####
################################

# Map a name of function to the other name
# Usage:
#   map_function original_function_name target_function_name
# Run:
#   target_function_name
function map_function() {
    if [ $# -ne 2 ]; then panic PARAMETER_MISSING "Function map_function needs two parameter for mapping." ; fi

    local target_function_name=$2
    if [ ! -z "${target_function_name//[a-zA-Z0-9._]/}" ] || [[ "${target_function_name}" == [0-9._]* ]]; then panic FUNCTION_NAME_INVALID "Can not define a function name is '$target_function_name'."; fi
    eval "function $target_function_name() { $1 \"\$@\"; }"
}

# @todo
# now, only echo the parameter
function lambda() {
    if [ $# -ne 1 ]; then panic PARAMETER_MISSING "Function lambda needs only one parameter."; fi
    # if [[ ! "$1" =~ "^([A-Z][a-zA-Z0-9]*\.)+[a-zA-Z_][a-zA-Z0-9_]*$" ]]; then panic PARAMETER_VALUE_INVALID "Function lambda needs a function with full namespace."; fi
    echo "$1"
}

# get (n)th value in the array for compating zsh and bash
function get_array_index() {
    if [[ ! "$1" =~ ^[0-9]*$ ]]; then panic PARAMETER_VALUE_INVALID "Function get_array_index needs a numeric parameter."; fi
    if [[ "zsh" == "$SEASHELL_CURRENT_SHELL" ]]; then
        echo `expr $1 + 1`
    elif [[ "bash" == "$SEASHELL_CURRENT_SHELL" ]]; then
        echo $1
    else
        panic SYSTEM_SHELL_UNSUPPORT "Function get_array_index is only supported in the bash/zsh."
    fi
}

##############################
#### Function Section End ####
##############################



###############################
#### Archive Section Begin ####
###############################

# Ouput a standalone script including all its dependency(function, variable) from a modular script
# Usage:
#     archive $script_path $global_assoc_variables $global_index_variables
function archive() {
    if [ -z "$1" -o ! -f "$1" ]; then panic FILE_NONEXISTENT "Function archive needs a valid file."; fi

    local content=`cat $1 | grep -vE "(#.*$|^$|source)"`

    OLD_IFS=$IFS
    IFS=$'\n'
    for i in `echo "$content" | grep -E "^(import|include)"`; do
        IFS=$OLD_IFS
        eval "$i"
    done
    IFS=$OLD_IFS

    local assoc_array="$2"
    local index_array="$3"
    local function_array=""

    unset -f import
    unset -f import_to
    unset -f include
    unset -f archive

    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
        assoc_array=`echo "$assoc_array" | awk -F '=' '{print $1}'`
        index_array=`echo "$index_array" | awk -F '=' '{print $1}'`
        function_array=`typeset -f`
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
        assoc_array=`echo "$assoc_array" | awk -F '=' '{print $1}' | awk '{print $3}'`
        index_array=`echo "$index_array" | awk -F '=' '{print $1}' | awk '{print $3}'`
        function_array=`declare -f`
    else
        panic SYSTEM_SHELL_UNSUPPORT "Function archive is only supported in the bash/zsh."
    fi

    assoc_array=`echo "$assoc_array" | tr '\n' '|'`
    index_array=`echo "$index_array" | tr '\n' '|'`

    if [[ -z "$assoc_array" || "$assoc_array" == "|" ]]; then
        assoc_array="SEASHELL_NAMESPACE_FUNCTION_INCLUDED"
    else
        assoc_array="${assoc_array}SEASHELL_NAMESPACE_FUNCTION_INCLUDED"
    fi
    if [[ -z "$index_array" || "$index_array" == "|" ]]; then
        index_array="'\*'"
    else
        index_array="${index_array}'\*'"
    fi

    echo -e "# generated by $(whoami) with seashell at $(date)\n"
    echo -e "\n# Predefine"
    echo 'export SEASHELL_PID=$$'
    echo 'export SEASHELL_CURRENT_SHELL=`if [ -n "$ZSH_VERSION" ]; then echo zsh; elif [ -n "$BASH_VERSION" ]; then echo bash; else exit; fi`'
    echo 'if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then setopt no_bad_pattern && setopt sh_word_split && setopt noglob; fi'
    echo -e "\n# Global Variable"
    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
        declare -A | grep -vE "($assoc_array)=" | awk '{print "declare -A " $0}'
        declare -a | grep -vE "($index_array)=" | awk '{print "declare -a " $0}'
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
        declare -A | grep -vE "($assoc_array)="
        declare -a | grep -vE "($index_array)="
    fi
    echo -e "\n# Function"
    echo "$function_array"
    echo -e "\n# Code"
    echo "$content" | grep -vE "^(import|include)"
}

#############################
#### Archive Section End ####
#############################
