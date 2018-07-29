#!/bin/sh
snmpget -v 2c -m -Ov -m +CISCO-PRODUCTS-MIB -c $1 $2 sysObjectID.0 2>/dev/null | grep -o -E "[^:]*$"
