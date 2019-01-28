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
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=znc
VER=1.7.2
VERHUMAN=$VER
PKG=ooce/network/znc
SUMMARY="$PROG - an advanced IRC bouncer"
DESC="$SUMMARY"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

set_arch 64

CXXFLAGS=-g
# Enable verbose make
MAKE_JOBS+=" V=1"

install_modules() {
    for f in $SRCDIR/files/*.cpp; do
        bf=`basename $f`
        logmsg "Installing module: $bf"
        logcmd cp $f $TMPDIR/$BUILDDIR/modules/
    done
}

install_files() {
    logcmd mkdir -p $DESTDIR/var/$PREFIX/configs || logerr "mkdir failed"
    logcmd cp $SRCDIR/files/znc.conf $DESTDIR/var/$PREFIX/configs/ \
        || logerr "-- failed to copy configuration file"
}

init
download_source $PROG $PROG $VER
patch_source
install_modules
prep_build
build
install_files
install_smf network znc.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
