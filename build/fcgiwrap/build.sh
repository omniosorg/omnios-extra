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

# Copyright 2020 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=fcgiwrap
VER=1.1.0
PKG=ooce/application/$PROG
SUMMARY="Simple FastCGI wrapper for CGI scripts"
DESC="fcgiwrap is a simple server for running CGI applications \
over FastCGI. It hopes to provide clean CGI support to Nginx \
(and other web servers that may need it)."

set_arch 64

SKIP_LICENCES=NOSEK

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVER=$VER
"

BUILD_DEPENDS_IPS="
    ooce/library/fcgi2
"
RUN_DEPENDS_IPS="
    ooce/library/fcgi2
"

CONFIGURE_OPTS_64=" 
    --prefix=$PREFIX
    --without-systemd
"

CFLAGS+=" -I$PREFIX/include"
LDFLAGS+=" -L$PREFIX/lib -R$PREFIX/lib -lsocket"

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf -i
prep_build
build
strip_install
install_smf application $PROG.xml application-$PROG
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
