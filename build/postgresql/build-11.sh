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
# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=postgresql
PKG=ooce/database/postgresql-11
VER=11.5
SUMMARY="PostgreSQL 11"
DESC="The World's Most Advanced Open Source Relational Database"

SKIP_LICENCES=postgresql

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/pgsql-$MAJVER
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$PREFIX
VARPATH=/var$PREFIX
RUNPATH=$VARPATH/run

set_arch 64

RUN_DEPENDS_IPS="ooce/database/postgresql-common"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

CFLAGS+=" -O3"

CONFIGURE_OPTS="
    --enable-thread-safety
    --with-openssl
    --with-libxml
    --with-xslt
    --with-readline
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
    --enable-dtrace DTRACEFLAGS=\"-64\"
"

# need to build world to get e.g. man pages in
MAKE_TARGET=world
MAKE_INSTALL_TARGET=install-world

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
#run_testsuite check-world
install_smf database $PROG-$sMAJVER.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
