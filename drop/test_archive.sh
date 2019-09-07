assoc_array=`declare -A`
index_array=`declare -a`

source $SEASHELL_HOME/seashell.sh

archive "$1" "$assoc_array" "$index_array"
