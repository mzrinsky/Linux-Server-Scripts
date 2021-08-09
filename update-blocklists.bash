#!/bin/bash

# Written by Matt Zrinsky <matt.zrinsky@gmail.com>
# Lives @ https://github.com/mzrinsky/Linux-Server-Scripts

ipset_sysconfig=/etc/sysconfig/ipset

function curl_to_ipset() {
	local from_url=$1
	local ipset_name_=$2
	local tmp_file="/tmp/${ipset_name_}.tmp"
	echo "Refreshing ipset: ${ipset_name_} from source: ${from_url}"
	curl --compressed "${from_url}" 2>/dev/null > "${tmp_file}"
	local return_code=$?
	if [ $return_code -eq 0 ]; then
		echo "Got updated data, refreshing ipset: ${ipset_name_}"
		/usr/sbin/ipset_generate.bash "${ipset_name_}" "${tmp_file}"
		# cleanup after ourselves..
		rm "${tmp_file}"
	else
		echo "Failed to download new data, skipping update of ${ipset_name_}"
	fi
}

function tmp_to_ipset() {
	local from_file=$1
	local ipset_name_=$2
	if [ -f $from_file ]; then
		echo ""
		/usr/sbin/ipset_generate.bash "${ipset_name_}" "${from_file}"
	else
		echo "File ${from_file} does not exist, can not update $ipset_name_ !"
	fi
}

IPSET_NAME="ipsum"
DATA_URL="https://raw.githubusercontent.com/stamparm/ipsum/master/levels/3.txt"
curl_to_ipset $DATA_URL $IPSET_NAME

IPSET_NAME="blocklistde"
DATA_URL="https://lists.blocklist.de/lists/all.txt"
curl_to_ipset $DATA_URL $IPSET_NAME

# special case..
IPSET_NAME="research"
DATA_URL="https://isc.sans.edu/api/threatcategory/research/"
TMP_FILE_="/tmp/research_ipset.tmp"
# pull the curl data, but parse it as xml, and extract the ipv4 nodes..
# then replace the html so we have an ip address
# and write the ip addresses to a file..
echo "Refreshing ipset: ${IPSET_NAME} from source: ${DATA_URL}"
curl --compressed "${DATA_URL}" 2>/dev/null |\
 xmllint --xpath 'threatcategory/research/ipv4' - |\
 sed -e 's/<ipv4>//g' |\
 sed -e 's/<\/ipv4>/\n/g' > ${TMP_FILE_}

if [ $? -eq 0 ]; then
	echo "Got updated data, refreshing ipset: ${IPSET_NAME}"
	tmp_to_ipset ${TMP_FILE_} ${IPSET_NAME}
else
	echo "Failed to download new data, skipping update of ${IPSET_NAME}"
fi

if [ -f "$TMP_FILE_" ]; then
	rm "$TMP_FILE_"
fi

# Save the data
echo "Saving ipset data to ${ipset_sysconfig}"
# force a save of the ipsets..
/usr/sbin/ipset_save.bash ${ipset_sysconfig}

echo "done."

