#!/bin/bash
# Script to add a user
# Input file format:
# username
# supplementary groups, divided by commas
# home directory
# encrypted password (can be obtained by "openssl passwd -crypt <your password>"
if [ $(id -u) -eq 0 ]; then
    filename="$1"
    while read -r line
    do
        username="$line"        
        getent passwd $username >/dev/null
        if [ $? -eq 0 ]; then
            echo "$username exists!"
            exit 1
        else
            getent group $username >/dev/null
	    if [ $? -eq 0 ]; then
		home_group_exists="-g $username"
	    else
		home_group_exists=""
	    fi
            read -r line
            groups="$line"
            if [ $groups == "-" ]; then
                gr_arg="" #"-" means default: user belongs only to initial group
            else
                for group in $(echo $groups | sed "s/,/ /g")
                do
                    getent group $group >/dev/null
                    if [ ! $? -eq 0 ]; then
                        echo "group $group doesn't exist! It will be added."
			groupadd $group
                    fi
                done
                gr_arg="-G $groups"
            fi
            read -r line
            path="$line"
	    if [ $path == "-" ]; then
		pa_arg="" #"-" means default: directory name is USERNAME, appended to BASE_DIR
	    else
                pa_arg="-d $path"
	    fi
            read -r line
            pswd="$line"
            ps_arg="-p $pswd"
        fi
        useradd $home_group_exists $ps_arg $gr_arg $pa_arg $username
	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!!!"
    done < $filename
else
    echo "Only root may add new users!!!"
    exit 3
fi
