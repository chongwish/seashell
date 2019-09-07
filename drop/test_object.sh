source $SEASHELL_HOME/seashell.sh

function Namespace.Package.fn() {
    echo "function fn"
}
declare -A NAMESPACE_PACKAGE=([fn]=Namespace.Package.fn)

`new v=Namespace.Package`
${v[fn]} # function fn
