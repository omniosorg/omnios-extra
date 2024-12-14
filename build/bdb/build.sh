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
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=bdb
VER=5.3.28
VERHUMAN=$VER
PKG=ooce/database/bdb
SUMMARY="$PROG - Berkeley DB: an embedded database library for key/value data"
DESC="$SUMMARY"

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

SKIP_LICENCES="Sleepycat"

set_builddir db-$VER/build_unix

OPREFIX=$PREFIX
PREFIX+="/$PROG-$VER"

forgo_isaexec

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG-$VER
"

CONFIGURE_CMD="../dist/configure"
CONFIGURE_OPTS="
    --includedir=$OPREFIX/include
    --enable-compat185
    --disable-static
"

LDFLAGS[i386]+=" -lssp_ns"

export EXTLIBS=-lm

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" --libdir=$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]}"

    export DLDFLAGS=${LDFLAGS[$arch]}
}

init
download_source $PROG db $VER
EXTRACTED_SRC=db-$VER patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
