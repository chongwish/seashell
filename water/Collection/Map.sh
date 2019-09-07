#
# Module: Collection.Map
#

# Usage:
#     $(for_each assoc_array `lambda fn`) or `foreach assoc_array $(lambda fn)`
#     fn is a function needs two parameters, the first parameter is the key of assoc_array_a and the other is the value of assoc_array_a
function for_each() {
    echo '
    eval
    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
       for k in "${(@k)'$1'}"; do '$2' "$k" "${'$1'[$k]}"; done;
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
       for k in "${!'$1'[@]}"; do '$2' "$k" "${'$1'[$k]}"; done;
    else
      exit;
    fi
    '
}

# Usage:
#     $(map assoc_array_a `lambda fn` assoc_array_b) or `map assoc_array_a $(lambda fn) assoc_array_b`
#     fn is a function needs two parameters, the first parameter is the key of assoc_array_a and the other is the value of assoc_array_a
# Result:
#     if:
#       assoc_array_a=([a]=1 [b]=2 [c]=3)
#       fn => echo "key is $1, value is $2"
#     then:
#       assoc_array_b=([a]="key is a, value is 1" [b]="key is b, value is 2" [c]="key is c, value is 3")
function map() {
    echo '
    eval
    declare -A '$3'=();
    if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then
      for k in ${(k)'$1'}; do '$3'[$k]=`'$2' "$k" "${'$1'[$k]}"`; done;
    elif [[ "$SEASHELL_CURRENT_SHELL" == "bash" ]]; then
      for k in "${!'$1'[@]}"; do '$3'[$k]=`'$2' "$k" "${'$1'[$k]}"`; done;
    else
      exit;
    fi
    '
}
