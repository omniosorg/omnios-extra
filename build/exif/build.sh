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
#
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PKG=ooce/multimedia/exif
VER=0.6.21
PROG=exif
SUMMARY="Exif utility"
DESC="A small command-line utility to show EXIF information hidden in "
DESC+="JPEG files"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

export POPT_CFLAGS="-I$OPREFIX/include"
export POPT_LIBS="-L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64 -lpopt"
export LIBEXIF_CFLAGS="-I$OPREFIX/include"
export LIBEXIF_LIBS="-L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64 -lexif"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
