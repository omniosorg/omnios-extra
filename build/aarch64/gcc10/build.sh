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
# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../common.sh

PKG=ooce/developer/aarch64-gcc10
PROG=gcc
VER=10.3.0
ILVER=il-1
SUMMARY="gcc $VER-$ILVER ($ARCH)"
DESC="The GNU Compiler Collection"

REPO=$GITHUB/richlowe/$PROG
BRANCH=il-${VER//./_}-arm64

GCCMAJOR=${VER%%.*}

XFORM_ARGS="
    -D MAJOR=$GCCMAJOR
    -D PREFIX=${PREFIX#/}
    -D GCCVER=$VER
    -D TRIPLET64=$TRIPLET64
"

BMI_EXPECTED=1
NO_SONAME_EXPECTED=1

# Build gcc with itself
set_gccver $GCCMAJOR

set_arch 64
set_ssp none

# We're building the 64-bit version of the compiler and tools but we want
# to install it in the standard bin/lib locations. Gcc will take care of
# building and putting the 32/64 objects in the right places. We also want
# to unset all of the flags that we usually pass for a 64-bit object so that
# gcc can properly create the multilib targets.
CONFIGURE_OPTS_64="$CONFIGURE_OPTS_32"
unset CFLAGS32 CFLAGS64
unset CPPFLAGS32 CPPFLAGS64
unset CXXFLAGS32 CXXFLAGS64
unset LDFLAGS32 LDFLAGS64

# Use bash for all shells - some corruption occurs in libstdc++-v3/config.status
# otherwise.
export CONFIG_SHELL=$SHELL
export MAKESHELL=$SHELL
# Place the GNU utilities first in the path
export PATH=$GNUBIN:$PATH

LANGUAGES="c,c++"

RUN_DEPENDS_IPS="
    ooce/developer/$ARCH-gnu-binutils
    ooce/developer/$ARCH-linker
    ooce/developer/$ARCH-sysroot
"

export LD=/bin/ld
export LD_FOR_HOST=/bin/ld
export LD_FOR_TARGET=$PREFIX/bin/ld
export AS_FOR_TARGET=$PREFIX/bin/gas
#export HEADERS=$SYSROOT/usr/include
#export CFLAGS_FOR_TARGET=-I$HEADERS
export STRIP="/usr/bin/strip -x"
export STRIP_FOR_TARGET="$STRIP"

HARDLINK_TARGETS="
    ${PREFIX#/}/bin/$TRIPLET64-gcc-$VER
    ${PREFIX#/}/bin/$TRIPLET64-gcc-ar
    ${PREFIX#/}/bin/$TRIPLET64-gcc-nm
    ${PREFIX#/}/bin/$TRIPLET64-gcc-ranlib
    ${PREFIX#/}/bin/$TRIPLET64-c++
    ${PREFIX#/}/bin/$TRIPLET64-g++
"

PKGDIFF_HELPER="
    s^/$GCCMAJOR\\.[0-9]\\.[0-9]([/ ])^/$GCCMAJOR.x.x\\1^
    s^/gcc-$GCCMAJOR\\.[0-9]\\.[0-9]^/gcc-$GCCMAJOR.x.x^
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --host $NATIVE_TRIPLET64
    --build $NATIVE_TRIPLET64
    --target $TRIPLET64
    --without-gnu-ld --with-ld=$LD_FOR_TARGET
    --with-gnu-as --with-as=$AS_FOR_TARGET
    --with-sysroot=$SYSROOT
    --with-gmp-include=/usr/include/gmp
    --with-build-time-tools=$PREFIX/usr/gnu/$TRIPLET64/bin
    --with-build-config=no
    --enable-languages=$LANGUAGES
    --enable-shared
    --with-system-zlib
    --enable-plugins
    --enable-__cxa_atexit
    --enable-initfini-array
    --with-diagnostics-urls=auto-if-env
    --disable-bootstrap
    --disable-decimal-float
    --disable-libatomic
    --disable-libcilkrts
    --disable-libgomp
    --disable-libitm
    --disable-libmudflap
    --disable-libquadmath
    --disable-libsanitizer
    --disable-libvtv
    --disable-nls
    --disable-shared
    --enable-c99
    --enable-long-long
    enable_frame_pointer=yes
"
CONFIGURE_OPTS_WS="
    --with-boot-ldflags=\"-R$PREFIX/lib\"
    --with-boot-cflags=\"-O2\"
    --with-pkgversion=\"OmniOS $RELVER/$VER-$ILVER\"
    --with-bugurl=$HOMEURL/about/contact
"
LDFLAGS="-R$PREFIX/lib"
CPPFLAGS+=" -D_TS_ERRNO"

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=${DESTDIR} install-strip || \
        logerr "--- Make install failed"
}

init
clone_github_source $PROG $REPO $BRANCH
append_builddir $PROG
patch_source
# gcc should be built out-of-tree
prep_build autoconf -oot
build -noctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
