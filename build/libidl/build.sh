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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libIDL
VER=0.8.14
PKG=ooce/library/libidl
SUMMARY="libIDL"
DESC="library for creating trees of CORBA Interface Definition Language (IDL)"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --disable-static
"
CONFIGURE_OPTS_32="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --bindir=$PREFIX/bin/$ISAPART64
    --sbindir=$PREFIX/sbin/$ISAPART64
    --libdir=$OPREFIX/lib/$ISAPART64
"

init
download_source $PROG $PROG $VER
prep_build
patch_source
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
