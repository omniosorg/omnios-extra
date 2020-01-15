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

PROG=ImageMagick
VER=7.0.9-16
PKG=ooce/application/imagemagick
SUMMARY="$PROG - Convert, Edit, or Compose Bitmap Images"
DESC="Use $PROG to create, edit, compose, or convert bitmap images. It can "
DESC+="read and write images in a variety of formats (over 200) including "
DESC+="PNG, JPEG, GIF, HEIC, TIFF, DPX, EXR, WebP, Postscript, PDF, and SVG."

[ $RELVER -lt 151032 ] && exit 0

SKIP_LICENCES=ImageMagick

BUILD_DEPENDS_IPS="
    library/libxml2
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libjpeg-turbo
    ooce/library/libpng
    ooce/library/pango
    ooce/library/tiff
    ooce/application/graphviz
"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --enable-hdri
    --with-modules
    --disable-static
"

CFLAGS+=" -I$OPREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
run_testsuite check
VER=${VER//-/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
