source $SEASHELL_HOME/seashell.sh

import Media.Audio

import Linux.Shell

recurse_process_file_with $(lambda convert_to_m4a) ~/Music/Old ~/Music/New "*.flac" "*.m4a"
