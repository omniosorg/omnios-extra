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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pbzip2
PKG=ooce/compress/pbzip2
VER=1.1.13
SUMMARY=$PROG
DESC="Parallel implementation of the bzip2 block-sorting file compressor"

SKIP_LICENCES=pbzip2

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

export CXX

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        CXXFLAGS=\"$CXXFLAGS ${CXXFLAGS[$arch]}\"
        LDFLAGS=\"$LDFLAGS ${LDFLAGS[$arch]}\"
        LDLIBS_PTHREAD=
    "
    MAKE_INSTALL_ARGS="PREFIX=$PREFIX"

    # no configure
    false
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -noctf    # C++
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
