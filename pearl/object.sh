#
# object.sh
#

# Generate a variable which is a assoc array with all the functions in the namespace we specify
# Usage:
#     `new v=Linux.Container.X`
# Then a assoc array which name is v will be generated, We can call it by the way below:
#     ${v[fn1]}
function new () {
    local package=`echo ${1#*=} | tr 'a-z.' 'A-Z_'`
    local variable=${1%=*}

    if [ -z "$package" -o -z "$variable" ]; then panic PARAMETER_VALUE_INVALID "Function new needs the only one parameter like k=v." ; fi

    local result=""
    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
        eval "for i in \${(@k)$package}; do result=\"\$result [\$i]=\"\${${package}[\$i]}\"\"; done"
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
        eval "for i in \${!$package[*]}; do result=\"\$result [\$i]=\${$package[\$i]}\"; done"
    else
        panic SYSTEM_SHELL_UNSUPPORT "Function new is only supported in the bash/zsh."
    fi
    echo "eval declare -A $variable=($result)"
}
