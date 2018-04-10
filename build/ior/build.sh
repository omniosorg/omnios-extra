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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=ior
VER=3.1.0
VERHUMAN=$VER
PKG=ooce/system/test/ior
SUMMARY="$PROG - Parallel filesystem I/O benchmark"
DESC="$SUMMARY"

BUILD_DEPENDS_IPS="ooce/library/openmpi"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

reset_configure_opts

save_function configure64 configure64_orig
configure64(){
    logcmd $TMPDIR/$BUILDDIR/bootstrap || logerr "--- bootstrap failed"
    configure64_orig
}

# Build 64-bit only and skip the arch-specific directories
BUILDARCH=64
CFLAGS="-I$OPREFIX/include"
LDFLAGS="-L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
    --libdir=$PREFIX/lib
    --without-mpiio
"

init
download_source $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
