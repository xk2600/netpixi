# NETPIXI -
*Copyright 2019, Christopher M. Stephan - See [LICENSE](License.txt) for further information.*

Advanced PXE appliance for network device staging and deployment.

## Installation

Stupid simple method:

    **Verify Signature**
    fetch -qo - https://raw.githubusercontent.com/xk2600/netpixi/master/.install | sha256
    5353af61d147baa1c8e857db9f0ab190863e51e0bbb00fbc2b8628e82405e3bc

    **Execute**
    fetch -qo - https://raw.githubusercontent.com/xk2600/netpixi/master/.install | /bin/sh

## Filesystem Mapping

Application Root at /usr/local/www/netpixi/

| Path             | Description                    |
|------------------|--------------------------------|
| ./bin/           | CGI scripts (written in TCL)   |
| ./bootstrap/     | TFTP Root Directory            |
| ./data/          | Static content for Web Service |
| ./db/            | Database and archives          |
| ./doc/           | Documentation                  |

Related Files

/usr/local/etc/dhcpd.conf
NOTE: that /tftpboot is a symlink to /usr/local/www/netpixi/bootstrap

subnet 198.51.100.0 netmask 255.255.255.0 {

  range dynamic-bootp 198.51.100.100 198.51.100.199;

  default-lease-time 600;
  max-lease-time 7200;

  option domain-name-servers ns.netpixi.local;
  option domain-name "netpixi.local";
  option routers 198.51.100.1;
  option broadcast-address 198.51.100.255;

  option bootfile-name "/bootstrap-config";
  option tftp-server-address 198.51.100.1;

}



Workflow:

  1. Network Device boots.
  2. DHCP Server responds with:
     * IP Address in Network 198.51.100.0/24
     * Router at 198.51.100.1
     * bootfile-name (Option 67) "/bootstrap-config"
     * tftp-server-adddress (option 15): 198.51.100.1
  3. The Device applies bootstrap-config, which does the following:
     * sets hostname to 'bootstrapping'
     * creates username 'provisioner'
     * sets up eem environment and applet to allow management
     * sets script to launch tclsh executing /bootstrap.tcl on startup.
     * tells the management interface to 

