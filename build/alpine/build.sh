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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=alpine
VER=2.26
PKG=ooce/application/alpine
SUMMARY="Alpine Email Program"
DESC="$PROG - an Alternatively Licensed Program for Internet News and Email"

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

OPREFIX=$PREFIX
PREFIX+=/$PROG

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

set_arch 64
NO_PARALLEL_MAKE=1

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --with-host-stamp=omnios
    --disable-debug
    --with-system-pinerc=/etc$PREFIX/pine.conf
    --with-system-fixed-pinerc=/etc$PREFIX/pine.conf.fixed
    --with-passfile=.pinepw
    --with-ssl-certs-dir=/etc/ssl/certs
    --without-tcl
    --with-ldap-include-dir=$OPREFIX/include
"
CONFIGURE_OPTS[amd64]+="
    --with-ldap-lib-dir=$OPREFIX/lib/amd64
"

export LIBS=-luuid

init
download_source $PROG $PROG $VER
prep_build autoconf -autoreconf
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
