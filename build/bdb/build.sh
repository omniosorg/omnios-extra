#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition.  All rights reserved.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=bdb
VER=5.3.28
VERHUMAN=$VER
PKG=ooce/database/bdb
SUMMARY="$PROG - Berkeley DB: an embedded database library for key/value data"
DESC="$SUMMARY"
ORIGPREFIX=$PREFIX
PREFIX=$PREFIX/$PROG-$VER

XFORM_ARGS="-D PREFIX=${PREFIX#/} -D ORIGPREFIX=${ORIGPREFIX#/} -D PROGVER=${PROG}-${VER}"

SKIP_LICENCES="Sleepycat"

BUILDDIR=db-$VER/build_unix
CONFIGURE_CMD="../dist/configure"
CONFIGURE_OPTS="
    --enable-compat185
    --disable-static
"
CONFIGURE_OPTS_32="
    --prefix=$PREFIX
    --includedir=$ORIGPREFIX/include
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$ORIGPREFIX/lib
"
CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --includedir=$ORIGPREFIX/include
    --bindir=$PREFIX/bin/$ISAPART64
    --sbindir=$PREFIX/sbin/$ISAPART64
    --libdir=$ORIGPREFIX/lib/$ISAPART64
"
LDFLAGS32+=" -L$ORIGPREFIX/lib -R$ORIGPREFIX/lib"
LDFLAGS64+=" -L$ORIGPREFIX/lib/$ISAPART64 -R$ORIGPREFIX/lib/$ISAPART64"

export EXTLIBS=-lm

save_function build64 build64_orig
build64() {
    export DLDFLAGS=$LDFLAGS64
    build64_orig
}

init
download_source $PROG db $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
