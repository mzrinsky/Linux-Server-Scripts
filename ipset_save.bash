#!/bin/bash

# Written by Matt Zrinsky <matt.zrinsky@gmail.com>
# Lives @ https://github.com/mzrinsky/Linux-Server-Scripts

if [ "$EUID" -ne 0 ] 
  then echo "This script must be run as root."
  exit
fi

FILENAME="${1:=/etc/sysconfig/ipset}"
echo "Saving ipsets to '${FILENAME}'"
ipset save | grep -v 'f2b-' | grep -v 'tmp-' > "${FILENAME}"
echo "done"
