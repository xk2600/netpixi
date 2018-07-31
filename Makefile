
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
	@echo no build required.
	@echo
	@echo "  syntax: make [target]"
	@echo
	@echo "        target: install, install-packages,"
	@echo "                uninstall, uninstall-packages,"
	@echo "                update"
	@echo 
	
.PHONY: is-root
is-root:
	@test [ "x`whoami`x" == "xrootx" ] || echo must be root.

################################################ END GENERIC TARGETS ##########

#### NETPIXI INSTALLATION #####################################################

.PHONY: install
install: is-root
	# INSTALL DEPENDANT PACKAGES USING PKG
	@echo
	@echo ****************************************************
	-env ASSUME_ALWAYS_YES=YES pkg bootstrap
	-env ASSUME_ALWAYS_YES=YES pkg install ca_root_nss sudo git lighttpd net-snmp tcl86 tcllib
	
	# INSTALL NETPIXI TO CORRECT PATH
	@echo
	@echo ****************************************************
	-mkdir -p ${DIR_NETPIXI}
	-cd ${DIR_NETPIXI} ; git clone ${REMOTE_REPO}
	
	# CREATE DIRECTORY STRUCTURE FOR ${PREFIX}/www/netpixi/{bin,data}
	@echo 
	@echo  linkin ${PREFIX}/www/netpixi/{bin,data}...
	-mkdir -p ${PREFIX}/www/netpixi/
	-ln -s ${DIR_NETPIXI}/netpixi/bin  ${PREFIX}/www/netpixi/bin
	-ln -s ${DIR_NETPIXI}/netpixi/data ${PREFIX}/www/netpixi/data
	
	# CREATE SYMLINKS
	-rm /${CONF_INETD}
	-ln -s ${DIR_NETPIXI}/${CONF_INETD}   /${CONF_INETD}
	-rm /${PREFIX}/${CONF_DHCPD}
	-ln -s ${DIR_NETPIXI}/${CONF_DHCPD}   /${PREFIX}/${CONF_DHCPD}
	-ln -s ${DIR_NETPIXI}/${CONF_NETPIXI} /${PREFIX}/${CONF_NETPIXI}
	-ln -s ${DIR_NETPIXI}/${RCD_NETPIXI}  /${PREFIX}/${RCD_NETPIXI}
	-ln -s ${DIR_NETPIXI}/bootstrap /tftpboot ;
	
	@echo Add the following lines to your rc.conf:
	@echo
	@cat ${DIR_NETPIXI}/${CONF_RC}
	@echo



################################################ END NETPIXI INSTALLATION #####

.PHONY: update
update:
	cd ${DIR_NETPIXI}
	git pull

.PHONY: uninstall-packages
uninstall-packages:
	# UNINSTALL DEPENDANT PACKAGES USING PKG
	@echo
	@echo ****************************************************
	-env ASSUME_ALWAYS_YES=YES pkg remove ca_root_nss sudo git lighttpd net-snmp tcl86 tcllib

.PHONY: uninstall
uninstall: uninstall-packages
	
	# INSTALL NETPIXI TO CORRECT PATH
	@echo
	@echo ****************************************************
	-rm -Rf ${DIR_NETPIXI}
	
	# CREATE DIRECTORY STRUCTURE FOR ${PREFIX}/www/netpixi/{bin,data}
	@echo 
	-rm ${PREFIX}/www/netpixi/bin
	-rm ${PREFIX}/www/netpixi/data
	
	# CREATE SYMLINKS
	-rm /${CONF_INETD}
	-rm /${PREFIX}/${CONF_DHCPD}
	-rm /${PREFIX}/${CONF_NETPIXI}
	-rm /${PREFIX}/${RCD_NETPIXI}
	-rm /tftpboot ;
	
	@echo Add the following lines to your rc.conf:
	@echo
	@cat ${DIR_NETPIXI}/${CONF_RC}
	@echo

