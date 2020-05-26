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
#
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=gnupg
VER=1.4.23
VERHUMAN=$VER
PKG=ooce/security/gnupg
SUMMARY="$PROG - GNU Privacy Guard"
DESC="$SUMMARY"

# This component does not yet build with gcc 10
[ $GCCVER = 10 ] && set_gccver 9

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

reset_configure_opts

# Build 64-bit only and skip the arch-specific directories
BUILDARCH=64
# GCC can't handle the assembly files that come with the source.
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
    --libdir=$PREFIX/lib
    --disable-asm
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
