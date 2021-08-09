#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "This script must be run as root."
  exit
fi

# name of the ipset..
SET_NAME=$1
TMP_NAME="tmp-${SET_NAME}"
ADD_TO=${SET_NAME}

if [ -n "$SET_NAME" ]; then
	SET_EXISTS=`ipset list -n ${SET_NAME}`
	if [ -z "$SET_EXISTS" ]; then
	  echo "Creating ${SET_NAME}"
	  ipset create ${SET_NAME} hash:net
	else
		echo "Set ${SET_NAME} exists, creating temporary set ${TMP_NAME} .."
		ipset create -! ${TMP_NAME} hash:net
		ADD_TO=${TMP_NAME}
	fi
else
	echo "Need to specify a set name."
	exit 0;
fi

# read in the data..
# either from stdin or file..
ip_skip_counter=0
ip_total_counter=0
echo "Refreshing ${ADD_TO} with data.."
while read line
do
	range_regex='\.0$'
	if [[ $line =~ $range_regex ]]; then
		echo "Converting ${line} to /24 range"
		line=`echo "${line}" | sed -e 's/\.0$/\.0\/24/'`
	fi
	if [[ $line =~ ':' ]]; then
		echo "Skipping IPv6? - ${line}"
	else
		MATCH_TEST=$(ipset test ${ADD_TO} ${line} &> /dev/null)
		if [ $? -eq 1 ]; then
	  	ipset add ${ADD_TO} $line
			ip_total_counter=$((ip_total_counter+1))
		else
			#echo "skipping $line, already matches."
			ip_skip_counter=$((ip_skip_counter+1))
			ip_total_counter=$((ip_total_counter+1))
		fi
	fi
done < "${2:-/dev/stdin}"

echo "Skipped ${ip_skip_counter} of ${ip_total_counter} or $((ip_skip_counter*100/ip_total_counter)) %"

if [ "$TMP_NAME" == "$ADD_TO" ]; then
	echo "Swapping ${ADD_TO} -> ${SET_NAME}"
	# now that the data is added, swap the data to the right set..
	ipset swap ${ADD_TO} ${SET_NAME}
	echo "Cleaning up ${TMP_NAME}"
	ipset destroy ${TMP_NAME}
fi

