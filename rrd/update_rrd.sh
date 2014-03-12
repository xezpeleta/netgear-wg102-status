#! /bin/sh

# First you must run:
# rrdtool create wifi_clients.rrd -s 50 DS:ap1:GAUGE:300:0:60 DS:ap2:GAUGE:300:0:60 DS:ap3:GAUGE:300:0:60 DS:ap4:GAUGE:300:0:60 RRA:AVERAGE:0.5:1:600


DIR=`dirname $0`
. $DIR/../lib/netgear_functions.sh

checkData () {
    if [ "$1" = "<null>" ];then
        echo "u"
    else
        echo $1
    fi
}

ap1=$(checkData $(getClientCount 192.168.10.101))
ap2=$(checkData $(getClientCount 192.168.10.102))
ap3=$(checkData $(getClientCount 192.168.10.103))
ap4=$(checkData $(getClientCount 192.168.10.104))

echo $ap1 $ap2 $ap3 $ap4
/usr/bin/rrdtool updatev $DIR/wifi_clients.rrd N:$ap1:$ap2:$ap3:$ap4
