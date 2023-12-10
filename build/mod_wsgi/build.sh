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

# Copyright 2023 Carsten Grzemba

. ../../lib/build.sh

PROG=mod_wsgi
VER=5.0.0
# Hard-coded here for now. If we ship more than one apache version, this will
# need restructuring.
PKG=ooce/server/apache-24/modules/wsgi
SUMMARY="$PROG CGI daemon"
DESC="$PROG is a high performance alternative to mod_cgi or mod_cgid, "
DESC+="for configuration consult: https://modwsgi.readthedocs.io"

APACHEVER=2.4
sAPACHEVER=${APACHEVER//./}

RUN_DEPENDS_IPS+=" ooce/server/apache-$sAPACHEVER"

set_arch 64

OPREFIX=$PREFIX
PREFIX+="/apache-$APACHEVER"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

export PATH+=":$PREFIX/bin"

CONFIGURE_OPTS="
    --enable-layout=OOCE
    --prefix=$PREFIX
"

init
download_source apache $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
