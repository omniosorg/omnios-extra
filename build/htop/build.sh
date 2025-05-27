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

PROG=htop
PKG=ooce/system/htop
VER=3.4.1
SUMMARY="htop"
DESC="An interactive process viewer for Unix"

set_arch 64
set_clangver

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

# TODO: if we are going to use clang as a cross-compiler we should
# add support to the framework; this is just a hacky workaround
# to have at least one consumer of clang for cross-compiling
pre_configure() {
    typeset arch=$1

    ! cross_arch $arch && return

    set_clangver

    PATH=$CROSSTOOLS/$arch/bin:$PATH
    CC+=" --target=${TRIPLETS[$arch]}"
    CFLAGS[$arch]+=" $CTF_CFLAGS"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf -autoreconf
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
