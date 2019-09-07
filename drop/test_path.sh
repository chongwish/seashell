source $SEASHELL_HOME/seashell.sh

get_absolute_path /root # /root
get_absolute_path a # `pwd`/a
get_absolute_path # `pwd`

change_package_name_separator Linux::Container::X # Linux/Container/X

get_package_relation_path Linux::Container::X # Linux/Container/X.sh

get_system_package_path Linux::Container::X # $SEASHELL_HOME/water/Linux/Container/X.sh

get_user_package_path Linux::Container::X # `pwd`/Linux/Container/X.sh
