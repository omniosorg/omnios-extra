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

PROG=fstrm
VER=0.6.1
PKG=ooce/library/fstrm
SUMMARY="$PROG"
DESC="A C implementation of the Frame Streams data transport protocol."
LIBEVENT_VER=2.1.12
LIBEVENT_DIR=libevent-${LIBEVENT_VER}-stable

set_clangver

forgo_isaexec

init
prep_build

#########################################################################
# Download and build a static version of libevent

save_buildenv

CONFIGURE_OPTS="
    --disable-shared
    ac_cv_lib_xnet_socket=no
"

build_dependency libevent $LIBEVENT_DIR \
    libevent libevent ${LIBEVENT_VER}-stable

restore_buildenv

#########################################################################

CONFIGURE_OPTS="--disable-static"

pre_build() {
    typeset arch=$1

    export libevent_CFLAGS="-I$DEPROOT$PREFIX/include"
    export libevent_LIBS="-L$DEPROOT$PREFIX/${LIBDIRS[$arch]} -levent"

    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

note -n "-- Building $PROG"

download_source $PROG $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
