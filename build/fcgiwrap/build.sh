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
PKG=ooce/application/fcgiwrap
SUMMARY="Simple FastCGI wrapper for CGI scripts"
DESC="fcgiwrap is a simple server for running CGI applications \
over FastCGI. It hopes to provide clean CGI support to Nginx \
(and other web servers that may need it)."

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVER=$VER
"

BUILD_DEPENDS_IPS+="
    ooce/library/fcgi2
"

# The packaged Makefile.in will install the final binary into
# $(prefix)$(sbindir) so override the fully-qualified --sbindir that comes
# in from the framework. configure does check if the argument is fully
# qualified hence the leading /
CONFIGURE_OPTS="
    --without-systemd
    --sbindir=/sbin
"

# configure does not properly use pkg-config for these.
CFLAGS+=" -I$PREFIX/include"
LDFLAGS64+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64 -lsocket"

extract_licence() {
    logmsg "-- extracting licence"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    sed '/^$/q' < $PROG.c > LICENCE
    popd > /dev/null
}

init
download_source $PROG $VER
extract_licence
patch_source
run_autoreconf -i
prep_build
build
strip_install
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
