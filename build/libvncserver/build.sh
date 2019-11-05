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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libvncserver
VER=0.9.12
PKG=ooce/library/libvncserver
SUMMARY="libvncserver"
DESC="A library for easy implementation of a VNC server."

BUILDDIR="$PROG-LibVNCServer-$VER"

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
    ooce/library/libjpeg-turbo
    ooce/library/libpng
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DADDITIONAL_LIBS=socket
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DWITH_WEBSOCKETS=0
"
CONFIGURE_OPTS_32=
CONFIGURE_OPTS_64="
    -DJPEG_LIBRARY_RELEASE:FILEPATH=$PREFIX/lib/$ISAPART64/libjpeg.so
    -DPNG_LIBRARY_RELEASE:FILEPATH=$PREFIX/lib/$ISAPART64/libpng.so
"

LDFLAGS32+=" -L$PREFIX/lib -R$PREFIX/lib"
LDFLAGS64+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"
CFLAGS+=" -D_REENTRANT"

BUILDORDER="64 32"

save_function make_install64 _make_install64
make_install64() {
    _make_install64
    pushd $DESTDIR/$PREFIX >/dev/null
    logcmd mkdir -p lib/$ISAPART64/
    logcmd mv lib/*.so.* lib/pkgconfig lib/$ISAPART64/
    popd >/dev/null
}

build() {
    _BUILDDIR=$BUILDDIR
    for b in $BUILDORDER; do
        mkdir -p $TMPDIR/$BUILDDIR/build.$b
        BUILDDIR+="/build.$b"
        [[ $BUILDARCH =~ ^($b|both)$ ]] && build$b
        BUILDDIR=$_BUILDDIR
    done
}

init
download_source $PROG "LibVNCServer" $VER
patch_source
prep_build cmake
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
