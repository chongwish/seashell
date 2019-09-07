source $SEASHELL_HOME/seashell.sh


# map
import Collection.Map[for_each map]

function fn() {
    echo "key is $1, value is $2"
}

declare -A assoc_array_a=([a]=1 [b]=2 [c]=3)

$(for_each assoc_array_a `lambda fn`) # key is a, value is 1\nkey is b, value is 2\nkey is c, value is 3

$(map assoc_array_a `lambda fn` assoc_array_b)
declare -p assoc_array_b # assoc_array_b=([a]="key is a, value is 1" [b]="key is b, value is 2" [c]="key is c, value is 3" )


# array
import Collection.Array[for_each map]

function add1() {
    expr $1 + 1
}

declare -a index_array_a=(1 2 3)

$(for_each index_array_a `lambda add1`) # 2\n3\n4

$(map index_array_a `lambda add1` index_array_b)
declare -p index_array_b # index_array_b=(2 3 4)
