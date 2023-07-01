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

PROG=serf
VER=1.3.10
SCONS_VER=4.5.2
PKG=ooce/library/serf
SUMMARY="High performance C-based HTTP client library"
DESC="Apache's high performance C-based HTTP client library built upon the "
DESC+="Apache Portable Runtime (APR) library."

CONFIGURE_OPTS="
    PREFIX=$PREFIX
    CPPFLAGS=-DPATH_MAX=1024
"
CONFIGURE_OPTS[i386]="LIBS=-lssp_ns"
CONFIGURE_OPTS[amd64]=

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[${arch}_WS]="
        GCC=$GCC
        APR=$PREFIX/bin/$arch/apr-1-config
        APU=$PREFIX/bin/$arch/apu-1-config
        CFLAGS=\"$CFLAGS ${CFLAGS[$arch]}\"
        LINKFLAGS=\"$LDFLAGS ${LDFLAGS[$arch]}\"
        LIBDIR=\"$PREFIX/${LIBDIRS[$arch]}\"
    "
}

make_arch() { :; }

make_install() {
    logmsg "-- make install"
    $CONFIGURE_CMD install --install-sandbox=$DESTDIR
}

init
BUILDDIR=scons-local-$SCONS_VER download_source scons scons-local-$SCONS_VER
CONFIGURE_CMD="$TMPDIR/scons.py"
download_source $PROG $PROG $VER
patch_source
prep_build autoconf-like
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
