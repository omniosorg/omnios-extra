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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libde265
VER=1.0.18
PKG=ooce/library/libde265
SUMMARY="h.265 codec implementation"
DESC="Open source implementation of the h.265 video codec"

test_relver '>=' 151047 && set_clangver

forgo_isaexec

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DBUILD_SHARED_LIBS=ON
"

CXXFLAGS+=" -DHAVE_ALLOCA_H"

pre_build() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]=" -DCMAKE_INSTALL_LIBDIR=${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
