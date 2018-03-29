#!/bin/bash

# ============================================================================
# qadrsc - Quick-and-dirty remote secure copy script
# Copyright (C) 2018 by Ralf Kilian
# Distributed under the MIT License (https://opensource.org/licenses/MIT)
#
# GitHub: https://github.com/urbanware-org/qadrsc
# ============================================================================

version="1.2.0"

parse_path() {
    input_path="$1"
    path_is_remote=0

    egrep "@|:" <<< $input_path &>/dev/null
    if [ $? -eq 0 ]; then
        path_is_remote=1
        remote_user="$(echo "$input_path" | cut -d '@' -f 1)"
        remote_target="$(echo "$input_path" | cut -d '@' -f 2)"
        remote_ip="$(echo "$remote_target" | cut -d ':' -f 1)"

        # The leading slash prevents using relative paths
        remote_path="/$(echo "$remote_target" | cut -d ':' -f 2)"
    fi
}

usage() {
    script_file=$(basename "$0")
    echo "usage: $script_file SOURCE_PATH DESTINATION_PATH"
    echo
    echo "required arguments:"
    echo "  SOURCE_PATH           source path of the on the local or remote"\
                                 "system"
    echo "  DESTINATION_PATH      destination path on the local or remote"\
                                 "system where"
    echo "                        to copy the files to"
    echo
    echo "Notice that when using asterisks (*) in the source path, the path"\
         "must either"
    echo "be enclosed with single (') or double (\") quotes."
    echo
    echo "The remote path syntax is identical with the one from 'rsync' and"\
         "'scp',"
    echo "e. g. \"johndoe@192.168.2.1:/etc\"."
    echo
    echo "Further information can be found inside the 'README' file, for"\
         "usage examples"
    echo "see the 'USAGE' file."
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

# Parse source path
parse_path "$1"
if [ $path_is_remote -eq 1 ]; then
    src_is_remote=1
    src_user="$remote_user"
    src_ip="$remote_ip"
    src_path="$remote_path"
else
    src_is_remote=0
    src_path=$1
fi

# Parse destination path
parse_path "$2"
if [ $path_is_remote -eq 1 ]; then
    if [ $src_is_remote -eq 1 ]; then
        usage "Source and destination must not both be a remote path"
    fi
    dst_is_remote=$path_is_remote
    dst_user="$remote_user"
    dst_ip="$remote_ip"
    dst_path="$remote_path"
else
    if [ $src_is_remote -eq 0 ]; then
        usage "Neither source nor destination is a remote path"
    fi
    dst_path=$2
fi

if [ $src_is_remote -eq 0 ]; then
    dir_current=$(pwd)
    file_source=$(sed -e "s/.*\///g" <<< $1)
    dir_source=$(sed -e "s/$file_source$//g" <<< $1)

    if [ -z "$dir_source" ]; then
        dir_source=$(pwd)
    fi

    cd $dir_source
    tar -c ./$file_source | ssh ${dst_user}@${dst_ip} \
                            "sudo tar -x --no-same-owner -C $dst_path"
    cd $dir_current
else
    # Simply use 'scp' to handle that way
    scp -q -r ${src_user}@${src_ip}:$src_path $dst_path
fi

# EOF
