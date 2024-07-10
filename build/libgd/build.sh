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

PROG=libgd
VER=2.3.3
PKG=ooce/library/libgd
SUMMARY="libgd"
DESC="GD is an open source code library for the dynamic creation of images by "
DESC+="programmers"

SKIP_LICENCES=libgd

OPREFIX=$PREFIX
PREFIX+="/$PROG"

forgo_isaexec
test_relver '>=' 151051 && set_clangver
set_standard XPG6

BUILD_DEPENDS_IPS="
    library/fontconfig
    library/freetype2
    library/libheif
    library/libjpeg-turbo
    library/libpng
    library/tiff
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS+="
    --disable-static
    --includedir=$OPREFIX/include
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" --libdir=$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
