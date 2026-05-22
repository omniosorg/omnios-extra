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

PROG=fish
VER=4.7.1
PKG=ooce/shell/fish
SUMMARY=$PROG
DESC="$PROG - Friendly Interactive SHell"
OPREFIX=$PREFIX
PREFIX+="/$PROG"
SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
    ooce/developer/rust
"

HARDLINK_TARGETS=${PREFIX#/}/bin/fish

set_arch 64
set_mirror https://github.com
set_checksum sha256 6f4d5b438a6338e3f5dcda19a28261e2ece7a9b7ff97686685e6abdc31dbb7df

CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release 
    -DCMAKE_INSTALL_PREFIX=$PREFIX 
"

CONFIGURE_OPTS[amd64]="
    -DCMAKE_INSTALL_LIBDIR=$OPREFIX/lib/amd64
"

XFORM_ARGS="
    -DPKGROOT=${PREFIX#/opt/ooce/}
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
"

SKIP_LICENSES=Various

init
download_source fish-shell/fish-shell/releases/download/${VER} ${PROG} ${VER}
prep_build cmake
patch_source
build -noctf
make_package
strip_install
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
