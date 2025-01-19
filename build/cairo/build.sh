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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=cairo
VER=1.18.2
PKG=ooce/library/cairo
SUMMARY="cairo"
DESC="Cairo is a 2D graphics library with support for multiple output devices"

BUILD_DEPENDS_IPS="
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libpng
    ooce/library/pixman
"

# ctime_r, mkdtemp, ...
set_standard POSIX+EXTENSIONS

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPIXMAN=$PIXMANVER
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
"
CONFIGURE_OPTS[i386]="
    --bindir=$PREFIX/bin/i386
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --bindir=$PREFIX/bin
    --libdir=$OPREFIX/lib/amd64
"
CONFIGURE_OPTS[aarch64]="
    --bindir=$PREFIX/bin
    --libdir=$OPREFIX/lib
"

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]} -lxnet"

    ! cross_arch $arch && return

    CONFIGURE_CMD+=" --cross-file $BLIBDIR/meson-$arch-gcc"
}

post_install() {
    typeset arch=$1

    pushd $DESTDIR/$OPREFIX >/dev/null

    # Unfortunately, meson messes up the runtime library path
    # Fixing this up post-install for now,
    # there may be a better way to do it.
    typeset rpath="$OPREFIX/${LIBDIRS[$arch]}"
    rpath+=":/usr/gcc/$GCCVER/${LIBDIRS[$arch]}"

    for f in ${LIBDIRS[$arch]}/lib$PROG*.so.*; do
        [ -f $f -a ! -h $f ] || continue
        logmsg "--- fixing runpath in $f"
        logcmd $ELFEDIT -e "dyn:value -s RUNPATH $rpath" $f
        logcmd $ELFEDIT -e "dyn:value -s RPATH $rpath" $f
    done

    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build meson
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
