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

PROG=dtc
VER=1.7.0
PKG=ooce/util/dtc
SUMMARY="Device Tree Compiler"
DESC="$PROG - $SUMMARY"

set_arch 64

# No configure
configure64() { :; }

NO_SONAME_EXPECTED=1

# TODO: no debug info/SSP for shared library
MAKE_ARGS="
    NO_YAML=1
    NO_PYTHON=1
    PREFIX=$PREFIX
"
MAKE_ARGS_WS="
    EXTRA_CFLAGS=\"$CTF_CFLAGS $SSPFLAGS\"
    SHAREDLIB_LDFLAGS=\"-shared -Wl,-soname\"
    LDFLAGS=\"-R$PREFIX/lib/$ISAPART64\"
"
MAKE_INSTALL_ARGS="
    $MAKE_ARGS
    LIBDIR=$PREFIX/lib/$ISAPART64/libfdt
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
