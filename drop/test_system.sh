source $SEASHELL_HOME/seashell.sh

function fn1() {
    echo "fn1"
}
map_function fn1 fn2
fn2 # fn1

get_array_index 2 # zsh => 3, bash => 2

