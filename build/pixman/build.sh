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

PROG=pixman
VER=0.43.0
PKG=ooce/library/pixman
SUMMARY="$PROG"
DESC="Low-level software library for pixel manipulation, providing features "
DESC+="such as image compositing and trapezoid rasterization"

TESTSUITE_SED='
    /Running all tests/d
    s/  *[0-9][0-9.]*s//
    /^Full log written to/d
'

CFLAGS[aarch64]+=" -mtls-dialect=trad"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
        --prefix=$PREFIX
        --libdir=$PREFIX/${LIBDIRS[$arch]}
    "

    ! cross_arch $arch && return

    CONFIGURE_CMD+=" --cross-file $SRCDIR/files/aarch64-gcc.txt"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build meson
build
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
