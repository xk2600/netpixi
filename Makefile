
### NOTES:
#
# Quick install:
#     /usr/bin/pkg install ca_root_nss
#     /usr/bin/fetch -qo - https://git.io/fj7oc | /usr/bin/make -f - remote
# 
# 

PREFIX		=  "/usr/local"
DIR_NETPIXI	=  "/opt/netpixi"

CONF_INETD	=  "etc/inetd.conf"
CONF_DHCPD	=  "etc/dhcpd.conf"
CONF_NETPIXI	=  "etc/netpixi.conf"
CONF_RC		=  "etc/rc.conf"
 
RCD_NETPIXI	=  "etc/rc.d/netpixi"

PKG_BOOTSTRAP	=  "/var/db/pkg/FreeBSD.meta"
PKG_CAROOT      =  "/etc/ssl/cert.pem"
PKG_SUDO	=  "${PREFIX}/bin/sudo"
PKG_LIGHTTPD	=  "${PREFIX}/bin/lighttpd"
PKG_NETSNMP	=  "${PREFIX}/bin/snmpget"
PKG_TCL		=  "${PREFIX}/bin/tclsh8.6"
PKG_TCLLIB	=  "${PREFIX}/lib/tcllib/pkgIndex.tcl"

REMOTE_REPO	=  "https://github.com/xk2600/netpixi.git"

### USE HOME DIRECTORY FOR REPO STORAGE IF NOT DEFINED PRIOR TO ENTRY.
REPO		?= "~/src"

#### INITIAL TARGETS ##########################################################

all:
	# DEFAULT MAKE
	[ "x`whoami`x" != "xrootx" ] && echo error: requires root. && exit -1
	echo no builds required. 'make remote' or 'make install'



################################################ END INITIAL TARGETS ##########

#### INSTALL PACKAGES #########################################################

${PKG_BOOTSTRAP}:
	env ASSUME_ALWAYS_YES=YES pkg bootstrap

${PKG_CAROOT}:
	pkg install ca_root_nss

${PKG_SUDO}: ${PKG_BOOTSTRAP}
	pkg install sudo

${PKG_GIT}: ${PKG_BOOTSTRAP}
	pkg install git

${PKG_LIGHTTPD}: ${PKG_BOOTSTRAP}
	pkg install lighttpd

${PKG_NETSNMP}: ${PKG_BOOTSTRAP}
	pkg install net-snmp

${PKG_TCL}: ${PKG_BOOTSTRAP}
	pkg install tcl86

${PKG_TCLLIB}: ${PKG_BOOTSTRAP}
	pkg install tcllib

install-packages: ${PKG_SUDO} ${PKG_LIGHTTPD} ${PKG_NETSNMP} ${PKG_TCL} ${PKG_TCLLIB}

################################################ END INSTALL PACKAGES #########

#### NETPIXI INSTALLATION #####################################################

${PREFIX}/www/netpixi:
	# CREATE DIRECTORY STRUCTURE FOR ${PREFIX}/www/netpixi/{bin,data}
	mkdir -p ${PREFIX}/www/netpixi/
	ln -s ${DIR_NETPIXI}/netpixi/bin  ${PREFIX}/www/netpixi/bin
	ln -s ${DIR_NETPIXI}/netpixi/data ${PREFIX}/www/netpixi/data


${DIR_NETPIXI}:
	# INSTALL NETPIXI TO CORRECT PATH
	mkdir -p ${DIR_NETPIXI}

${REPO}/netpixi:
	# CLONE REMOTE REPO INTO LOCAL REPOSITORY
	mkdir -p ${REPO}
	cd ${REPO}
	git clone ${REMOTE_REPO}

install-netpixi: ${DIR_NETPIXI}
	cp -R ${REPO}/.* ${DIR_NETPIXI}

create-symlinks: ${PREFIX}/www/netpixi
	# create tftproot symlink to netpixi/bootstrap
	mv /tftproot /tftproot.old
	ln -s ${DIR_NETPIXI}/bootstrap /tftproot
	echo *************************************************************
	echo * MAKE SURE YOU VERIFY NOTHING IMPORTANT IS IN TFTPROOT.OLD *
	echo * BEFORE REMOVAL!                                           *
	echo *************************************************************
	
	# CONF/RC.D FILES:
	ln -s ${DIR_NETPIXI}/${CONF_INETD}   /${CONF_INETD}
	ln -s ${DIR_NETPIXI}/${CONF_DHCPD}   /${PREFIX}/${CONF_DHCPD}
	ln -s ${DIR_NETPIXI}/${CONF_NETPIXI} /${PREFIX}/${CONF_NETPIXI}
	ln -s ${DIR_NETPIXI}/${CONF_RC}      /${CONF_RC}
	ln -s ${DIR_NETPIXI}/${RCD_NETPIXI}  /${PREFIX}/${RCD_NETPIXI}
	

	
install: install-packages install-netpixi create-symlinks
	git remote add upstream https://github.com/xk2600/netpixi.git

remote: ${PKG_CAROOT}
	# CALL REMOTE INSTALL SCRIPT... WHICH REALLY JUST EXECUTES THIS MAKEFILE AGAIN
	# AFTER GRABBING THE MOST RECENT VERSION. 
	#fetch -qo - https://raw.githubusercontent.com/xk2600/netpixi/master/.install | /bin/sh	
	# INSTEAD OF FETCH, JUST DO IT INLINE:
	{ \
	  [ "x`whoami`x" == "xrootx" ] || { echo "must be root. please try again..." ; exit -1 ; } ; \
	  while [ 1 == 1 ] ; \
	   do \
	    printf "Where would you like keep the local copy of the repo? (~) " ; read REPO ; \
	    [ "x$${REPO}x" == "xx" ] && REPO="~" ; \
	    [ -d $${REPO} ] && break || { echo "$${REPO} is not a directory or does not exist." ; } ; \
	   done ; \
	  \
	  TMPDIR=`mktemp` ; \
	  cd $${TMPDIR} ; \
	  while [ 1 == 1 ] ; \
	    do \
	      printf "       (y,n) " ; read Q ; \
	      [ "x${Q}x" == "xyx" ] && break ; \
	      [ "x${Q}x" == "xnx" ] && quit -1 ; \
	      printf "...Not an option.\n Again, " ; \
	    done ; \
	  \
	  fetch -qo -  https://raw.githubusercontent.com/xk2600/netpixi/master/Makefile | REPO=$${REPO} make -f - install ; \
	  REPO=$${REPO} make install ; \
	  rm -Rf $${TMPDIR} ; \
	}
	
update:
	git pull upstream master

uninstall:
	# TODO
	
