#! /bin/sh

RETRY=2

getSysname () {
    AP=$1
    sysname=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovq -v2c $AP WG102::sysAPName 2> /dev/null`
    if [ -z "$sysname" ];then
        if [ "$RETRY" -gt 1 ];then
            for i in {1..$RETRY}
            do
                sysname=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovq -v2c $AP WG102::sysAPName 2> /dev/null`
            done
        fi
        if [ -z "$sysname" ];then
            sysname="<null>"
        fi
    fi
    echo $sysname
}

getUptime () {
    AP=$1
    #uptime=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovqt -v2c $AP iso.3.6.1.2.1.1.3.0 2> /dev/null`
    uptime=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovqt -v2c $AP WG102::sysRuntime 2> /dev/null`
    if [ -z "$uptime" -o "$uptime" = "" ];then
        uptime="<null>"
        echo $uptime
        exit 1
    fi

    if [ ! "$uptime" -ge "0" ];then
        uptime="<null>"
        echo $uptime
        exit 2
    fi
    #echo $uptime
    echo $(expr "$uptime" / 8640000)
}

getClientCount () {
    AP=$1
    clients=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovq -v2c $AP WG102::wlanStationCount.0 2> /dev/null`
    if [ -z "$clients" ];then
        clients="<null>"
        echo $clients
        exit 1
    fi

    if [ "$clients" = "" -o ! "$clients" -ge "0" ];then
        clients="<null>"
        echo $clients
        exit 2
    fi
    echo $clients
}

getFirmware () {
    AP=$1
    #firmware=`/usr/bin/snmpget -c $COMMUNITY -Ovq -v2c $i WG102::sysVersion | sed 's/\<Version\>//g'`
    firmware=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovq -v2c $AP iso.3.6.1.2.1.1.1.0 | cut -f7-8 -d" " | cut -f1 -d '"'`
    if [ -z "$firmware" ];then
        firmware="<null>"
    fi
    echo $firmware
}

getFreeMemory () {
    AP=$1
    memory=`/usr/bin/snmpget -r 3 -c $COMMUNITY -Ovq -v2c $AP WG102::sysFreeMemory`
    if [ -z "$memory" ];then
        memory="<null>"
        echo $memory
        exit 1
    fi

    if [ ! "$memory" -ge "0" ];then
        memory="<null>"
        echo $memory
        exit 2
    fi
    #echo $memory
    echo $(expr "$memory" / 1024)
}

getChannel () {
    AP=$1
    channel=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessMode.dot11bg 2> /dev/null`
    if [ ! "$channel" -ge "0" ];then
        channel="<null>"
    fi
    echo $channel
}

getClientsMac () {
    AP=$1
    clients=`/usr/bin/snmpwalk -c $COMMUNITY -r 3 -Ovq -v2c $AP  WG102::clientMacAddress 2> /dev/null`
    if [ -z "$clients" ];then
        clients="<null>"
    fi
    echo $clients
}


getClientIndex () {
    AP=$1
    CLIENT=$2
    clients=`/usr/bin/snmpwalk -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wlanClientsEntry.2 2> /dev/null`
    index=1
    for i in $clients
    do
        if [ "$i" = "$CLIENT" ];then
            echo $index
            exit 0
        fi
        index=$(( $index+1 ))
    done
}

getClientIP () {
    AP=$1
    INDEX=$2
    #ip=`/usr/bin/snmpwalk -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wlanClientsEntry.3 2> /dev/null`
    ip=`/usr/bin/snmpwalk -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::clientIP.1.$INDEX 2> /dev/null`
    if [ -z "$ip" ];then
        ip="<null>"
    fi
    echo $ip

}

getAllClients () {
    for i in $HOSTS
    do
        count=$(getClientCount $i)
        if [ "$count" = "<null>" -o ! $count -eq 0 ];then
            clients=$(getClientsMac $i)

            for j in $clients
            do
                ap=$i
                client=$j
                index=$(getClientIndex $ap $client)
                #status=$(getclientStatus $ap $index)
                if [ ! -z "$index" ];then
                    time=$(getClientTime $ap $index)
                    printf "$client,$ap,$index,$time\n"
                else
                    printf "$client,$ap\n"
                fi
            done
        #else
        #    echo "Error: $i ($count clients)"
        fi
    done
}

XwhereIsClient () {
    MAC="$1"
    clients=$(getAllClients)
    for i in $clients
    do
        echo $i | grep -i $MAC
    done
}

whereIsClient () {
    CLIENT=$1
    for i in $HOSTS
    do
        count=$(getClientCount $i)
        if [ "$count" = "<null>" ];then
            exit 1
        fi

        if [ ! $count -eq 0 ];then
            clients=$(getClientsMac $i)

            if [ ! -z "$(echo "$clients"|grep -i $CLIENT)" ];then
                echo $i
            fi
        fi
    done
}

getClientTime () {
    AP=$1
    INDEX=$2

    date=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.2.$INDEX`
    time=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.3.$INDEX`
    request=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.4.$INDEX`
    response=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.5.$INDEX`
    grant=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.6.$INDEX`
    disconnect=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.7.$INDEX`
    disconnectall=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.8.$INDEX`
    flag=`/usr/bin/snmpget -c $COMMUNITY -r 3 -Ovq -v2c $AP WG102::wirelessLinkStatEntry.9.$INDEX`

    echo "$date-$time-$request-$response-$grant-$disconnect-$disconnectall-$flag"
    #echo $date
}


getClientInfo () {
    CLIENT=$1
    where=$(whereIsClient $CLIENT)
    countwhere=$(echo "$where"|wc -l)
    if [ "$countwhere" -gt "0" ];then
        for i in $where
        do
            ap=$i
            index=$(getClientIndex $ap $CLIENT)
            if [ ! -z "$index" ];then
                time=$(getClientTime $ap $index)
                ip=$(getClientIP $ap $index)
                printf "$ap,$index,$time,$ip\n"
            else
                printf "$ap,$ip\n"
            fi
        done
    fi
}
