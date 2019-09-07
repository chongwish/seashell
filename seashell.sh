#
# seashell.sh
# The entry of seashell, it's better to sure that a absulute path was given
# Usage:
#     export SEASHELL_HOME=/xxx/xxx
#     source $SEASHELL_HOME/seashell.sh
#

if [ -z "$SEASHELL_HOME" ]; then echo "Please define varaible SEASHELL_HOME first." && exit 1; fi

export SEASHELL_PEARL="$SEASHELL_HOME/pearl"
export SEASHELL_WATER="$SEASHELL_HOME/water"
export SEASHELL_PID=$$
export SEASHELL_CURRENT_SHELL=`if [ -n "$ZSH_VERSION" ]; then echo zsh; elif [ -n "$BASH_VERSION" ]; then echo bash; else exit; fi`

# zsh
if [[ "$SEASHELL_CURRENT_SHELL" == "zsh" ]]; then setopt no_bad_pattern && setopt sh_word_split && setopt noglob; fi

for i in `ls "$SEASHELL_PEARL"`; do source "$SEASHELL_PEARL/$i"; done
