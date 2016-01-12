#!/bin/bash
echo ""
echo "### 9.4.1 BLFS Prep  ###"
echo "### ================================================================="

if [ ! -f ./blfs-include.sh ];then
    echo "*** Fatal Error - './blfs-include.sh' not found." ; exit 8 ; fi
source ./blfs-include.sh

echo "*** Validating the environment."
check_user root


echo "*** Retrieving Source Files ***"

grep -v '^\s*$\|^#\|^MD5' ./wget-list-blfs  | wget -nc -i- -P /sources

echo ""
echo "*** Verifying md5sums of sources"
grep -o 'MD5=\S*=[a-z0-9]*' ./wget-list-blfs |  awk -F  "=" '/1/ {print $3 "  " $2}' > /sources/blfs-md5sums-2
pushd  /sources
md5sum -c blfs-md5sums-2
popd

echo ""
echo "**************************** STOP!!!!!!! ****************************"
echo "************* Verify the MD5 Sums Above Are All OK!! ****************"
echo ""
#echo "########################## End Chapter 3.1 ##########################"
#echo "You are now ready to run:"
#echo "--> ./lfs-4.2-root.sh"
#echo ""
#
#exit 0
