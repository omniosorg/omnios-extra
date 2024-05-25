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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libvncserver
VER=0.9.14
PKG=ooce/library/libvncserver
SUMMARY="libvncserver"
DESC="A library for easy implementation of a VNC server."

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

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
CONFIGURE_OPTS[i386]=
CONFIGURE_OPTS[amd64]="-DCMAKE_LIBRARY_PATH=$PREFIX/lib/amd64"

LDFLAGS[i386]+=" -L$PREFIX/lib -R$PREFIX/lib"
LDFLAGS[amd64]+=" -L$PREFIX/lib/amd64 -R$PREFIX/lib/amd64"
CFLAGS+=" -D_REENTRANT"

[ "$BUILDARCH" = "i386 amd64" ] && BUILDARCH="amd64 i386"

post_install() {
    [ $1 = amd64 ] || return

    pushd $DESTDIR/$PREFIX >/dev/null
    logcmd mkdir -p lib/amd64/
    logcmd mv lib/*.so.* lib/pkgconfig lib/amd64/
    popd >/dev/null
}

init
download_source $PROG "LibVNCServer" $VER
patch_source
prep_build cmake+ninja
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
