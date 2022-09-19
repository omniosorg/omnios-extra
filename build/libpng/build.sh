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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libpng
VER=1.6.38
PKG=ooce/library/libpng
SUMMARY="libpng"
DESC="libpng is the official PNG reference library"

SKIP_LICENCES=libpng

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --disable-static
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib/$ISAPART64
"

# Make ISA binaries for libpng-config, to allow software to find the
# right settings for 32/64-bit when pkg-config is not used.
make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p $ISAPART64
    logcmd mv libpng*-config $ISAPART64/ || logerr "mv libpng-config"
    make_isaexec_stub_arch $ISAPART64 $PREFIX/bin
    popd >/dev/null
}

init
download_source $PROG $PROG $VER
prep_build
patch_source
build
run_testsuite
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
