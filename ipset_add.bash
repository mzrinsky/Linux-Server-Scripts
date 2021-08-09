#!/bin/bash

if [ "$EUID" -ne 0 ] 
  then echo "This script must be run as root."
  exit
fi

SET_NAME=$1
NEW_ADDRESS=$2

if [ -z "$NEW_ADDRESS" ]; then
	echo "Missing address argument.."
	echo "Usage ipset_add.bash <set_name> <address>"
	exit 0;
fi

if [ -n "$SET_NAME" ]; then
	SET_EXISTS=`ipset list -n ${SET_NAME}`
	if [ -z "$SET_EXISTS" ]; then
		echo "Set '${SET_NAME}' was not found, please create it first."
		exit 0;
	else
		MATCH_TEST=$(ipset test ${SET_NAME} ${NEW_ADDRESS} &> /dev/null)
		if [ $? -eq 1 ]; then
			ipset add ${SET_NAME} ${NEW_ADDRESS}
			echo "Added ${NEW_ADDRESS} to ipset ${SET_NAME}"
			/usr/sbin/ipset_save.bash
		else
			echo "Set '${SET_NAME}' already matches ${NEW_ADDRESS}"
		fi
	fi
else
	echo "You MUST specify a set name."
	exit 0;
fi
