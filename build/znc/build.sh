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
#
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=znc
VER=1.8.2
VERHUMAN=$VER
PKG=ooce/network/znc
SUMMARY="$PROG - an advanced IRC bouncer"
DESC="An advanced IRC bouncer that is left connected so an IRC client "
DESC+="can disconnect/reconnect without losing the chat session"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

# The icu4c ABI changes frequently. Lock the version
# pulled into each build of znc.
ICUVER=`pkg_ver icu4c`
ICUVER=${ICUVER%%.*}
BUILD_DEPENDS_IPS="=ooce/library/icu4c@$ICUVER"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"

set_arch 64
[ $RELVER -ge 151041 ] && set_clangver

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

SKIP_RTIME_CHECK=1
NO_SONAME_EXPECTED=1

install_modules() {
    for f in $SRCDIR/files/*.cpp; do
        bf=`basename $f`
        logmsg "Installing module: $bf"
        logcmd cp $f $TMPDIR/$BUILDDIR/modules/
    done
}

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_SKIP_RPATH=ON
"

CONFIGURE_OPTS_64="
    -DCMAKE_INSTALL_LIBDIR=lib
"
LDFLAGS+=" -lsocket"
LDFLAGS64+=" -Wl,-R$OPREFIX/lib/$ISAPART64"

tests() {
    for key in SSL IPv6 Zlib; do
        $EGREP " $key *: yes" $LOGFILE || logerr "$key was not included"
    done
}

init
download_source $PROG $PROG $VER
patch_source
install_modules
prep_build cmake+ninja
build -noctf    # C++
tests
strip_install
install_smf network znc.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
