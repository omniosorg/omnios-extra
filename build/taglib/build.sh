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

PROG=taglib
VER=2.1.1
PKG=ooce/library/taglib
SUMMARY="$PROG"
DESC="$PROG - a library for reading and editing the meta-data of several "
DESC+="popular audio formats"

set_clangver

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DBUILD_SHARED_LIBS=ON
"
CONFIGURE_OPTS[i386]="-DCMAKE_INSTALL_BINDIR=bin/i386"
CONFIGURE_OPTS[amd64]="-DCMAKE_INSTALL_BINDIR=bin/amd64"
CONFIGURE_OPTS[aarch64]="-DCMAKE_INSTALL_BINDIR=bin"

pre_build() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" -DCMAKE_INSTALL_LIBDIR=${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build -noctf    # C++
strip_install
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
