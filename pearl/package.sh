#
# package.sh
#

# Load the package, it will load from user directory when it was found, or load from seashell directly when it was found
# Usage:
#     include Linux.Container.X
# Run:
#     Linux.Container.X.fn1
function include() {
    verify_package_name $1

    # pefer user-defined package to system-defined package
    local package_path=`get_user_package_path $1`
    if [ ! -f "$package_path" ]; then package_path=`get_system_package_path $1`; fi
    if [ ! -f "$package_path" ]; then panic PACKAGE_NOT_FOUND "Can not find the package '$package_path'!"; fi

    # content without comment
    local content=`cat $package_path | grep -v "^#"`

    # include dependency-tree
    declare -a package_included=(`echo "$content" | grep "^include " | sed -r "s/include //g"`)
    for i in ${package_included[*]}; do
        if [ -z "${SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$i]}" ]; then
            include $i
        fi
    done

    # record all the functions in the current namespace to a global variable SEASHELL_NAMESPACE_FUNCTION_INCLUDED
    SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$1]="`echo "$content" | grep -oE '^(function )?[a-zA-Z0-9_]+\(\)' | sed -rz 's/(function |\(\)|\n$)/ /g' | tr -d ' ' | tr '\n' '|'`"

    # import the function from a module to the current namespace
    declare -a function_imported=("`echo "$content" | grep '^import ' | sed -r 's/^import //g' | sed -rz 's/\n/|/g'`")
    local OLD_IFS=$IFS
    IFS=$"|"
    for module_imported in ${function_imported[@]}; do
        IFS=$OLD_IFS
        if [ -n "$module_imported" ]; then
            import_to $1 $module_imported
        fi
    done
    IFS=$OLD_IFS

    # rewrite the function-call in the current namespace
    local parser=$(echo "$content" | grep -v "^(include|import)" | sed -r 's/^(function )?([a-zA-Z0-9_]+)\(\)/\1'$1.'\2\(\)/g' | sed -r 's/(^\s*\b|`|\$\(|`lambda\s+|\$\(lambda\s+|then\s+|do\s+|;\s+)('${SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$1]}')(\b|`|\))/\1'$1.'\2\3/g')

    eval "$parser"
}

# Load the function to the current script with theirs namespace, it will execute the include first
# Usage:
#     1. import Linux.Container.X
#     2. import Linux.Container.X[fn1 fn2]
# Run:
#     fn1
function import() {
    import_to "" $@
}

# Load the function to the namespace we assigned. if the namespace is blank, the behavior of it just like the function import does.
# Usage 1:
#     1. import_to Linux.Container.X Array
#     2. import_to Linux.Container.X Array[fn1 fn2]
# Run 1:
#     Linux.Container.X.fn1
# Usage 2:
#     1. import_to "" Linux.Container.X
#     2. import_to "" Linux.Container.X[fn1 fn2]
# Run 2:
#     fn1
function import_to() {
    if [ $# -le 1 ]; then panic PARAMETER_MISSING "Function import_to needs two package name."; fi

    local to_package_name=$1
    local to_package_name_for_replace=$to_package_name
    shift

    # replace '[]' to ' ' for supporting to import the function we assigned
    local parameters=(`echo "$@" | tr '[]' ' '`)
    if [ ${#parameters[*]} -eq 0 ]; then panic PARAMETER_MISSING "Function import needs two package name."; fi

    # using get_array_index for compating zsh and bash
    local from_package_name=${parameters[$(get_array_index 0)]}
    # get the function list by parameter passing
    local function_name_list=("${parameters[@]:1}")

    if [ -n "$to_package_name" ]; then
        verify_package_name $to_package_name
        to_package_name_for_replace="${to_package_name}."
    fi
    verify_package_name $from_package_name

    include $from_package_name

    # generate a namespace function map, like: [fn1]=ns.fn1
    declare -a function_name_list_in_package=(`get_package_function_list $from_package_name`)
    declare -A function_name_map_in_package=()
    for function_name in ${function_name_list_in_package[@]}; do
        function_name_map_in_package[${function_name//${from_package_name}./}]=$function_name
    done

    # if there aren't any parameter was passed, all the functions in the namespace would be imported
    if [ ${#function_name_list[*]} -ne 0 ]; then
        function_name_list_in_package=()
        for function_name in ${function_name_list[@]}; do
            if [ -z "${function_name_map_in_package[$function_name]}" ]; then
                panic FUNCTION_NAME_INVALID "Can not import nonexistent function '$function_name' from '$from_package_name'."
            fi
            function_name_list_in_package+=(${function_name_map_in_package[$function_name]})
        done
    fi

    # map the assigned namespace function to current namespace, and append these functions to the global variable SEASHELL_NAMESPACE_FUNCTION_INCLUDED
    for function_name in ${function_name_list_in_package[*]}; do
        map_function $function_name ${function_name//${from_package_name}./${to_package_name_for_replace}}
        # it doesn't need to do anything more if the current namespace is blank
        if [ -z "$to_package_name" ]; then continue; fi
        if [ -z "${SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$to_package_name]}" ]; then
            SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$to_package_name]="${function_name//${from_package_name}./}"
        else
            SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$to_package_name]="${SEASHELL_NAMESPACE_FUNCTION_INCLUDED[$to_package_name]}|${function_name//${from_package_name}./}"
        fi
    done
}

# Get all the functions we had sourced and filter that function which package we specify
# Usage:
#     declare -a array=(`get_package_function_list Linux.Container.X`)
# Return:
#     Linux.Container.X.fn1 Linux.Container.X.fn2 ...
function get_package_function_list() {
    local package_name=$1
    verify_package_name $package_name

    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
        declare -a function_list=($(print -l ${(ok)functions} | grep "^${package_name}\.[a-zA-Z][a-zA-Z0-9]*\(_[a-zA-Z0-9]\+\)*$"))
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
        declare -a function_list=($(declare -F | grep " ${package_name}\.[a-zA-Z][a-zA-Z0-9]*\(_[a-zA-Z0-9]\+\)*$" | awk '{print $3}' | tr -d ' '))
    else
        panic SYSTEM_SHELL_UNSUPPORT "Function get_package_function_list is only supported in the bash/zsh."
    fi

    echo ${function_list[*]}
}

# Verify a name of package can be valid, the name of package is only begin with every namespace hierarchy, these hierarchy concatenate with the char '.', look like: Linux.Container.X
# Usage:
#     verify_package_name Linux.Container.X => ok
#     verify_package_name linux.container.x => failed
function verify_package_name() {
    local package_name=$1
    if [[ ! $package_name =~ ^([A-Z][a-zA-Z0-9]*\.)*[A-Z][a-zA-Z0-9]+$ ]]; then panic PACKAGE_NAME_INVALID "'$package_name' wasn't a valid package name."; fi
}
