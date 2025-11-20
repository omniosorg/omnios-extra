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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libwebp
VER=1.6.0
PKG=ooce/library/libwebp
SUMMARY="libwebp"
DESC="WebP - A modern image format that provides lossless and lossy compression"
DESC+=" for images on the web"

test_relver '>=' 151047 && set_clangver
forgo_isaexec

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS+="
    ooce/library/libgif
    ooce/library/libjpeg-turbo
    ooce/library/libpng
    ooce/library/tiff
"

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
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --enable-everything
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[${arch}_WS]="
        --libdir=$OPREFIX/${LIBDIRS[$arch]}
        LDFLAGS=\"-L${SYSROOT[$arch]}$OPREFIX/${LIBDIRS[$arch]} -Wl,-R$OPREFIX/${LIBDIRS[$arch]}\"
    "

    CPPFLAGS+=" -I${SYSROOT[$arch]}$OPREFIX/include"
}

init
download_source $PROG $PROG $VER
prep_build
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
