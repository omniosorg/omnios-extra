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
VER=7.0.10-35
PKG=ooce/application/imagemagick
SUMMARY="$PROG - Convert, Edit, or Compose Bitmap Images"
DESC="Use $PROG to create, edit, compose, or convert bitmap images. It can "
DESC+="read and write images in a variety of formats (over 200) including "
DESC+="PNG, JPEG, GIF, HEIC, TIFF, DPX, EXR, WebP, Postscript, PDF, and SVG."

LIBDE265VER=1.0.8
LIBHEIFVER=1.9.1

OPREFIX=$PREFIX
PREFIX+=/$PROG

reset_configure_opts

SKIP_LICENCES=ImageMagick
SKIP_RTIME=1

BUILD_DEPENDS_IPS="
    library/libxml2
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libjpeg-turbo
    ooce/library/libpng
    ooce/library/pango
    ooce/library/tiff
    ooce/library/libwebp
    ooce/library/libzip
    ooce/application/graphviz
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DLIBDE265=$LIBDE265VER
    -DLIBHEIF=$LIBHEIFVER
"

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

save_function configure64 _configure64
configure64() {
    libde265_LIBS="-L$DEPROOT$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64 "
    libde265_LIBS+="-lde265"
    _configure64 "$@"
}
# To find libjpeg
CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS32+=" -L$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64"

CONFIGURE_OPTS+=" --disable-examples --disable-go"
build_dependency libheif libheif-$LIBHEIFVER $PROG/heif \
    libheif $LIBHEIFVER
restore_buildenv
save_function _configure64 configure64

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
LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

addpath PKG_CONFIG_PATH64 $DEPROOT$PREFIX/lib/pkgconfig
CPPFLAGS+=" -I$DEPROOT$PREFIX/include"
LDFLAGS32+=" -L$DEPROOT$PREFIX/lib -R$PREFIX/lib"
LDFLAGS64+=" -L$DEPROOT$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

CONFIGURE_OPTS_64+=" --bindir=$PREFIX/bin"

install_deps() {
    # Copy in the dependency libraries
    pushd $DEPROOT$PREFIX/lib >/dev/null
    for lib in libde265* libheif*; do
        [[ $lib = *.so.* && -f $lib && ! -h $lib ]] || continue
        tgt=`echo $lib | cut -d. -f1-3`
        logmsg "--- installing library $lib -> $tgt"
        logcmd cp $lib $DESTDIR/$PREFIX/lib/$tgt || logerr "cp $tgt"
        logcmd cp $ISAPART64/$lib $DESTDIR/$PREFIX/lib/$ISAPART64/$tgt \
            || logerr "cp $ISAPART64/$tgt"
        # Also copy the final 64-bit libraries to the build area so they can be
        # found by the testsuite
        logcmd cp $ISAPART64/$lib $TMPDIR/$BUILDDIR/MagickCore/.libs/$tgt \
            || logerr "cp $tgt for testsuite"
    done
    popd >/dev/null
}

make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p $ISAPART64
    logcmd mv *-config $ISAPART64/ || logerr "mv -config"
    make_isaexec_stub_arch $ISAPART64 $PREFIX/bin
    popd >/dev/null
}

download_source $PROG $PROG $VER
patch_source
build
install_deps
strip_install
run_testsuite check
make_isa_stub
VER=${VER//-/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
