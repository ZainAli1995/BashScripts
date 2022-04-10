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
}

readFromFile(){
	
	echo "Hey"	
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
		   shift
		   ;;
		i)
		   INTERACTIVE_MODE='true'
		   ;;
		*)
		   help
		   ;;
	esac
done

if [[ -f ${FILE_NAME} ]]; then
	
	for i in `cat ${FILE_NAME}`; do	
		useradd ${CREATE_HOME_DIR} ${ADD_COMMENTS}
	done
fi
