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

PROG=nagios-nsca
VER=2.10.0
PKG=ooce/application/nagios-nsca
SUMMARY="Nagios Service Check Acceptor"
DESC="The Nagios Service Check Acceptor (NSCA) is used to send service check \
results to a central Nagios server. This consists of the NSCA daemon \
which runs on the main Nagios server and accepts results and the \
send_nsca client which is used to send results to the server."

set_arch 64

BUILDDIR=nsca-$VER

BUILD_DEPENDS_IPS="
    ooce/library/libmcrypt
"

RUN_DEPENDS_IPS="
    ooce/application/nagios-common
"

MAKE_ARGS="all"

OPREFIX="$PREFIX"
PREFIX+="/nagios"

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CFLAGS+=" -I$OPREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
LDFLAGS64+=" -lmcrypt"

make_install64() {
    logmsg "--- make install"
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd mkdir -p $DESTDIR/$PREFIX/sbin
    logcmd cp src/nsca $DESTDIR/$PREFIX/sbin/nsca || logerr "cp failed"
    logcmd mkdir -p $DESTDIR/$PREFIX/bin
    logcmd cp src/send_nsca $DESTDIR/$PREFIX/bin/send_nsca \
        || logerr "cp failed"
    logcmd mkdir -p $DESTDIR/etc/$PREFIX
    logcmd cp sample-config/nsca.cfg $DESTDIR/etc/$PREFIX/nsca.cfg \
        || logerr "cp failed"
    logcmd cp sample-config/send_nsca.cfg $DESTDIR/etc/$PREFIX/send_nsca.cfg \
        || logerr "cp failed"

    popd >/dev/null
}

init
download_source nagios nsca $VER
patch_source
prep_build
build
strip_install
install_smf application nsca.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
