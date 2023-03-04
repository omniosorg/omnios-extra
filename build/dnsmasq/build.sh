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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=dnsmasq
VER=2.89
PKG=ooce/network/dnsmasq
SUMMARY="Lightweight, easy to configure DNS forwarder"
DESC="dnsmasq is a lightweight, easy to configure DNS forwarder, designed to "
DESC+="provide DNS (and optionally DHCP and TFTP) services to a small-scale network."

set_arch 64
[ $RELVER -ge 151045 ] && set_clangver

BASEDIR=$PREFIX/$PROG
CONFFILE=/etc$BASEDIR/$PROG.conf
EXECFILE=$PREFIX/sbin/dnsmasq

copy_sample_config() {
    local relative_conffile=${CONFFILE#/}
    local dest_confdir=$DESTDIR/${relative_conffile%/*}

    logmsg "-- copying sample config"
    logcmd mkdir -p "$dest_confdir" || logerr "mkdir failed"
    logcmd cp $TMPDIR/$BUILDDIR/$PROG.conf.example $DESTDIR/$relative_conffile \
        || logerr "copying configs failed"
}

configure64() {
    MAKE_ARGS_WS="
        CC=$CC
        CFLAGS=\"-DNO_IPSET $CFLAGS $CFLAGS64\"
        LDFLAGS=\"$LDFLAGS $LDFLAGS64\"
        PREFIX=$PREFIX
        MANDIR=$PREFIX/share/man
        sunos_libs=\"-lnsl -lsocket\"
    "

    MAKE_INSTALL_ARGS_WS="
        PREFIX=$PREFIX
        MANDIR=$PREFIX/share/man
    "
}

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DCONFFILE=$CONFFILE
    -DUSER=$PROG
    -DGROUP=$PROG
    -DPROG=$PROG
"

init
download_source "$PROG" "$PROG" "$VER"
patch_source
prep_build
build
copy_sample_config
xform files/$PROG.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
