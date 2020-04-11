source $SEASHELL_HOME/seashell.sh

import Media.Video

import Linux.Shell

recurse_process_file_with $(lambda convert_to_x264) ~/Videos/Old ~/Videos/New "*.mp4"
