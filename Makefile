
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
PKG_GIT		=  "${PREFIX}/bin/git"
PKG_SUDO	=  "${PREFIX}/bin/sudo"
PKG_LIGHTTPD	=  "${PREFIX}/bin/lighttpd"
PKG_NETSNMP	=  "${PREFIX}/bin/snmpget"
PKG_TCL		=  "${PREFIX}/bin/tclsh8.6"
PKG_TCLLIB	=  "${PREFIX}/lib/tcllib/pkgIndex.tcl"

REMOTE_REPO	=  "https://github.com/xk2600/netpixi.git"

#### GENERIC TARGETS ##########################################################

.PHONY: all
all:
	# DEFAULT MAKE
	echo no builds required. 'make remote' or 'make install'
	
.PHONY: is-root
is-root:
	[ "x`whoami`x" == "xrootx" ] || { echo "must be root. please try again..." ; exit -1 ; } 

.PHONY: continue
continue:
	while [ 1 == 1 ] ;  do printf "Continue? (y,n) " ; read Q ; \
	  [ "x$${Q}x" == "xyx" ] && break ; [ "x$${Q}x" == "xnx" ] && quit -1 ; printf "...Not an option.\n Again, " ; done ; \

.PHONY: repo-defined
repo-defined:
.ifndef REPO
	@.error "REPOSITORY LOCATION MUST BE DEFINED PRIOR TO MAKING ****\n  REPO=/path/to/location/for/repository\n  /usr/bin/fetch -qo - ${REMOTE_MAKEFILE} | REPO=${REPO} /usr/bin/make -f - remote\n\n"
	#while [ 1 == 1 ] ; do printf "Repository Location? (~) " ; read REPO ; \
	#  [ "x$${REPO}x" == "xx" ] && REPO="~" ; [ -d $${REPO} ] && break || echo "$${REPO} is not a directory or does not exist." ; \
	#done ; \
	#/usr/bin/fetch -qo - ${REMOTE_MAKEFILE} | REPO=${REPO} /usr/bin/make -f - remote ; \
	#exit 0
.endif

################################################ END GENERIC TARGETS ##########

#### INSTALL PACKAGES #########################################################

.PHONY: pkg-header
pkg-header:
	printf "\n\n"
	printf "***********************************************************"
	printf "******* Installing Packages: \n"

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

.PHONY: install-packages
install-packages: pkg-header ${PKG_SUDO} ${PKG_LIGHTTPD} ${PKG_NETSNMP} ${PKG_TCL} ${PKG_TCLLIB}
	printf "\n\n"
	printf "******* Packages installed \n"
	printf "***********************************************************\n"
################################################ END INSTALL PACKAGES #########

#### NETPIXI INSTALLATION #####################################################

.PHONY: netpixi-header
netpixi-header:
	printf "\n\n"
	printf "***********************************************************"
	printf "******* Installing netPixi: \n"

${PREFIX}/www/netpixi:
	# CREATE DIRECTORY STRUCTURE FOR ${PREFIX}/www/netpixi/{bin,data}
	mkdir -p ${PREFIX}/www/netpixi/
	ln -s ${DIR_NETPIXI}/netpixi/bin  ${PREFIX}/www/netpixi/bin
	ln -s ${DIR_NETPIXI}/netpixi/data ${PREFIX}/www/netpixi/data

${DIR_NETPIXI}:
	# INSTALL NETPIXI TO CORRECT PATH
	@mkdir -p ${DIR_NETPIXI}
	@printf "\n\n"
	@printf ">>>> Copying ${REPO}/.* to ${DIR_NETPIXI} :\n"
	@cp -R ${REPO}/.* ${DIR_NETPIXI}

.PHONY: install-netpixi
install-netpixi: ${DIR_NETPIXI}

# BACKUP AND SYMLINK inetd.conf
/${CONF_INETD}.original:
	printf "\n\n"
	printf ">>>> ${.target}: \n"
	mv /${CONF_INETD} /${CONF_INETD}.original
	ln -s ${DIR_NETPIXI}/${CONF_INETD}   /${CONF_INETD}

# BACKUP AND SYMLINK dhcpd.conf
/${PREFIX}/${CONF_DHCPD}.original:
	printf "\n\n"
	printf ">>>> ${.target}: \n"
	mv /${PREFIX}/${CONF_DHCPD} /${PREFIX}/${CONF_DHCPD}.original
	ln -s ${DIR_NETPIXI}/${CONF_DHCPD}   /${PREFIX}/${CONF_DHCPD}

# SYMLINK netpixi.conf
/${PREFIX}/${CONF_NETPIXI}:
	printf "\n\n"
	printf ">>>> ${.target}: \n"
	ln -s ${DIR_NETPIXI}/${CONF_NETPIXI} /${PREFIX}/${CONF_NETPIXI}

/${PREFIX}/${RCD_NETPIXI}:
	ln -s ${DIR_NETPIXI}/${RCD_NETPIXI}  /${PREFIX}/${RCD_NETPIXI}

.PHONY: create-symlinks
create-symlinks: ${PREFIX}/www/netpixi
	@printf "\n\n>>>> /tftproot:\n"
	# create tftproot symlink to netpixi/bootstrap
	mv /tftproot /tftproot.old
	ln -s ${DIR_NETPIXI}/bootstrap /tftproot
	@echo
	@echo *************************************************************
	@echo * MAKE SURE YOU VERIFY NOTHING IMPORTANT IS IN TFTPROOT.OLD *
	@echo * BEFORE REMOVAL!                                           *
	@echo *************************************************************
	@echo
	
	@printf "Add the following lines to your rc.conf:\n\n"
	@cat ${DIR_NETPIXI}/${CONF_RC}
	@printf "\n\n"

	
install: netpixi-header install-packages install-netpixi create-symlinks
	printf "\n\n"
	printf "******* Packages installed \n"
	printf "***********************************************************\n"

################################################ END NETPIXI INSTALLATION #####

#### FETCH NETPIXI REPO #######################################################

.PHONY: fetch-repo-header
fetch-repo-header:
	printf "\n\n"
	printf "***********************************************************"
	printf "******* Fetching Repository: \n"

${REPO}/netpixi:
	# CLONE REMOTE REPO INTO LOCAL REPOSITORY
	@mkdir -p ${REPO}
	@cd ${REPO}
	@printf "${REPO}/netpixi: "
	git clone ${REMOTE_REPO}

remote: is-root repo-defined fetch-repo-header ${PKG_CAROOT} ${PKG_GIT} ${REPO}/netpixi
	# CALL REMOTE INSTALL SCRIPT... WHICH REALLY JUST EXECUTES THIS MAKEFILE AGAIN
	# AFTER GRABBING THE MOST RECENT VERSION. 
	#fetch -qo - https://raw.githubusercontent.com/xk2600/netpixi/master/.install | /bin/sh	
	#git remote add upstream https://github.com/xk2600/netpixi.git
	printf "\n\n"
	printf "******* Repository Ready. \n"
	printf "***********************************************************\n"
	
################################################ END FETCH REPO ###############


update:
	git pull upstream master

uninstall:
	# TODO
	
