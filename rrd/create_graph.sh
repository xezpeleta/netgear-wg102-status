#!/bin/sh

DIR=`dirname $0`

rrd=$DIR/wifi_clients.rrd
last=`rrdtool last $rrd`
file1=$DIR/dia.png
date=`date +date +%Y-%m-%d-%H.%M`
width=800
height=450

#from: http://stackoverflow.com/a/10014969
ap1_color="#00ffff"
ap2_color="#000000"
ap3_color="#0000ff"
ap4_color="#ff00ff"
ap5_color="#008b8b"
ap6_color="#006400"
ap7_color="#8b008b"
ap8_color="#ff8c00"
ap9_color="#8b0000"
ap10_color="#9400d3"
ap11_color="#ffd700"
ap12_color="#4b0082"
ap13_color="#add8e6"
ap14_color="#90ee90"


# Last day - Example: only 4 AP data
/usr/bin/rrdtool graph $file1 --imgformat PNG --start -1day --end $last --width $width --height $height  \
--title "WiFi clients" \
DEF:ap1=$rrd:ap1:AVERAGE \
DEF:ap2=$rrd:ap2:AVERAGE \
DEF:ap3=$rrd:ap3:AVERAGE \
DEF:ap4=$rrd:ap4:AVERAGE \
LINE1:ap1$ap1_color:'AP1sotano' \
LINE1:ap2$ap2_color:'AP2p0zuzen' \
LINE1:ap3$ap3_color:'AP3p0idazk' \
LINE1:ap4$ap4_color:'AP4p0zerb' COMMENT:"Updated $date \\c"
