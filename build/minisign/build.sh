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

PROG=minisign
VER=0.12
PKG=ooce/security/minisign
SUMMARY="$PROG"
DESC="Simple tool to sign files and verify signatures"

set_arch 64
set_clangver

SKIP_SSP_CHECK=1

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_STRIP=$USRBIN/true
"

pre_build() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]=
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"
}

init
download_source -nodir $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build -noctf
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
