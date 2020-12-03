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

# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=bdb
VER=5.3.28
VERHUMAN=$VER
PKG=ooce/database/bdb
SUMMARY="$PROG - Berkeley DB: an embedded database library for key/value data"
DESC="$SUMMARY"

SKIP_LICENCES="Sleepycat"

set_builddir db-$VER/build_unix

forgo_isaexec

OPREFIX=$PREFIX
PREFIX+="/$PROG-$VER"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG-$VER
"

CONFIGURE_CMD="../dist/configure"
CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --enable-compat185
    --disable-static
"
CONFIGURE_OPTS_32="
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --libdir=$OPREFIX/lib/$ISAPART64
"

LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
[ $RELVER -ge 151037 ] && LDFLAGS32+=" -lssp_ns"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

export EXTLIBS=-lm

save_function build64 _build64
build64() {
    export DLDFLAGS=$LDFLAGS64
    _build64
}

init
download_source $PROG db $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
