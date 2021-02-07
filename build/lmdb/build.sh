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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=lmdb
VER=0.9.28
PKG=ooce/database/lmdb
SUMMARY="lmdb"
DESC="Lightning Memory-Mapped Database"

forgo_isaexec

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

MAKE_INSTALL_ARGS="
    prefix=$PREFIX
    includedir=$OPREFIX/include
"

MAKE_INSTALL_ARGS_32="
    libdir=$OPREFIX/lib
"

MAKE_INSTALL_ARGS_64="
    libdir=$OPREFIX/lib/$ISAPART64
"

configure32() {
    export XCFLAGS="$CFLAGS $CFLAGS32"
    export LDFLAGS="$LDFLAGS $LDFLAGS32"
    [ $RELVER -ge 151037 ] && export SOLIBS="-lssp_ns"
}

configure64() { 
    export XCFLAGS="$CFLAGS $CFLAGS64"
    export LDFLAGS="$LDFLAGS $LDFLAGS64"
    export SOLIBS=
}

init
download_source $PROG $PROGUCVER
patch_source
prep_build
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
