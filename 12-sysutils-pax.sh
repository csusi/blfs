#!/bin/bash
echo ""
echo "### BLFS - Pax-070715 AKA heirloom   (0.1 SBU)"
echo "### ========================================================================="

## Change this.  May be run from dir its in or dir above.. ???
if [ ! -f ./blfs-include.sh ];then
    echo "*** Fatal Error - './blfs-include.sh' not found." ; exit 8 ; fi
source ./blfs-include.sh

BLFS_SECTION=blfs-sysutils
BLFS_SOURCE_FILE_PREFIX=heirloom
BLFS_LOG_FILE=/build-logs/$BLFS_SECTION-$BLFS_SOURCE_FILE_PREFIX
echo "BLFS $LFS_SOURCE_FILE_PREFIX started on $(date -u)" >> /build-logs/0-milestones.log

# Ideally, will retrieve and md5 check in script but doing that
# For initial packages as root on host OS
# BLFS_SOURCE_FTP_FQDN=openssl.org
# BLFS_SOURCE_FTP_PATH=source
BLFS_SOURCE_FILE_NAME="$(grep -o "MD5=$BLFS_SOURCE_FILE_PREFIX.*=[a-z0-9]*" ./wget-list-blfs | cut -d= -f2)"
BLFS_SOURCE_MD5="$(grep -o "MD5=$BLFS_SOURCE_FILE_PREFIX.*=[a-z0-9]*" ./wget-list-blfs | cut -d= -f3)"

echo "*** BLFS_SOURCE_FILE_NAME=$BLFS_SOURCE_FILE_NAME"
echo "*** BLFS_SOURCE_MD5=$BLFS_SOURCE_MD5"

echo "*** Validating the environment."
### While probably not always needed, for my needs keeping it in
check_user root

########## Extract Source and Change Directory ##########

### Add new code.  
### Has the package been installed before ?
###   If yes, is there an override option to re-install?
###     If Not, then exit and do not re-install
### Else 
###   Go ahead and install

cd /sources
test_only_one_tarball_exists
extract_tarball ""
cd $(ls -d /sources/$LFS_SOURCE_FILE_PREFIX*/)

########## Begin LFS Chapter Content ##########

time {
		
	echo "*** Running Pre-Configuration Tasks ... $BLFS_SOURCE_FILE_NAME"
	sed -i build/mk.config                   \
    -e '/LIBZ/s@ -Wl[^ ]*@@g'            \
    -e '/LIBBZ2/{s@^#@@;s@ -Wl[^ ]*@@g}' \
    -e '/BZLIB/s@0@1@'                   &&
	
	echo "*** Running Configure ... $BLFS_SOURCE_FILE_NAME"
	### None
	
	
	echo "*** Running Make ... $BLFS_SOURCE_FILE_NAME"
	make makefiles                           &&
	make -C libcommon                        &&
	make -C libuxre                          &&
	make -C cpio
	 
	
	echo "*** Running Make Check ... $BLFS_SOURCE_FILE_NAME"
	### None 
	
	echo "*** Running Make Install ... $BLFS_SOURCE_FILE_NAME"
	### None
	
	echo "*** Performing Post-Make Tasks ... $BLFS_SOURCE_FILE_NAME"
	install -v -m755 cpio/pax_su3 /usr/bin/pax &&
	install -v -m644 cpio/pax.1 /usr/share/man/man1
}

########## Chapter Clean-Up ##########

echo ""	
echo "*** Running Clean Up Tasks ... $BLFS_SOURCE_FILE_NAME"
cd /sources
[ ! $BLFS_DO_NOT_DELETE_SOURCES_DIRECTORY ] && rm -rf $(ls -d  /sources/$BLFS_SOURCE_FILE_PREFIX*/)

echo "$BLFS_SOURCE_FILE_NAME" >> /build-logs/0-installed.log

echo ""
show_build_errors ""
capture_file_list "" 
chapter_footer

if [ $BLFS_ERROR_COUNT -ne 0 ]; then
	exit 4
else
	exit
fi



