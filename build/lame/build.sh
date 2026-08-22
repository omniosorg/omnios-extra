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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=lame
VER=4.0
PKG=ooce/audio/lame
SUMMARY="The LAME MP3 encoder"
DESC="A high quality MP3 enocder"

MPG123VER=1.33.7

forgo_isaexec
set_clangver
set_standard XPG6

BUILD_DEPENDS_IPS="
    developer/nasm
"

SKIP_RTIME_CHECK=1

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

init
prep_build

#########################################################################

save_buildenv

# Download and build libmpg123
CONFIGURE_OPTS="
    --disable-components
    --enable-libmpg123
"
CONFIGURE_OPTS[i386]+=" --with-cpu=x86"
CONFIGURE_OPTS[amd64]+=" --with-cpu=x86-64"
CONFIGURE_OPTS[aarch64]+=" --with-cpu=aarch64"

build_dependency -merge mpg123 mpg123-$MPG123VER mpg123 mpg123 $MPG123VER

restore_buildenv

#########################################################################

CONFIGURE_OPTS="
    --enable-nasm
"

pre_configure() {
    typeset arch=$1

    _dd=$DESTDIR
    cross_arch $arch && _dd+=.$arch

    logcmd $RM -f $_dd$PREFIX/${LIBDIRS[$arch]}/libmpg123.la \
        || logerr "rm libmpg123.la failed"

    export mpg123_CFLAGS="-I$_dd$PREFIX/include"
    export mpg123_LIBS="-L$_dd$PREFIX/${LIBDIRS[$arch]} -lmpg123"
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $PROG $VER
patch_source
build
LD_LIBRARY_PATH=$DESTDIR$PREFIX/${LIBDIRS[$BUILD_ARCH]} run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
