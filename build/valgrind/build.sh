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

PROG=valgrind
VER=3.26.0
PKG=ooce/developer/valgrind
SUMMARY="An instrumentation framework for building dynamic analysis tools."
DESC="Valgrind tools can automatically detect many memory management and "
DESC+="threading bugs, and profile your programs in detail."

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_ssp none
CTF_FLAGS+=" -s"

NO_SONAME_EXPECTED=1

# valgrind configure requires GNU tools
export PATH=$GNUBIN:$PATH

# use illumos file(1) which follows symlinks by default
export FILE

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

# valgrind builds both, 32 and 64-bit backends
# we should not override the bitness it sets to build/link individual objects
CFLAGS[amd64]=
LDFLAGS[amd64]=

init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf -autoreconf
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
