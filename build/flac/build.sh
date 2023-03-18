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

PROG=flac
VER=1.4.2
PKG=ooce/audio/flac
SUMMARY="flac"
DESC="Free Lossless Audio Codec"

forgo_isaexec
[ $RELVER -ge 151041 ] && set_clangver

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="
    developer/nasm
    ooce/library/libogg
"

TESTSUITE_SED='
    1,/^Test project/d
    s/  *[0-9][0-9.]*  *sec//
'

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_INSTALL_INCLUDEDIR=$OPREFIX/include
    -DBUILD_SHARED_LIBS=ON
"
CONFIGURE_OPTS[i386]="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib/amd64
"

LDFLAGS[i386]+=" -Wl,-R$OPREFIX/lib"
LDFLAGS[amd64]+=" -Wl,-R$OPREFIX/lib/amd64"

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build
# make sure the test suite uses the libraries from the proto area
LD_LIBRARY_PATH=$DESTDIR$OPREFIX/lib/amd64 run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
