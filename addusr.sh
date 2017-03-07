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
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
            echo "$username exists!"
            exit 1
        else
            read -r line
            groups="$line"
	    if [ "$(echo "$groups" | tr -d '[:space:]')" = "" ]; then
		echo "Enter groups!!"
		exit 3
            elif [ $groups == "-" ]; then
                gr_arg="" #"-" means default: user belongs only to initial group
            else
                for group in $(echo $groups | sed "s/,/ /g")
                do
                    egrep "^$group" /etc/group >/dev/null
                    if [ ! $? -eq 0 ]; then
                        echo "$group is not in the group list!"
                        exit 2
                    fi
                done
                gr_arg="-G $groups"
            fi
            read -r line
            path="$line"
	    if [ "$(echo "$path" | tr -d '[:space:]')" = "" ]; then
		echo "Enter path!!"
		exit 3
	    elif [ $path == "-" ]; then
		pa_arg="" #"-" means default: directory name is USERNAME, appended to BASE_DIR
	    else
                pa_arg="-d $path"
	    fi
            read -r line
            pswd="$line"
	    if [ "$(echo "$pswd" | tr -d '[:space:]')" = "" ]; then
		echo "Enter a password!!!"
		exit 3
	    else
            	ps_arg="-p $pswd"
	    fi
        fi
        useradd $ps_arg $gr_arg $pa_arg $username
	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!!!"
    done < $filename
else
    echo "Only root may add new users!!!"
    exit 3
fi
