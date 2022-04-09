#!/bin/bash

#This script can be used to check the running system status

#Checks the disk space on the block devices
#Reports if the disk space used is more than 80% on any partition
#Checks the status of the filesystem
#Checks the status of apache
#Checks the status of postgresql

APACHE_STATUS='SUCCESS'
PGSQL_STATUS='SUCCESS'
DISK_STATUS='SUCCESS'
FS_CHECK='SUCCESS'

DATE=$(date +%Y_%m_%d_%H_%M_%S)

#Create the log file to log the output

LOG_DIR='/var/log/systemchecks'

if [[ ! -d ${LOG_DIR} ]]; then
	
	mkdir -p /var/log/systemchecks
fi

LOG_FILE="/var/log/systemchecks/${DATE}"

echo "Name of the log file ${LOG_FILE}"

echo "=============== The system check ran at ${DATE} =======================" | tee -a ${LOG_FILE}

portCheck(){

	local PORT=${1}
	local PORT_STATUS='SUCCESS'

	local PORT_CHECK=$(nmap -P0 localhost -p ${PORT} | grep 'tcp\|udp' | awk '{print $2}')
	
        if [[ ${PORT_CHECK} != 'open' ]]; then
                PORT_STATUS='FAILED'

                echo "The port 80 is currently closed. Perhaps httpd service is not running" >> ${LOG_FILE}
        fi
	
	echo ${PORT_STATUS}
}

checkApacheStatus(){

	local PORT_CHECK=$(portCheck 80)
	
	if [[ ${PORT_CHECK} != 'SUCCESS' ]]; then
		APACHE_STATUS='FAILED'
		
		echo "The port 80 is currently closed. Perhaps httpd service is not running" >> ${LOG_FILE}
	fi
	
	local STATUS_CHECK1=$(systemctl status httpd | grep -i active | awk '{print $2}')
	
	if [[ ${STATUS_CHECK1} != 'active' ]]; then
		APACHE_STATUS='FAILED'
		echo "The httpd service is not running with the systemd" >> ${LOG_FILE}
	fi

	curl -s http://localhost:80 > /dev/null
	
	if [[ $? -ne 0 ]]; then
		APACHE_STATUS='FAILED'
		echo "Unable to connect to the localhost host on port 80" >> ${LOG_FILE}
	fi
	
	#Display final apache status
	echo ""
	echo "Checking Status of Apache................... [${APACHE_STATUS}]"
}

checkpostgreSQLStatus(){

	local PORT_CHECK=$(portCheck 5432)

        if [[ ${PORT_CHECK} != 'SUCCESS' ]]; then
                PGSQL_STATUS='FAILED'
                echo "The port 80 is currently closed. Perhaps httpd service is not running" >> ${LOG_FILE}
        fi	

	local STATUS_CHECK=$(systemctl status postgresql-12 | grep -i active | awk '{print $2}')
	
	if [[ ${STATUS_CHECK} != 'active' ]]; then
		PGSQL_STATUS='FAILED'
		echo "The port 5432 is currently closed. Perhaps the service postgresql is not running" >> ${LOG_FILE}
	fi

	psql -c "select now()"	&> /dev/null
	
	if [[ $? -ne 2 ]]; then
		PGSQL_STATUS='FAILED'
		echo "The sample query check failed" >> ${LOG_FILE}
	fi
	
	echo "Checking Status of PostgreSQL............... [${PGSQL_STATUS}]"
}

diskUsageStatus(){

	if [[ -f /tmp/temp_file ]]; then
		rm /tmp/temp_file
	fi
		
	DISK_USAGE=$(df -Th | grep "\/dev/" | grep -v tmpfs | awk '{print $6}')
	df -Th | grep "\/dev/" | tr -d "%" | grep -v tmpfs | awk '{print $1,$6}' >> /tmp/temp_file	

	for i in `cat /tmp/temp_file | awk '{print $NF}'`; do
	
		if [[ ${i} -gt 80 ]]; then
			DISK_STATUS='FAILED'
			echo "one of the disk usage is higher than 80%" >> ${LOG_FILE}
		fi
	done
	
	echo "Checking Status of Disk Usage............... [${DISK_STATUS}]"	
}

checkFileSystem(){
	
	if [[ -f /tmp/fs_temp_file ]]; then
		rm /tmp/fs_temp_file
	fi
	
	#1 -> Make sure all the partitions are mounted
	#2 -> Make sure you can touch a file in the directory	
	
	awk '/UUID/' /etc/fstab  | grep -v "swap" | awk '{print $1}' | tr -d "UUID=" >> /tmp/fs_temp_file
	
	for i in `cat /tmp/fs_temp_file`; do

		BLOCK_DEVICE=$(blkid -U ${i})
				
		df -Th | grep -q "${BLOCK_DEVICE}"
		
		if [[ $? -ne 0 ]]; then
			FS_CHECK='FAILED'
			echo "Block device: ${BLOCK_DEVICE} is not mounted" >> ${LOG_FILE}
		fi
		
		MOUNT_POINT=$(mount | grep "${i}" | awk '{print $3}')
		
		touch ${MOUNT_POINT}/testfile
		
		if [[ $? -ne 0 ]]; then
			FS_CHECK='FAILED'
			echo "Unable to touch a file on partition: ${MOUNT_POINT}" >> ${LOG_FILE}
		fi
	done		

	#Try to touch a file
	echo "Checking filesystem State................... [${FS_CHECK}]"
}

checkSMTPServer(){
	echo "To do"
}

checkApacheStatus
checkpostgreSQLStatus
diskUsageStatus
checkFileSystem
