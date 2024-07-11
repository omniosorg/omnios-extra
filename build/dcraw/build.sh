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

PROG=dcraw
PKG=ooce/multimedia/dcraw
VER=9.28.0
SUMMARY="Raw digital photograph decoder"
DESC="dcraw - Decoding raw digital photographs"

LCMSVER=2.16
JASPERVER=4.2.4

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DJASPERVER=$JASPERVER
    -DLCMSVER=$LCMSVER
"

SKIP_LICENCES='JasPer'

set_arch 64
test_relver '>=' 151051 && set_clangver
set_builddir $PROG
set_standard XPG6

CFLAGS[aarch64]+=" -mtls-dialect=trad"

init
prep_build

#########################################################################

save_buildenv

CONFIGURE_OPTS="--disable-shared"
build_dependency lcms2 lcms2-$LCMSVER $PROG/lcms2 lcms2 $LCMSVER

LDFLAGS[aarch64]+=" -L${SYSROOT[aarch64]}$PREFIX/${LIBDIRS[aarch64]}"

CONFIGURE_OPTS[amd64]="-DCMAKE_INSTALL_LIBDIR=${LIBDIRS[amd64]}"
CONFIGURE_OPTS[aarch64]="
    -DJAS_CROSSCOMPILING=ON
    -DJAS_STDC_VERSION=201112L
    -DCMAKE_INSTALL_LIBDIR=${LIBDIRS[aarch64]}
"
CONFIGURE_OPTS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DJAS_ENABLE_SHARED=false"
build_dependency -cmake jasper jasper-$JASPERVER $PROG/jasper jasper $JASPERVER

restore_buildenv

#########################################################################

note -n "-- Building $PROG"

configure_arch() {
    typeset arch=$1


    CPPFLAGS+=" -I$DEPROOT$PREFIX/include"
    CPPFLAGS+=" -I${SYSROOT[$arch]}$PREFIX/include"
    LDFLAGS+=" -L$DEPROOT$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS+=" -L${SYSROOT[$arch]}$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"

    subsume_arch $arch CPPFLAGS
    subsume_arch $arch CFLAGS
    subsume_arch $arch LDFLAGS
}

make_arch() {
    typeset arch=$1

    logcmd $CC $CPPFLAGS $CFLAGS -o dcraw dcraw.c \
        $LDFLAGS -lm -ljasper -llcms2 -ljpeg -lheif || logerr "build failed"
}

make_install() {
    logcmd $MKDIR -p $DESTDIR/$PREFIX/bin $DESTDIR/$PREFIX/share/man/man1
    logcmd $CP $PROG $DESTDIR/$PREFIX/bin || logerr "cp $PROG"
    logcmd $CP $PROG.1 $DESTDIR/$PREFIX/share/man/man1/ || logerr "cp $PROG.1"
}

download_source $PROG $PROG $VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
