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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=lmdb
VER=0.9.34
PKG=ooce/database/lmdb
SUMMARY="lmdb"
DESC="Lightning Memory-Mapped Database"

forgo_isaexec
set_clangver

SKIP_LICENCES=OpenLDAP

PROGUCVER=${PROG^^}_$VER
BUILDDIR=$PROG-$PROGUCVER/libraries/liblmdb

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

MAKE_ARGS+=" -e"

pre_configure() {
    typeset arch=$1

    [ $arch = i386 ] && SOLIBS="-lssp_ns" || SOLIBS=

    MAKE_ARGS_WS="
        CFLAGS=\"$CFLAGS ${CFLAGS[$arch]}\"
        LDFLAGS=\"$LDFLAGS ${LDFLAGS[$arch]}\"
        SOLIBS=\"$SOLIBS\"
    "

    # no configure
    false
}

pre_install() {
    typeset arch=$1

    MAKE_INSTALL_ARGS="
        prefix=$PREFIX
        includedir=$OPREFIX/include
        libdir=$OPREFIX/${LIBDIRS[$arch]}
    "
}

init
download_source $PROG $PROGUCVER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
