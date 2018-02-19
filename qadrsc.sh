#!/bin/bash

# ============================================================================
# qadrsc - Quick-and-dirty securely copy to remote script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/qadrsc
# ============================================================================

version="1.0.0"

usage() {
    script_file=$(basename "$0")
    echo "usage: $script_file SOURCE_PATH REMOTE_USER REMOTE_IP"\
                             "DESTINATION_DIR"
    echo
    echo "required arguments:"
    echo "  SOURCE_PATH           path of the source file(s) on the local"\
                                 "system"
    echo "  REMOTE_USER           username of the remote user used to log in"
    echo "  REMOTE_IP             IP address of the remote system"
    echo "  DESTINATION_DIR       directory on the remote system to copy the"\
                                 "files to"
    echo
    echo "Notice that when using asterisks in the source path, the path must"\
         "either be"
    echo "enclosed with single (') or double (\") quotes."
    echo
    echo "Further information and usage examples can be found inside the"\
         "'README' file"
    echo "of this project."
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
elif [ $# -ne 4 ]; then
    usage
    echo
    echo "error: Invalid number of arguments (4 required)"
    exit 1
fi

dir_current=$(pwd)
dir_destination="/$4"   # the leading slash denies using dynamic paths
remote_ip="$3"
remote_user="$2"

file_source=$(sed -e "s/.*\///g" <<< $1)
dir_source=$(sed -e "s/$file_source$//g" <<< $1)

cd $dir_source
tar -c ./$file_source | ssh ${remote_user}@${remote_ip} \
                        "sudo tar -x --no-same-owner -C $dir_destination"
cd $dir_current

# EOF

