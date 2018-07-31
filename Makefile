
### NOTES:
#
# Quick install:
#     /usr/bin/pkg install ca_root_nss
#     /usr/bin/fetch -qo - https://git.io/fj7oc | /usr/bin/make -f - remote
# 
# 

PREFIX		=  /usr/local
DIR_NETPIXI	=  /opt/netpixi

CONF_INETD	=  etc/inetd.conf
CONF_DHCPD	=  etc/dhcpd.conf
CONF_NETPIXI	=  etc/netpixi.conf
CONF_RC		=  etc/rc.conf
 
RCD_NETPIXI	=  etc/rc.d/netpixi

PKG_BOOTSTRAP	=  /var/db/pkg/FreeBSD.meta
PKG_CAROOT      =  /etc/ssl/cert.pem
PKG_GIT		=  ${PREFIX}/bin/git
PKG_SUDO	=  ${PREFIX}/bin/sudo
PKG_LIGHTTPD	=  ${PREFIX}/bin/lighttpd
PKG_NETSNMP	=  ${PREFIX}/bin/snmpget
PKG_TCL		=  ${PREFIX}/bin/tclsh8.6
PKG_TCLLIB	=  ${PREFIX}/lib/tcllib/pkgIndex.tcl

REMOTE_REPO	=  https://github.com/xk2600/netpixi.git

#### GENERIC TARGETS ##########################################################

.PHONY: all
all:
	# DEFAULT MAKE
	@echo no builds required. 'make remote' or 'make install'
	
.PHONY: is-root
is-root:
	@test [ "x`whoami`x" == "xrootx" ] || echo must be root.

.PHONY: repo-defined
repo-defined:
.ifndef REPO
	@while [ 1 == 1 ] ; \
	 do \
	  echo "Repository Location? (~) " ; \
	  read REPO ; \
	  [ "x$${REPO}x" == "xx" ] && REPO="~" ; \
	  [ -d $${REPO} ] && break || echo "$${REPO} is not a directory or does not exist." ; \
	 done ; \
	/usr/bin/fetch -qo - ${REMOTE_MAKEFILE} | REPO=${REPO} /usr/bin/make -f - remote ; \
	exit 0
.endif

################################################ END GENERIC TARGETS ##########

#### INSTALL PACKAGES #########################################################

${PKG_CAROOT}:
	@echo "pkg required: ca_root_nss"

${PKG_SUDO}: 
	@echo "pkg required: sudo"

${PKG_GIT}: 
	@echo "pkg required: git"

${PKG_LIGHTTPD}: 
	@echo "pkg required: lighttpd"

${PKG_NETSNMP}: 
	@echo "pkg required: net-snmp"

${PKG_TCL}: 
	@echo "pkg required: tcl86"

${PKG_TCLLIB}: 
	@echo "pkg required: tcllib"

.PHONY: install-packages
install-packages: ${PKG_SUDO} ${PKG_LIGHTTPD} ${PKG_NETSNMP} ${PKG_TCL} ${PKG_TCLLIB}

################################################ END INSTALL PACKAGES #########

#### NETPIXI INSTALLATION #####################################################

${PREFIX}/www/netpixi:
	# CREATE DIRECTORY STRUCTURE FOR ${PREFIX}/www/netpixi/{bin,data}
	@echo 
	@echo  linkin ${PREFIX}/www/netpixi/{bin,data}...
	@mkdir -p ${PREFIX}/www/netpixi/
	ln -s ${DIR_NETPIXI}/netpixi/bin  ${PREFIX}/www/netpixi/bin
	ln -s ${DIR_NETPIXI}/netpixi/data ${PREFIX}/www/netpixi/data

${DIR_NETPIXI}:
	# INSTALL NETPIXI TO CORRECT PATH
	@mkdir -p ${DIR_NETPIXI}
	@echo 
	@echo " Copying ${REPO}/.* to ${DIR_NETPIXI} :"
	@cp -R ${REPO}/.* ${DIR_NETPIXI}

.PHONY: install-netpixi
install-netpixi: ${DIR_NETPIXI}

# BACKUP AND SYMLINK inetd.conf
/${CONF_INETD}.original:
	echo 
	echo " ${.target}: "
	mv /${CONF_INETD} /${CONF_INETD}.original
	ln -s ${DIR_NETPIXI}/${CONF_INETD}   /${CONF_INETD}

# BACKUP AND SYMLINK dhcpd.conf
/${PREFIX}/${CONF_DHCPD}.original:
	echo 
	echo " ${.target}: "
	mv /${PREFIX}/${CONF_DHCPD} /${PREFIX}/${CONF_DHCPD}.original
	ln -s ${DIR_NETPIXI}/${CONF_DHCPD}   /${PREFIX}/${CONF_DHCPD}

# SYMLINK netpixi.conf
/${PREFIX}/${CONF_NETPIXI}:
	echo " ${.target}: "
	ln -s ${DIR_NETPIXI}/${CONF_NETPIXI} /${PREFIX}/${CONF_NETPIXI}

/${PREFIX}/${RCD_NETPIXI}:
	ln -s ${DIR_NETPIXI}/${RCD_NETPIXI}  /${PREFIX}/${RCD_NETPIXI}

.PHONY: create-symlinks
create-symlinks: ${PREFIX}/www/netpixi
	@echo " /tftproot: "
	# create tftproot symlink to netpixi/bootstrap
	mv /tftproot /tftproot.old
	ln -s ${DIR_NETPIXI}/bootstrap /tftproot
	@echo
	@echo *************************************************************
	@echo * MAKE SURE YOU VERIFY NOTHING IMPORTANT IS IN TFTPROOT.OLD *
	@echo * BEFORE REMOVAL!                                           *
	@echo *************************************************************
	@echo
	
	@echo Add the following lines to your rc.conf:
	@echo
	@cat ${DIR_NETPIXI}/${CONF_RC}
	@echo

	
#install: install-packages install-netpixi create-symlinks
install: install-netpixi create-symlinks

################################################ END NETPIXI INSTALLATION #####

#### FETCH NETPIXI REPO #######################################################

${REPO}/netpixi:
	# CLONE REMOTE REPO INTO LOCAL REPOSITORY
	@mkdir -p ${REPO}
	@cd ${REPO}
	@echo "${REPO}/netpixi: "
	git clone ${REMOTE_REPO}

remote: is-root repo-defined fetch-repo-header ${PKG_CAROOT} ${PKG_GIT} ${REPO}/netpixi
	# CALL REMOTE INSTALL SCRIPT... WHICH REALLY JUST EXECUTES THIS MAKEFILE AGAIN
	# AFTER GRABBING THE MOST RECENT VERSION. 
	#fetch -qo - https://raw.githubusercontent.com/xk2600/netpixi/master/.install | /bin/sh	
	#git remote add upstream https://github.com/xk2600/netpixi.git
	
################################################ END FETCH REPO ###############


update:
	git pull upstream master

uninstall:
	# TODO
	
