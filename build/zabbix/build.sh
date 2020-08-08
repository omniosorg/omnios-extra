#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2020 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=zabbix
VER=5.0.2
PKG=ooce/application/zabbix
SUMMARY="enterprise-class open source distributed monitoring solution"
DESC="Zabbix is software that monitors numerous parameters of a network "
DESC+="and the health and integrity of servers"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

BUILD_DEPENDS_IPS+="
    ooce/database/postgresql-$PGSQLVER
"

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVER=$VER
    -DUSER=zabbix -DGROUP=zabbix -DAGENTUSER=zabbixa
"

pgconfig=$OPREFIX/pgsql-$PGSQLVER/bin/pg_config

CONFIGURE_OPTS="
    --sysconfdir=/etc/$PREFIX
    --datadir=$OPREFIX/share
    --enable-agent
    --enable-server
    --enable-proxy
    --enable-ipv6
    --with-postgresql=$pgconfig
    --with-libevent=$OPREFIX
    --with-libevent-lib=$OPREFIX/lib/$ISAPART64
    --with-net-snmp
    --with-libcurl
    --with-libxml2
    --with-openssl
    --with-libcurl
"

# See https://support.zabbix.com/browse/ZBX-18210
# and https://support.zabbix.com/browse/ZBX-16928
CFLAGS+=" -DDUK_USE_BYTEORDER=1"

LDFLAGS+=" -R$OPREFIX/lib/$ISAPART64 "
LDFLAGS+=" -R`$pgconfig --libdir`"
LIBS+=" -lumem"

save_function make_install _make_install
make_install() {
    _make_install "$@"

    logcmd rsync -a ui/ $DESTDIR/$PREFIX/ui/ \
        || logerr "rsync ui failed"
    logcmd rsync -a database/postgresql/*.sql $DESTDIR/$PREFIX/sql/ \
        || logerr "rsync database failed"

    logcmd rsync -a $SRCDIR/files/agentconf/ \
        $DESTDIR/etc/$PREFIX/zabbix_agentd.conf.d/ \
        || logerr "rsync agentconf failed"
    logcmd rsync -a $SRCDIR/files/scripts/ $DESTDIR/$PREFIX/scripts/ \
        || logerr "rsync scripts failed"
}

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf -fi
prep_build
build -ctf

for f in agent server; do
    xform files/$PROG-$f.xml > $TMPDIR/$PROG-$f.xml
    install_smf application $PROG-$f.xml
    [ "$f" = server ] && add_notes README.server-install
    PKG=$PKG-$f make_package $f.mog
done

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
