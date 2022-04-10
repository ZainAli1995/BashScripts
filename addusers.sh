#!/bin/bash

#Script to add a list of users to a system

help(){

	echo "USAGE ${0} [..OPTIONS] [username]"
	echo "-f	specify a csv file to take the list of users"
	echo "-m	to create a users home directory"
	echo "-a	to provide admin privileges to the user"
	echo "-c	to add a comment with the account creation"
	echo "-g	to get the user information"
	echo "-i	to create user in an interactive mode"
	echo "-r	to remove a user from the system including his home directory"
}

function userAdd(){

        local CREATE_HOME_DIR=${1}
        local ADD_COMMENTS=${2}
        local COMMENTS=${3}
        local USERNAME=${4}

        useradd "${CREATE_HOME_DIR}" "${ADD_COMMENTS}" "${COMMENTS}" "${USERNAME}"

        if [[ $? -eq 0 ]]; then
                echo "User ${i} added successfully to the system"
        else
                echo "User ${i} addition failed !!!"
                exit 1
        fi
}

function removeUser(){

	local USERNAME=${1}
	userdel -r ${USERNAME}
	if [[ $? -eq 0 ]]; then
		echo "User ${USERNAME} removed successfully"
		exit 0
	else
		echo "User ${USERNAME} not removed successfully"
		exit 1
	fi	
}

function getUserInfo(){

	local USERNAME=${1}
	chage -l ${USERNAME}
	
	if [[ $? -eq 0 ]]; then
		exit 0
	else
		exit 1
	fi
}

function addAdminRights(){

        local USERNAME=${1}
        usermod -aG wheel ${USERNAME}

        if [[ $? -eq 0 ]]; then
                echo "User ${USERNAME} added to the wheel group"
        else
                echo "User ${USERNAME} failed to get added to the wheel group"
                exit 1
        fi
}

function findUser(){

        local USERNAME=${1}

        grep -x ${USERNAME} /etc/passwd > /dev/null

        if [[ $? -eq 0 ]]; then
                echo "User found in the system"
        else
                echo "User not found in the system"
        fi
}


function interactiveMode(){

	echo "Welcome to the interactive console !! Today you will add or remove a user to the system"
	read -p "Enter the name of the User => " LOCAL_USERNAME
	
	grep -x ${LOCAL_USERNAME} /etc/passwd > /dev/null
	if [[ $? -eq 0 ]]; then
		echo "User already exists"
		read -p "Do you want to delete ${LOCAL_USERNAME} from the system ? [YES/NO]" ANSWER
		if [[ ${ANSWER} = 'YES' ]]; then
			removeUser ${USERNAME}
		elif [[ ${ANSWER} = 'NO' ]]; then
			read -p "Do you want information about the user ? [YES/NO]" ANSWER_TWO
			if [[ ${ANSWER_TWO = 'YES' ]]; then
				getUserInfo ${LOCAL_USERNAME}
			else
				echo "Sorry I cannot help you further !!!"
				exit 1
			fi
		fi
	else
		read -p "Do you want to add a user to the system ? [YES/NO]" ANSWER_THREE
		if [[ ${ANSWER_THREE} = 'YES' ]]; then
			userAdd ${LOCAL_USERNAME}
		else
			echo "Sorry I cannot help you further !!!"
		fi
	fi
	exit 0
}

while [ $# -gt 0 ]; do
	
	case $1 in
		f)
		   FILE_NAME=${1}
		   shift
		   shift
		   ;;
		m)
		   CREATE_HOME_DIR='-m'
		   shift
		   ;;
		a)
		   ADMIN_RIGHTS='true'
		   shift
		   ;;
		c)
		   ADD_COMMENTS='-c'
		   COMMENTS=$1
		   shift
		   shift
		   ;;
		g)
		   GET_USER_INFO='true'
		   GET_USERNAME=${1}
		   shift
		   ;;
		i)
		   interactiveMode
		   shift
		   ;;
		r)
		   REMOVE_USER='true'
	   	   shift
		   ;;
		*)
		   help
		   ;;
	esac
done

if [[ ${GET_USER_INFO} = 'true' ]]; then
	getUserInfo '${GET_USERNAME}'
fi

if [[ ${REMOVE_USER} = 'true' ]]; then
	removeUser '${USERNAME}
fi

if [[ -f ${FILE_NAME} ]]; then
	
	for USERNAME in `cat ${FILE_NAME}`; do	
		userAdd "${CREATE_HOME_DIR}" "${ADD_COMMENTS}" "${COMMENTS}" "${USERNAME}"
		
		if [[ ${ADMIN_RIGHTS} = 'true' ]]; then
			addAdminRights ${USERNAME}
		fi
	done
else
	if [[ ${#} -ne 1 ]]; then
		echo "Please provide only one single user"
		exit 1
	else
		userAdd "${CREATE_HOME_DIR}" "${ADD_COMMENTS}" "${COMMENTS}" "${USERNAME}"
	fi
fi
