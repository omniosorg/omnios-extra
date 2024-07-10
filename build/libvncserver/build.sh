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

test_relver '>=' 151051 && set_clangver

set_builddir $PROG-LibVNCServer-$VER

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
    -DWITH_EXAMPLES=OFF
"
CONFIGURE_OPTS[i386]=
CONFIGURE_OPTS[amd64]="-DCMAKE_INSTALL_LIBDIR=lib/amd64"

LDFLAGS[i386]+=" -L$PREFIX/lib -Wl,-R$PREFIX/lib"
LDFLAGS[amd64]+=" -L$PREFIX/lib/amd64 -Wl,-R$PREFIX/lib/amd64"
CFLAGS+=" -D_REENTRANT"

init
download_source $PROG LibVNCServer $VER
patch_source
prep_build cmake+ninja
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
