
#### USER CONFIGURATION #######################################################

REPO            =  /root/src
PREFIX		=  /usr/local
DIR_NETPIXI	=  /opt/netpixi


###############################################################################

CONF_INETD	=  etc/inetd.conf
CONF_DHCPD	=  etc/dhcpd.conf
CONF_NETPIXI	=  etc/netpixi.conf
CONF_RC		=  etc/rc.conf
 
RCD_NETPIXI	=  etc/rc.d/netpixi

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

.PHONY: output-vars
output-vars:
	@echo REPO         = ${REPO}
	@echo PREFIX	   = ${PREFIX}
	@echo DIR_NETPIXI  = ${DIR_NETPIXI}
	@echo CONF_INETD   = ${CONF_INETD}
	@echo CONF_DHCPD   = ${CONF_DHCPD}
	@echo CONF_NETPIXI = ${CONF_NETPIXI}
	@echo CONF_RC      = ${CONF_RC}
	@echo RCD_NETPIXI  = ${RCD_NETPIXI}
	@echo REMOTE_REPO  = ${REMOTE_REPO}


################################################ END GENERIC TARGETS ##########

#### NETPIXI INSTALLATION #####################################################

.PHONY: install
install: is-root output-vars
	# INSTALL DEPENDANT PACKAGES USING PKG
	@echo
	@echo ****************************************************
	-env ASSUME_ALWAYS_YES=YES pkg bootstrap
	-env ASSUME_ALWAYS_YES=YES pkg install ca_root_nss sudo git lighttpd net-snmp tcl86 tcllib
	
	# INSTALL NETPIXI TO CORRECT PATH
	@echo
	@echo ****************************************************
	-mkdir -p ${REPO}
	-mkdir -p ${DIR_NETPIXI}
	-mkdir -p ${DIR_NETPIXI}/log
	-mkdir -p ${PREFIX}/www/netpixi/
	
	# CLONE REPO, COPY NECESSARY FILES TO INSTALL AREA.
	@echo
	@echo ****************************************************
	-git clone ${REMOTE_REPO} ${REPO}
	@echo 
	@echo
	-cp -R   ${REPO}/netpixi/bootstrap ${DIR_NETPIXI}
	-cp -R   ${REPO}/netpixi/db        ${DIR_NETPIXI}
	-cp -R   ${REPO}/netpixi/doc       ${DIR_NETPIXI}
	-cp -R   ${REPO}/netpixi/etc       ${DIR_NETPIXI}
	-cp -R   ${REPO}/netpixi/www       ${DIR_NETPIXI}
	
	@echo
	@echo ****************************************************
	@echo
	-rm /${CONF_INETD}
	-rm /${PREFIX}/${CONF_DHCPD}
			
	# CREATE WEB INTERFACE SYMLINKS
	@echo 
	@echo ****************************************************
	@echo
	-ln -s   ${DIR_NETPIXI}/netpixi/bin  ${PREFIX}/www/netpixi/bin
	-ln -s   ${DIR_NETPIXI}/netpixi/data ${PREFIX}/www/netpixi/data
	
	@echo
	# CREATE CONF/RC.D SYMLINKS
	-ln -s   ${DIR_NETPIXI}/${CONF_INETD}   /${CONF_INETD}
	-ln -s   ${DIR_NETPIXI}/${CONF_DHCPD}   /${PREFIX}/${CONF_DHCPD}
	-ln -s   ${DIR_NETPIXI}/${CONF_NETPIXI} /${PREFIX}/${CONF_NETPIXI}
	-ln -s   ${DIR_NETPIXI}/${RCD_NETPIXI}  /${PREFIX}/${RCD_NETPIXI}
	
	@echo
	# CREATE TFTPBOOT SYMLINK
	-ln -s   ${DIR_NETPIXI}/bootstrap       /tftpboot
	
	# CREATE LOG DIRECTORY SYMLINK
	-ln -s   ${DIR_NETPIXI}/log             /var/log/netpixi
	
	@echo
	@echo Add the following lines to your rc.conf:
	@echo
	@cat ${DIR_NETPIXI}/${CONF_RC}
	@echo



################################################ END NETPIXI INSTALLATION #####

.PHONY: update
update: 
	cd ${DIR_NETPIXI} ; git pull

.PHONY: uninstall-packages
uninstall-packages:
	# UNINSTALL DEPENDANT PACKAGES USING PKG
	@echo
	@echo ****************************************************
	-env ASSUME_ALWAYS_YES=YES pkg remove ca_root_nss sudo git lighttpd net-snmp tcl86 tcllib

.PHONY: uninstall
uninstall:
	
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

