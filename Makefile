PREFIX		=  "/usr/local"
DIR_NETPIXI	=  "/opt/netpixi"

CONF_INETD	=  "etc/inetd.conf"
CONF_DHCPD	=  "etc/dhcpd.conf"
CONF_NETPIXI	=  "etc/netpixi.conf"
CONF_RC		=  "etc/rc.conf"
 
RCD_NETPIXI	=  "etc/rc.d/netpixi"

PKG_BOOTSTRAP	=  "/var/db/pkg/FreeBSD.meta"
PKG_SUDO	=  "${PREFIX}/bin/sudo"
PKG_LIGHTTPD	=  "${PREFIX}/bin/lighttpd"
PKG_NETSNMP	=  "${PREFIX}/bin/snmpget"
PKG_TCL		=  "${PREFIX}/bin/tclsh8.6"
PKG_TCLLIB	=  "${PREFIX}/lib/tcllib/pkgIndex.tcl"

REMOTE_REPO	=  "https://github.com/xk2600/netpixi.git"

### USE HOME DIRECTORY FOR REPO STORAGE IF NOT DEFINED PRIOR TO ENTRY.
REPO		?= "~/src"

all:
	echo no builds required. please 'make install' as root.

#### INSTALL PACKAGES #########################################################

${PKG_BOOTSTRAP}:
	env ASSUME_ALWAYS_YES=YES pkg bootstrap

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

update:
	git pull upstream master

uninstall:
	# TODO
	
