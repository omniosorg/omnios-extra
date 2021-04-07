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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=stress-ng
VER=0.12.06
PKG=ooce/util/stress-ng
SUMMARY="Stress test a computer system in various selectable ways"
DESC="$PROG - $SUMMARY"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

configure64() {
    export CFLAGS+=" $CFLAGS64"

    MAKE_ARGS="LIB_ATOMIC= LIB_RT="
    MAKE_INSTALL_ARGS="
        -e
        BINDIR=$PREFIX/bin
        MANDIR=$PREFIX/share/man/man1
        JOBDIR=$PREFIX/share/example-jobs
        BASHDIR=$PREFIX/share/bash-completion/completions
    "
}

init
download_source $PROG V$VER
prep_build
patch_source
build -noctf    # https://www.illumos.org/issues/13698
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
