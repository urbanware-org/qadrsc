#!/bin/bash

# ============================================================================
# qadrsc - Quick-and-dirty securely copy to remote script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/qadrsc
# ============================================================================

version="1.1.0"

usage() {
    script_file=$(basename "$0")
    echo "usage: $script_file SOURCE_PATH DESTINATION_PATH"
    echo
    echo "required arguments:"
    echo "  SOURCE_PATH           path of the source file(s) on the local"\
                                 "system"
    echo "  DESTINATION_DIR       username, IP address and directory on the"\
                                 "remote"
    echo "                        system to copy the files to"
    echo
    echo "Notice that when using asterisks (*) in the source path, the path"\
         "must either"
    echo "be enclosed with single (') or double (\") quotes."
    echo
    echo "The destination path syntax is identical with the one from 'rsync'"\
         "and 'scp',"
    echo "e. g. \"johndoe@192.168.2.1:/etc\"."
    echo
    echo "Further information and usage examples can be found inside the"\
         "'README' file"
    echo "of this project."
    if [ -z "$1" ]; then
        exit 0
    else
        echo
        echo "error: $1"
        exit 1
    fi
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
elif [ "$1" = "--version" ]; then
    echo "$version"
    exit 0
elif [ $# -ne 2 ]; then
    usage "Invalid number of arguments (2 required)"
fi

grep "@" <<< $2 &>/dev/null
if [ $? -eq 1 ]; then
    usage "Invalid destination syntax ('@' separator missing)"
fi
grep ":" <<< $2 &>/dev/null
if [ $? -eq 1 ]; then
    usage "Invalid destination syntax (':' separator missing)"
fi

dir_current=$(pwd)
remote_user="$(echo "$2" | cut -d '@' -f 1)"
remote_path="$(echo "$2" | cut -d '@' -f 2)"
remote_ip="$(echo "$remote_path" | cut -d ':' -f 1)"

# The leading slash denies using dynamic paths
dir_destination="/$(echo "$remote_path" | cut -d ':' -f 2)"

if [ -z "$dir_destination" ]; then
    usage "Destination directory seems to be missing"
elif [ -z "$remote_user" ]; then
    usage "Remote user seems to be missing"
elif [ -z "$remote_ip" ]; then
    usage "Remote IP address seems to be missing"
fi

file_source=$(sed -e "s/.*\///g" <<< $1)
dir_source=$(sed -e "s/$file_source$//g" <<< $1)

if [ -z "$dir_source" ]; then
    dir_source=$(pwd)
fi

cd $dir_source
tar -c ./$file_source | ssh ${remote_user}@${remote_ip} \
                        "sudo tar -x --no-same-owner -C $dir_destination"
cd $dir_current

# EOF
