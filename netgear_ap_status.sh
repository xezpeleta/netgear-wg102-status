#! /bin/sh

HOSTS="192.168.10.101 192.168.10.102 192.168.10.103 192.168.10.104 192.168.10.105 192.168.10.106"
COMMUNITY="public"

DIR=`dirname $0`
. $DIR/lib/netgear_functions.sh

getNetgearStatus () {
    printf "%-14s %-18s %-10s %-10s %-15s %-10s\n" "IP" "Description" "Clients" "Uptime" "Firmware" "Freemem"
    printf "====================================================================================\n"
    for i in $HOSTS
    do
        sysname=$(getSysname $i)
        uptime=$(getUptime $i)
        clients=$(getClientCount $i)
        firmware=$(getFirmware $i)
        memory=$(getFreeMemory $i)
        printf "%-14s %-18s %-10s %-10s %-15s %-10s\n" "$i" "$sysname" "$clients" "$uptime" "$firmware" "$memory"
    done
}


getNetgearStatus
