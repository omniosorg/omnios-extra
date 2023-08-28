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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=json-c
VER=0.17
PKG=ooce/library/json-c
SUMMARY=$PROG
DESC="$PROG - A JSON implementation in C"

test_relver '>=' 151047 && set_clangver

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
"

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DBUILD_STATIC_LIBS=OFF
"
CONFIGURE_OPTS[i386]=
CONFIGURE_OPTS[amd64]="
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib/amd64
"
CONFIGURE_OPTS[aarch64]=

CFLAGS[aarch64]+=" -mno-outline-atomics -mtls-dialect=trad"

init
download_source $PROG $PROG $VER
prep_build cmake+ninja
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
