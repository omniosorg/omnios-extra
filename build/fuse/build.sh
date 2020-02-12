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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=fuse
VER=1.4
PKG=ooce/driver/fuse
SUMMARY="$PROG"
DESC="fuse kernel module for illumos"

set_gccver $ILLUMOS_GCC_VER

set_arch 64
set_builddir "illumos-${PROG}fs-Version-$VER/kernel"

MAKE=/usr/bin/dmake
# build requires ctf tools
PATH+=":/opt/onbld/bin/i386"

# override CFLAGS for kernel module; flags taken from:
# https://github.com/omniosorg/illumos-kvm/blob/master/Makefile#L105
# omitting gcc version specific flags; removing -Werror for now.
MAKE_ARGS=-e
CFLAGS+=" -fident -fno-builtin -fno-asm -nodefaultlibs -Wall"
CFLAGS+=" -Wno-unknown-pragmas -Wno-unused -fno-inline-functions -m64"
CFLAGS+=" -mcmodel=kernel -fno-shrink-wrap -mindirect-branch=thunk-extern"
CFLAGS+=" -mindirect-branch-register -g -O2 -fno-inline -ffreestanding"
CFLAGS+=" -fno-strict-aliasing -Wpointer-arith -gdwarf-2 -std=gnu99"
CFLAGS+=" -mno-red-zone"
export CFLAGS

# No configure
configure64() { :; }

init
download_source $PROG Version-$VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
