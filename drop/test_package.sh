source $SEASHELL_HOME/seashell.sh

function Array.for_each() { echo ""; }
get_package_function_list Array # Array.for_each

include Collection.Array
declare -F Collection.Array.for_each # bash only: Collection.Array.for_each

import Collection.Array[for_each]
declare -F for_each # bash only: for_each
