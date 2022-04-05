#!/bin/bash

#Script to deploy an rpm on a remote server

help(){

	echo "USAGE ${0} [OPTIONS] -p [PACKAGE_NAME]"
	echo "-s	specify the sever name"
	echo "-p	specify the package name"
	echo "-v	verify installation"
	echo "-i	install the package"
	exit 1	
}

#This function was added to find the rpm file using locate and then copy it to the RPM Directory
function findCopyRPM(){
	
	local RPM_PACKAGE=${1}
	local RPM_DIR='/root/local_repo'
	
	updatedb
	FIND_RPM_LOC=$(locate ${RPM_PACKAGE}})
	
	cp -ay ${FIND_RPM_LOC} ${RPM_DIR}
}

function install(){

	local PACKAGE_NAME=${1}
	sudo yum -y install ${PACKAGE_NAME}
}

function verification(){

	local PACKAGE_NAME=${1}
	
	rpmquery ${PACKAGE_NAME} 2> /dev/null
	
	if [[ "${?}" -eq 1 ]]; then
		echo "Package installed successfully"
	fi
}

function enable(){
	local PACKAGE_NAME=${1}
	systemctl enable ${PACKAGE_NAME}
}

function start(){
	local PACKAGE_NAME=${1}
	systemctl start ${PACKAGE_NAME}
}

function val_serverlist(){

	local serverlist_temp=${1}
	local DEFAULT_FILE='/etc/hosts'
	local VALIDATED='true'

	sed -n '/To be used/,/^=$/p' ${DEFAULT_FILE} | grep '^[[:digit:]]' | awk '{print $2}' > /tmp/default_serverlist
	
	for i in `cat ${serverlist_temp}`; do
	
		grep -x ${i} /tmp/default_serverlist > /dev/null
		
		if [[ $? -eq 0 ]]; then	
			continue
		else
			VALIDATED='false'
		fi
	done
	echo ${VALIDATED}	
}

#Temp file to store the list of servers the script will run on

SERVER_LIST='/tmp/serverlist_temp'

if [[ -f ${SERVER_LIST} ]]; then
	rm ${SERVER_LIST}
fi	

if [[ $# -eq 0 ]]; then
        help
fi

while [ $# -ne 0 ]; do

	case ${1} in
		
		-s|--servers) 
		
			shift	
			SERVER_NAMES=${1}
		
			#Check to see if any servers are provided
			
			if [[ ${SERVER_NAMES} != "" ]]; then
				
				echo "${SERVER_NAMES}" | tr ',' '\n' >> /tmp/serverlist_temp	
				
				#Validate the arguments passed by the user
				GET_VALIDATED=$(val_serverlist "${SERVER_LIST}")
				echo "Get validated has a value of ${GET_VALIDATED}"	
				
				if [[ "${GET_VALIDATED}" != 'true' ]]; then
					
					echo "You have passed incorrect server names"
					exit 1
				fi
			else
				help
			fi
		
			shift
			;;
		
		-p|--package)
		
			shift	
			PACKAGE_NAME=${1}
			
			if [[ ${PACKAGE_NAME} = "" ]]; then
				help
			fi
			shift
			;;
		
		i|--install)
			INSTALL='true'
			shift
			;;
				
		-v|--verify)
			
			VERIFICATION='true'
			shift
			;;
		*)
			help
			;;
	esac
done

for i in `cat ${SERVER_LIST}`; do
	
	#First version of the script will use rpm to the install
	#copy the rpm using scp to the target server
	
	echo "=============== Copying the package on server ${i} =================="
	scp "${PACKAGE_NAME}" root@centos-load-balancer:/tmp
	
	FIN_PACKAGE_NAME=$(basename "${PACKAGE_NAME}")
			
	DEST_PACKAGE="/tmp/${FIN_PACKAGE_NAME}"
	
	echo "=============== Attempting to Install the package ===================="
	ssh -o ConnectTimeout=2 "${i}" "rpm -ivh ${DEST_PACKAGE}"
	
	if [[ $? -eq 0 ]]; then
		echo "Package was installed successfully"
	else
		echo "Package installation failed"
		exit 1
	fi
done
