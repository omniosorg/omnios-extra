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

# Copyright 2016 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=postgresql
PKG=ooce/database/postgresql-12
VER=12.4
SUMMARY="PostgreSQL 12"
DESC="The World's Most Advanced Open Source Relational Database"

SKIP_LICENCES=postgresql
# too many TZ related hardlinks
SKIP_HARDLINK=1

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

build_manifests() {
    manifest_start $TMPDIR/manifest.client
    manifest_add_dir $PREFIX/include libpq
    manifest_add_dir $PREFIX/lib/pkgconfig
    manifest_add_dir $PREFIX/lib/$ISAPART64/pkgconfig
    manifest_add $PREFIX/lib 'libpq\..*' 'libecpg.*' 'libpgtypes.*'
    manifest_add $PREFIX/lib/$ISAPART64 'libpq\..*' 'libecpg.*' 'libpgtypes.*'
    manifest_add $PREFIX/bin pg_config psql ecpg
    manifest_add $PREFIX/share/man/man1 pg_config.1 psql.1 ecpg.1
    manifest_add $PREFIX/share psqlrc.sample
    manifest_finalise $OPREFIX

    manifest_uniq $TMPDIR/manifest.{server,client}
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
#run_testsuite check-world
install_smf database $PROG-$sMAJVER.xml
build_manifests
PKG=${PKG/database/library} SUMMARY+=" client and libraries" \
    make_package -seed $TMPDIR/manifest.client
make_package -seed $TMPDIR/manifest.server server.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
