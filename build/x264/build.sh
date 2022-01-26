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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=x264
VER=20210613
PKG=ooce/multimedia/x264
SUMMARY="H.264/MPEG-4 AVC encoder"
DESC="Free software library and application for encoding video streams "
DESC+="into the H.264/MPEG-4 AVC compression format"

set_builddir $PROG-stable
forgo_isaexec
[ $RELVER -ge 151041 ] && set_clangver

# x264 contains BMI instructions even when built on an older CPU
BMI_EXPECTED=1

CONFIGURE_OPTS="
    --enable-shared
"
CONFIGURE_OPTS_32+="
    --enable-pic
"
[ $RELVER -lt 151041 ] && CONFIGURE_OPTS_32+=" --disable-asm" \
    || CONFIGURE_OPTS_32+=" --host=$TRIPLET32"
CONFIGURE_OPTS_64+="
    --host=$TRIPLET64
"

MAKE_INSTALL_ARGS="-e INSTALL=$GNUBIN/install"

CFLAGS+=" -O3"

[ $RELVER -ge 151037 ] && LDFLAGS32+=" -lssp_ns"
LDFLAGS64+=" -Wl,-R$PREFIX/lib/$ISAPART64"

# we don't want x264 to have a (circular) runtime dependency on ffmpeg
PKG_CONFIG_PATH32=
PKG_CONFIG_PATH64=

init
download_source $PROG $PROG-stable $VER
patch_source
prep_build
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
