#
# Module: Collection.Array
#

# Usage:
#     $(for_each index_array `lambda fn`) or `for_each index_array $(lambda fn)`
#     fn is a function needs only one parameter
function for_each() {
    if [[ $# -lt 2 ]]; then exit; fi
    # for i in "${@:1:`expr $# - 1`}"; do ${@:(-1)} "$i"; done
    echo '
    eval
    for i in "${'$1'[@]}"; do '$2' "$i"; done
    '
}

# Usage:
#     $(map index_array_a `lambda fn` index_array_b) or `map index_array_a $(lambda fn) index_array_b`
#     fn is a function needs only one parameter
# Result:
#     if:
#       index_array_a=(1 2 3)
#       fn => expr $1 + 1
#     then:
#       index_array_b=(2 3 4)
function map() {
    if [[ $# -ne 3 ]]; then exit; fi
    echo '
    eval
    declare -a '$3'=(); for i in "${'$1'[@]}"; do '$3'+=(`'$2' "$i"`); done
    '
}
