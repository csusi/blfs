#!/bin/bash
echo ""
echo "### BLFS - The LSB Core "
echo "### ========================================================================="

### Questions:  
### 1) Get source a) all at once? b) At once in batches c) Individually
### 2) Backup source? 
### 3) Check if installed already


### From LFS iv. - LFS and Standards
### http://www.linuxfromscratch.org/lfs/view/stable/prologue/standards.html
### http://refspecs.linuxfoundation.org/lsb.shtml

### Builds remaining packages required for an LSB-Core
###   At, Batch (a part of At), Cpio, Ed, Fcrontab, Initd-tools, 
###   Lsb_release, NSPR, NSS, PAM, Pax, Sendmail (or Postfix or Exim), time


if [ ! -f ./blfs-include.sh ];then
    echo "*** Fatal Error - './blfs-include.sh' not found." ; exit 8 ; fi
source ./blfs-include.sh

echo "*** Validating the environment."
check_user root     

echo "BLFS LSB_Core started on $(date -u)" >> /build-logs/0-milestones.log

time {
	
	### http://www.linuxfromscratch.org/blfs/view/stable/postlfs/lsb-release.html
	### No Req/Rec/Opt
	./3-afterlfs-lsb_release.sh
	
	### http://www.linuxfromscratch.org/blfs/view/stable/general/pax.html
	### No Req/Rec/Opt
	./12-sysutils-pax.sh

	### http://www.linuxfromscratch.org/blfs/view/stable/general/nspr.html
	### No Req/Rec/Opt
	./9-genlibs-nspr.sh

	## http://www.linuxfromscratch.org/blfs/view/stable/general/time.html
	## No Req/Rec/Opt
	./11-genutils-time.sh

	## http://www.linuxfromscratch.org/blfs/view/stable/postlfs/lsb-release.html
	## No Req/Rec/Opt
	./12-sysutils-initd-tools.sh
	
	### http://www.linuxfromscratch.org/blfs/view/stable/postlfs/nss.html
	### Req NSPR, Rec SQLite
	./4-security-nss.sh

## 	http://www.linuxfromscratch.org/blfs/view/stable/general/at.html
## Requires an MTA
#./sysutil/at.sh


### http://www.linuxfromscratch.org/blfs/view/stable/general/cpio.html
## Optional an MTA texlive-20150521 (or install-tl-unx)
#./sysutil/cpio.sh

### http://www.linuxfromscratch.org/blfs/view/stable/postlfs/ed.html
### Required to uncompress the tarball: libarchive-3.1.2 (for bsdtar)
#./editors/ed.sh

#Fcrontab

#PAM

#Sendmail (or Postfix or Exim)

}

echo "Chapter Ch. 6.51 to 6.70 finished on $(date -u)" >> /build-logs/0-milestones.log

echo ""
echo "########################## BLFS - The LSB Core  ##########################"
echo "*** "
echo "*** "
echo ""

