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
VER=7.0.10-30
PKG=ooce/application/imagemagick
SUMMARY="$PROG - Convert, Edit, or Compose Bitmap Images"
DESC="Use $PROG to create, edit, compose, or convert bitmap images. It can "
DESC+="read and write images in a variety of formats (over 200) including "
DESC+="PNG, JPEG, GIF, HEIC, TIFF, DPX, EXR, WebP, Postscript, PDF, and SVG."

LIBDE265VER=1.0.6
LIBHEIFVER=1.8.0

OPREFIX=$PREFIX
PREFIX+=/$PROG

SKIP_LICENCES=ImageMagick

BUILD_DEPENDS_IPS="
    library/libxml2
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libjpeg-turbo
    ooce/library/libpng
    ooce/library/pango
    ooce/library/tiff
    ooce/library/libwebp
    ooce/application/graphviz
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DLIBDE265=$LIBDE265VER
    -DLIBHEIF=$LIBHEIFVER
"

set_arch 64

init
prep_build

#########################################################################
# Download and build bundled dependencies

save_buildenv
CONFIGURE_OPTS+=" --disable-sherlock265 --disable-encoder --disable-dec265"
build_dependency libde265 libde265-$LIBDE265VER $PROG/heif \
    libde265 $LIBDE265VER
restore_buildenv

export libde265_CFLAGS="-I$DEPROOT$PREFIX/include"
export libde265_LIBS="-L$DEPROOT$PREFIX/lib -R$PREFIX/lib -lde265"
# To find libjpeg
CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64"

CONFIGURE_OPTS+=" --disable-examples --disable-go"
build_dependency libheif libheif-$LIBHEIFVER $PROG/heif \
    libheif $LIBHEIFVER
restore_buildenv

# Remove static archives and libtool helpers from the dependency root.
logcmd $FD -e la -e a . $DEPROOT -X rm

#########################################################################

note -n "Building $PROG"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --enable-hdri
    --with-modules
    --with-heic
    --disable-static
"

CFLAGS+=" -I$DEPROOT$PREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

addpath PKG_CONFIG_PATH64 $DEPROOT$PREFIX/lib/pkgconfig
CPPFLAGS+=" -I$DEPROOT$PREFIX/include"
LDFLAGS64+=" -L$DEPROOT$PREFIX/lib -R$PREFIX/lib"

save_function make_install _make_install
make_install() {
    _make_install "$@"

    # Copy in the dependency libraries

    pushd $DEPROOT$PREFIX/lib >/dev/null
    for lib in libde265* libheif*; do
        [[ $lib = *.so.* && -f $lib && ! -h $lib ]] || continue
        tgt=`echo $lib | cut -d. -f1-3`
        logmsg "--- installing library $lib -> $tgt"
        logcmd cp $lib $DESTDIR/$PREFIX/lib/$tgt || logerr "cp $tgt"
        # Also copy the libraries to the build area so they can be found by
        # the testsuite
        logcmd cp $lib $TMPDIR/$BUILDDIR/MagickCore/.libs/$tgt
    done
    popd >/dev/null
}

download_source $PROG $PROG $VER
patch_source
build
strip_install
run_testsuite check
VER=${VER//-/.}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
