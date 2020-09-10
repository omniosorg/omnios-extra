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

PROG=apache
PKG=ooce/server/apache-24
VER=2.4.46
MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
SUMMARY="Apache httpd $MAJVER"
DESC="The Apache HTTP Server Project web server, version $MAJVER"

set_arch 64
set_builddir httpd-$VER

PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
    -DUSER=webservd -DGROUP=webservd
"

CONFIGURE_OPTS_64=
CONFIGURE_OPTS="
    --enable-layout=OOCE
    --prefix=$PREFIX

    --enable-http2
    --enable-ssl
    --with-berkeley-db
    --enable-cgi
    --enable-suexec
    --with-suexec-caller=webservd

    --enable-mpms-shared=all
    --enable-mods-shared=all

    --enable-authn-dbm
    --enable-auth-digest
    --enable-authnz-ldap
    --enable-ldap
    --enable-headers
    --enable-rewrite
"

[ $RELVER -ge 151035 ] && CONFIGURE_OPTS+=" --enable-brotli"

init
download_source $PROG httpd $VER
patch_source
prep_build
build -ctf
xform files/apache-template.xml > $TMPDIR/$PROG-$sMAJVER.xml
install_smf ooce $PROG-$sMAJVER.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
