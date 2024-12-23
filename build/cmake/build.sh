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

PROG=cmake
VER=3.31.3
PKG=ooce/developer/cmake
SUMMARY="Build coordinator"
DESC="An extensible system that manages the build process in a "
DESC+="compiler-independent manner"

set_arch 64
set_clangver

SKIP_LICENCES=Kitware

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

PKGDIFF_HELPER="
    s:/$PROG-[0-9][0-9.]*/:/$PROG-VERSION/:
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_USE_SYSTEM_BZIP2=ON
    -DCMAKE_USE_SYSTEM_CURL=ON
    -DCMAKE_USE_SYSTEM_EXPAT=ON
    -DCMAKE_USE_SYSTEM_LIBLZMA=ON
    -DCMAKE_USE_SYSTEM_LIBUV=ON
    -DCMAKE_USE_SYSTEM_ZLIB=ON
    -DCMAKE_USE_SYSTEM_ZSTD=ON
"
CONFIGURE_OPTS[amd64]=
CONFIGURE_OPTS[aarch64]=

pre_configure() {
    typeset arch=$1

    ! cross_arch $arch && return

    # setting CMAKE_SYSTEM_NAME will set the internal `CMAKE_CROSSCOMPILING`
    # to true; this prevents it from using the cross-compiled cmake for install
    CONFIGURE_OPTS[$arch]+=" -DBUILD_CursesDialog=ON -DCMAKE_SYSTEM_NAME=SunOS"

    LDFLAGS[$arch]+=" -R$PREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
