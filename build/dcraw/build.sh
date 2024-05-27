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

LCMSVER=2.15
JASPERVER=4.0.0

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DJASPERVER=$JASPERVER
    -DLCMSVER=$LCMSVER
"

SKIP_LICENCES='JasPer'

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

set_arch 64
set_builddir $PROG

pre_configure() {
    typeset arch=$1

    test_relver '>' 151038 && return

    export CMAKE_LIBRARY_PATH=$PREFIX/${LIBDIRS[$arch]}
}

init
prep_build

#########################################################################

save_buildenv

unset CONFIGURE_OPTS
CONFIGURE_OPTS="--prefix=/usr --disable-shared"
build_dependency lcms2 lcms2-$LCMSVER $PROG/lcms2 lcms2 $LCMSVER

unset CONFIGURE_OPTS
CONFIGURE_OPTS+=" -DCMAKE_INSTALL_PREFIX=/usr"
CONFIGURE_OPTS+=" -DJAS_ENABLE_SHARED=false"
build_dependency -cmake jasper jasper-$JASPERVER $PROG/jasper jasper $JASPERVER

restore_buildenv

CPPFLAGS+=" -I$DEPROOT/usr/include"
LDFLAGS+=" -L$DEPROOT/usr/lib"

#########################################################################

note -n "-- Building $PROG"

configure_arch() {
    typeset arch=$1

    CPPFLAGS+=" -I$OOCEOPT/include"
    LDFLAGS+=" -L$OOCEOPT/${LIBDIRS[$arch]} -R$OOCEOPT/${LIBDIRS[$arch]}"

    subsume_arch $arch CPPFLAGS
    subsume_arch $arch CFLAGS
    subsume_arch $arch LDFLAGS
}

make_arch() {
    typeset arch=$1

    logcmd $GCC $CPPFLAGS $CFLAGS -o dcraw dcraw.c \
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
