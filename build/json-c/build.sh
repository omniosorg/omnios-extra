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

PROG=json-c
VER=0.15
PKG=ooce/library/json-c
SUMMARY=$PROG
DESC="$PROG - A JSON implementation in C"

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DBUILD_STATIC_LIBS=OFF
"
CONFIGURE_OPTS_32=
CONFIGURE_OPTS_64="
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib/$ISAPART64
"

init
download_source $PROG $PROG $VER
prep_build cmake
patch_source
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
