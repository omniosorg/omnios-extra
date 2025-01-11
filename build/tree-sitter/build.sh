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

PROG=tree-sitter
VER=0.24.6
PKG=ooce/library/tree-sitter
SUMMARY="$PROG"
DESC="$PROG - parser generator tool and an incremental parsing library"

set_clangver

pre_configure() {
    typeset arch=$1

    save_variables CFLAGS LDFLAGS
    subsume_arch $arch CFLAGS LDFLAGS

    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS\"
        LDFLAGS=\"$LDFLAGS\"
    "

    export PREFIX
    export LIBDIR=$PREFIX/${LIBDIRS[$arch]}

    restore_variables CFLAGS LDFLAGS

    # No configure
    false
}

post_build() {
    typeset arch=$1

    [ $arch = i386 ] && return

    # rust needs the native gcc
    # the cross gcc should not be ahead in PATH
    cross_arch $arch && set_gccver $DEFAULT_GCC_VER

    unset -f post_build

    build_rust
    install_rust
}

LDFLAGS[i386]+=" -lssp_ns"

init
download_source $PROG v$VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
