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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libheif
VER=1.11.0
PKG=ooce/library/libheif
SUMMARY="HEIF and AVIF encoder"
DESC="ISO/IEC 23008-12:2017 HEIF and AVIF (AV1 Image File Format) "
DESC+="file format decoder and encoder"

BUILD_DEPENDS_IPS="
    ooce/library/libde265
    ooce/multimedia/x265
"
[ $RELVER -ge 151036 ] && BUILD_DEPENDS_IPS+=" ooce/multimedia/dav1d"

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="
    --disable-static
    --disable-examples
    --disable-go
"

LDFLAGS32+=" -R$PREFIX/lib"
LDFLAGS64+=" -R$PREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf -autoreconf
build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
