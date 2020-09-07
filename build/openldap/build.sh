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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=openldap
VER=2.4.52
PKG=ooce/network/openldap
SUMMARY="open-source LDAP implementation"
DESC="Open-source implementation of the Lightweight Directory Access Protocol"

OPREFIX="$PREFIX"
PREFIX+="/$PROG"

SKIP_LICENCES=OpenLDAP
SKIP_RTIME=1

# Setting this variable in the environment makes mkversion use a constant
# string in the LDAP version rather than the hostname and build path.
export SOURCE_DATE_EPOCH=`date +%s`

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DUSER=openldap -DGROUP=openldap
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --with-tls=openssl
    --sysconfdir=/etc$OPREFIX
    --localstatedir=/var$PREFIX
    --disable-static
    --enable-shared
    --enable-dynamic
    --enable-crypt
    --without-cyrus-sasl
"
CONFIGURE_OPTS_32+="
    --bindir=$PREFIX/bin/$ISAPART
    --disable-slapd
"
CONFIGURE_OPTS_64+="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libexecdir=$PREFIX/libexec

    --enable-slapd
    --enable-ldap
    --disable-bdb
    --disable-hdb
    --enable-mdb
    --enable-meta
    --enable-monitor
    --enable-null

    --enable-modules
    --enable-overlays=mod
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -ctf
PKG=ooce/library/openldap make_package client.mog
xform files/$PROG.xml > $TMPDIR/$PROG.xml
install_smf -oocemethod ooce $PROG.xml
RUN_DEPENDS_IPS="pkg:/ooce/library/openldap" make_package server.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
