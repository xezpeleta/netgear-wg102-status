netgear-wg102-status
====================

Shell scripts for getting info from Netgear WG102 access point using SNMP protocol.

Features:

* Get AP sysname
* Get connected client number
* Get uptime
* Get Firmware version
* Get avalable free memory


### Preparation

Before executing the script, get MIB file and save it in the "/usr/share/snmp/mibs/" folder

RRDTool Graph creation steps:
- Execute: `cd ./rrd && rrdtool create wifi_clients.rrd -s 50 DS:ap1:GAUGE:300:0:60 DS:ap2:GAUGE:300:0:60 DS:ap3:GAUGE:300:0:60 DS:ap4:GAUGE:300:0:60 RRA:AVERAGE:0.5:1:600`
- Every 5 minutes in CRON: `./update_rrd.sh`
- Update png file: `./create_graph.sh`

### Screenshots

<img src="http://gdurl.com/JGSE">

<img src="http://gdurl.com/piVH">
