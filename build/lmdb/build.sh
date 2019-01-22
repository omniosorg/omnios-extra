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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=lmdb
# check version in lmdb.h
VER=0.9.23
# lmdb is part of the openldap source package
LDAPVER=2.4.47
PKG=ooce/database/lmdb
SUMMARY="lmdb"
DESC="Lightning Memory-Mapped Database"

SKIP_LICENCES=OpenLDAP

BUILDDIR="openldap-$LDAPVER/libraries/liblmdb"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

MAKE_INSTALL_ARGS="
    prefix=$PREFIX
    includedir=$OPREFIX/include
"

MAKE_INSTALL_ARGS_32="
    bindir=$PREFIX/bin/$ISAPART
    sbindir=$PREFIX/sbin/$ISAPART
    libdir=$OPREFIX/lib
"

MAKE_INSTALL_ARGS_64="
    bindir=$PREFIX/bin
    sbindir=$PREFIX/sbin
    libdir=$OPREFIX/lib/$ISAPART64
"

configure32() { :; }

configure64() { 
    export XCFLAGS="-m64"
    export LDFLAGS="-m64"
}

init
download_source openldap openldap $LDAPVER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
