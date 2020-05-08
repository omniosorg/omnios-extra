#!/bin/sh

SERVICE="Disk Usage"

NAGIOS="nagios.nagios-server"
HOST=`/usr/bin/hostname`

MESSAGE=`/opt/ooce/nagios/libexec/check_disk -w 20% -c 10% -p /`
STATUS=`echo $MESSAGE | awk '{ print $2 }'`

if [ $STATUS = "OK"  ]
  then
    STATE=0
  elif [ $STATUS = "WARNING"  ]
  then
    STATE=1
  else
    STATE=2
fi

/bin/echo "$HOST	$SERVICE	$STATE	Disk Usage - $MESSAGE" \
    | /opt/ooce/nagios/bin/send_nsca -H $NAGIOS \
    -c /etc/opt/ooce/nagios/send_nsca.cfg
