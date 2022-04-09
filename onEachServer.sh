#!/bin/bash

#Script that will execute a command on each server

#HELP Menu

help(){

	echo "${0} [OPTIONS...] [COMMAND]" >&2
	echo "-s	SUPPLY the list of servers comma separated to execute the command on" >&2
	echo "-s all	can be used to look at the /etc/hosts file to execute on all servers" >&2
	echo "-c	COMMAND to be executed" >&2
}

DEFAULT_FILE='/etc/hosts'

if [[ -f temp_file ]]; then
	rm temp_file
fi

touch temp_file

while getopts s:c:d OPTION
do	
	case "${OPTION}" in
	
	s) SERVER_LIST=${OPTARG}
	   
	   if [[ ${SERVER_LIST} = 'all' ]]; then
		sed -n '/To be used/,/^=$/p' ${DEFAULT_FILE} | grep '^[[:digit:]]' | awk '{print $2}' >> temp_file	
	   else
	   	echo "${SERVER_LIST}" | tr ',' '\n' >> temp_file
	   fi
	   ;;

	c) COMMAND=${OPTARG}
	   ;;
	
	d) DRY_RUN='true'
	   ;;
	
	*) help
	   ;;
	
	esac
done

if [[ ${DRY_RUN} = 'true' ]] ; then

	echo "This command will be run on the following servers"
	cat temp_file
else

	for i in `cat temp_file`

	do
		echo "============ Executing the command on ${i} ================="
		ssh -o ConnectTimeout=2 "${i}" "${COMMAND}" 
	done
fi
