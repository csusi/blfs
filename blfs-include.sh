

### Setting the '-j4' switch on all of the 'make' commands to use all four   
### processors of the VM. This can cause race conditions when compiling some 
### packages. If encountered, set 'LFS_MAKE_FLAGS='within the bash script 
### in the pre-configuration tasks.
BLFS_MAKE_FLAGS=-j4


############################ Functions #############################

function check_user {
	if [ $( whoami ) != "$1" ]; then 
  	echo "*** Fatal Error - Script must be run as $1" 
  	exit 6 
  fi
}

function test_only_one_tarball_exists {
	echo "*** Validating one and only one tarball exists."
	BLFS_SOURCE_FILE_NAME=$(ls | egrep "^$BLFS_SOURCE_FILE_PREFIX.+tar")
	BLFS_SOURCE_FILE_COUNT=$(ls | egrep "^$BLFS_SOURCE_FILE_PREFIX.+tar" | wc -l)
	if [ $BLFS_SOURCE_FILE_COUNT -eq 0 ]; then
		echo "*** No '$BLFS_SOURCE_FILE_PREFIX' tarballs found.  Exiting script."
		exit 2
	elif [ $BLFS_SOURCE_FILE_COUNT -gt 1 ]; then
		echo "*** Multiple '$BLFS_SOURCE_FILE_PREFIX' tarballs found ($BLFS_SOURCE_FILE_COUNT).  Exiting script."
		exit 3
	fi
}

function extract_tarball {
	# Function takes in one variable, which determines if there is a preceeding 
	# path to where the new LFS OS root directory will be.  This is necessary for
	# much of Chapter 5, when writing directly to the LFS_MOUNT_DIR path. After
	# 6.4, when the root account has chrooted to the LFS_MOUNT_DIR path,
	# specifying this path will no longer be necessary and /sources will be off
	# the root of the directory structure.  
	
	
	echo "*** Extracting ... $BLFS_SOURCE_FILE_NAME"
	if [ ! -d /sources/$BLFS_SOURCE_FILE_PREFIX*/  ]; then
	    echo "*** Source directory does not exist. Extracting ... $BLFS_SOURCE_FILE_NAME"
	    tar xf $BLFS_SOURCE_FILE_NAME
	else
	    echo "*** Source directory found matching prefix '$BLFS_SOURCE_FILE_PREFIX'.  Not Extracting"
	    BLFS_DO_NOT_DELETE_SOURCES_DIRECTORY=1
	fi
}

function show_build_errors {
	# Function takes in one variable, which determines if there is a preceeding 
	# path to where the new LFS OS root directory will be.  This is necessary for
	# much of Chapter 5, when writing directly to the LFS_MOUNT_DIR path. After
	# 6.4, when the root account has chrooted to the LFS_MOUNT_DIR path,
	# specifying this path will no longer be necessary and /sources will be off
	# the root of the directory structure.  

	BLFS_WARNING_COUNT=0
  LFS_ERROR_COUNT=0

	BLFS_WARNING_COUNT=$(grep -n " [Ww]arnings*:* " /build-logs/$BLFS_SECTION* | wc -l)
	BLFS_ERROR_COUNT=$(grep -n " [Ee]rrors*:* \|^FAIL:" /build-logs/$BLFS_SECTION* | wc -l)
	
	
#  ### Commenting this block out because some sections generate a lot of warnings that
#  ### are mostly noise.  Uncomment if desired to display them.
#	if [ $LFS_WARNING_COUNT -ne 0 ]; then
#	    echo "*** $LFS_WARNING_COUNT Warnings In Build Logs for ... $LFS_SOURCE_FILE_NAME"
#	    grep -n " [Ww]arnings*:* " $ROOT_PATH/build-logs/$LFS_SECTION*
#	else 
#		  echo "*** $LFS_WARNING_COUNT Warnings In Build Logs for ... $LFS_SOURCE_FILE_NAME"
#	fi


	if [ $BLFS_ERROR_COUNT -ne 0 ]; then
	    echo "*** $BLFS_ERROR_COUNT Errors Found In Build Logs for ... $BLFS_SOURCE_FILE_NAME"
	    grep -n " [Ee]rrors*:* \|^FAIL:" /build-logs/$BLFS_SECTION*
	    echo "Compare against known good logs at: http://www.linuxfromscratch.org/lfs/build-logs"
	else 
		  echo "*** $BLFS_ERROR_COUNT Errors Found In Build Logs for ... $BLFS_SOURCE_FILE_NAME"
	fi
}

function capture_file_list {
  ### Not in the book. Capturing file list to see what files are added.
	### To see how the expected file system grows with each chapter, this is
	### cutting out the /proc /sys /dev and sources/build-logs/tools directories

	# Function takes in one variable, which determines if there is a preceeding 
	# path to where the new LFS OS root directory will be.  This is necessary for
	# much of Chapter 5, when writing directly to the LFS_MOUNT_DIR path. After
	# 6.4, when the root account has chrooted to the LFS_MOUNT_DIR path,
	# specifying this path will no longer be necessary and /sources will be off
	# the root of the directory structure.  
	
	find / \
	  -path /proc -prune \
	  -or -path /sys -prune  \
	  -or -path /dev -prune  \
	  -or -path /sources -prune  \
	  -or -print \
	  &> /build-logs/$BLFS_SECTION-filelist-chapter-end.log 
}


function chapter_footer {
	echo
	echo "### Error Count: $BLFS_ERROR_COUNT    Warning Count: $BLFS_WARNING_COUNT"
	echo "############ End Section $BLFS_SECTION ################################"
	echo 
}

function show_first_ten_errors_in_section_logs {
	CHAPTER=$1
	START_SECTION=$2
	END_SECTION=$3
	case $CHAPTER in
		"5") 
			ROOT_PATH=$LFS_MOUNT_DIR
			echo $ROOT_PATH
			;;
		"6")
			ROOT_PATH=""
			;;
		*)
			echo "*** FATAL ERROR - invalid chapter designation.  Check function call."
			exit
			;;
	esac
		
	  
	echo "*** Displaying first 10 errors from logs."
	for (( i=$START_SECTION ; i <= $END_SECTION ; i++ ))
	do
		echo "--> grep -n \" [Ee]rrors*:* \|^FAIL:\" $ROOT_PATH/build-logs/$CHAPTER.$i-* | head -n 10"
		grep -n " [Ee]rrors*:* \|^FAIL:" $ROOT_PATH/build-logs/$CHAPTER.$i-* | head -n 10
		echo ""
	done
}

function check_MD5_sums {
	echo "*** Checking MD5"
	if [ "$BLFS_SOURCE_MD5" == "$(md5sum ./$BLFS_SOURCE_FILE_NAME | cut -d' ' -f1)" ]; then
		echo "*** Stored MD5 Matches Computed MD5 From File"
	else
		echo "*** WARNING: The stored MD5 sum in the 'blfs-wget-list' does not match"
		echo "*** the computed MD5 from the downloaded version.  This may be because a "
		echo "*** new version was added in the 'blfs-wget-list' file and the MD5"
		echo "*** was not updated, or a new file was added at the source that differs"
		echo "*** from the previously computed MD5.  Proceed at caution."
		read -p "*** Do you want to continue [Yy]? " -n 1 -r
		echo
		  if [[ $REPLY =~ ^[Yy]$ ]]; then 
			echo "*** Continuing with mis-matching MD5 sums."
		  else 
			exit 16
		  fi	
	fi
}

