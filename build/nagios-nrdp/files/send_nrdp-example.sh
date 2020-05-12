#!/bin/sh

NRDP=http://nrdp.nagios-server/
TOKEN=secret
HOST=`/usr/bin/hostname`
SERVICE="Disk Usage"

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

/usr/bin/curl -f -d "token=$TOKEN&cmd=submitcheck&xml=\
<?xml version='1.0'?>\
<checkresults>\
  <checkresult type='service'>\
    <hostname>$HOST</hostname>\
    <servicename>$SERVICE</servicename>\
    <state>$STATE</state>\
    <output>$MESSAGE</output>\
    </checkresult>\
</checkresults>" $NRDP
