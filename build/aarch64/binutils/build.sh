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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../common.sh

PROG=binutils-gdb
VER=2.41
PKG=ooce/developer/aarch64-gnu-binutils
SUMMARY="GNU binary utilities ($ARCH target)"
DESC="A set of programming tools for creating and managing binary programs, "
DESC+="object files, libraries, etc."

REPO=$GITHUB/richlowe/$PROG
BRANCH=illumos-arm64-${VER/./-}

set_arch 64
# Needed for X/Open curses/termcap
set_standard -xcurses XPG6 CFLAGS

CTF_FLAGS+=" -s"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

HARDLINK_TARGETS="
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/ar
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/as
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/ld
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/nm
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/objcopy
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/objdump
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/ranlib
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/readelf
    ${PREFIX#/}/usr/gnu/$TRIPLET64/bin/strip
"

CONFIGURE_OPTS[amd64]+="
    --exec-prefix=$PREFIX/usr/gnu
    --target=$TRIPLET64
    --with-sysroot
    --with-system-zlib
    --enable-initfini-array
    --disable-gdb
"

init
clone_github_source $PROG $REPO $BRANCH
append_builddir $PROG
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
