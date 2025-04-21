#!/bin/bash

# AIR Tool
#
# Copyright 2024 Carnegie Mellon University.
#
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING INSTITUTE
# MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON UNIVERSITY MAKES NO
# WARRANTIES OF ANY KIND, EITHER EXPRESSED OR IMPLIED, AS TO ANY MATTER
# INCLUDING, BUT NOT LIMITED TO, WARRANTY OF FITNESS FOR PURPOSE OR
# MERCHANTABILITY, EXCLUSIVITY, OR RESULTS OBTAINED FROM USE OF THE MATERIAL.
# CARNEGIE MELLON UNIVERSITY DOES NOT MAKE ANY WARRANTY OF ANY KIND WITH RESPECT
# TO FREEDOM FROM PATENT, TRADEMARK, OR COPYRIGHT INFRINGEMENT.
#
# Licensed under a MIT (SEI)-style license, please see license.txt or contact
# permission_at_sei.cmu.edu for full terms.
#
# [DISTRIBUTION STATEMENT A] This material has been approved for public release
# and unlimited distribution.  Please see Copyright notice for non-US Government
# use and distribution.
#
# This Software includes and/or makes use of Third-Party Software each subject to
# its own license.
#
# DM24-1686


# Function to create user account inside the container
create_user_in_container() {
    local username=$1
    local uid=$2
    local gid=$3

    if [ -z "$username" ]; then
        echo "Username is required"
        exit 1
    fi

    if [ -z "$uid" ]; then
        echo "User ID is required"
        exit 1
    fi

    if [ -z "$gid" ]; then
        echo "Group ID is required"
        exit 1
    fi

    # Add user to /etc/group
    echo "$username:x:$gid:" >>/etc/group

    # Add user to /etc/gshadow
    echo "$username:x::" >>/etc/gshadow

    # Add user to /etc/passwd
    echo "$username:x:$uid:$gid::/home/$username:/bin/fish" >>/etc/passwd

    # Add user to /etc/shadow
    echo "$username:!x:::::::" >>/etc/shadow

    # Create home directory for user
    mkdir -p /home/$username

    # Copy root's files to the new user's home directory
    cp -R /root/. /home/$username

    # Set permissions for the home directory
    chmod -R 755 /home/$username

    # Change ownership of the home directory to the new user
    chown -R $username:$username /home/$username

    # Set permissions for the /tmp directory
    chmod -R 777 /tmp

    # Set permissions for the home directory
    chmod -R 755 /workspace

    # Change ownership of the home directory to the new user
    chown -R $username:$username /workspace

    HOME=/home/$username

    # set env vars
    echo '' >> $HOME/.config/fish/config.fish
    echo "set -x HOME /home/$username" >> $HOME/.config/fish/config.fish
    echo 'set -x FISH_CONFIG_DIR $HOME/.config/fish' >> $HOME/.config/fish/config.fish
    echo 'set -x XDG_DATA_HOME $HOME/.local/share' >> $HOME/.config/fish/config.fish
    echo 'set -x XDG_CONFIG_HOME $HOME/.config' >> $HOME/.config/fish/config.fish
    echo 'set -x XDG_CACHE_HOME $HOME/.local/share' >> $HOME/.config/fish/config.fish

    # Start the web server as root in the background
    /workspace/scripts/run_quarto.sh &

    # Set HOME environment variable and execute chroot and switch to the new user
    HOME=/home/$username FISH_CONFIG_DIR=$HOME/.config/fish/ XDG_DATA_HOME=$HOME/.local/share XDG_CONFIG_HOME=$HOME/.config XDG_CACHE_HOME=$HOME/.local/share exec chroot --userspec=$uid:$gid / /bin/fish -c "cd /workspace; exec fish"

}

# Check if script is being run with superuser privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 username uid gid"
    exit 1
fi


# Call the function with the provided arguments
create_user_in_container $1 $2 $3
