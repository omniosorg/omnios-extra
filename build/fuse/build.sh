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

PROG=fuse
VER=1.6
PKG=ooce/driver/fuse
SUMMARY="$PROG"
DESC="fuse kernel module for illumos"

set_gccver $ILLUMOS_GCC_VER

set_arch 64
set_builddir "illumos-${PROG}fs-Version-$VER/kernel"

pre_configure() {
    typeset arch=$1

    CFLAGS+=" `echo ${CFLAGS[kmod_$arch]}`"
    LDFLAGS+=" `echo ${LDFLAGS[kmod_$arch]}`"
    subsume_arch $arch CFLAGS LDFLAGS
    MAKE_ARGS=-e
    MAKE_INSTALL_ARGS=$MAKE_ARGS
    export MACH=$arch

    # No configure
    false
}

pre_make() {
    typeset arch=$1

    MAKE=$USRBIN/dmake
    # build requires ctf tools
    PATH+=":$ONBLDBIN/i386"

    ! cross_arch $arch && return

    export LD=$CROSSTOOLS/$arch/bin/ld
}

init
download_source $PROG Version-$VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
