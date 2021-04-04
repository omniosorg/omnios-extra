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

PROG=nicstat
VER=1.95
PKG=ooce/network/nicstat
SUMMARY="network monitoring tool"
DESC="command-line utility that prints out network "
DESC+="statistics for all network interface cards (NICs), including packets, "
DESC+="kilobytes per second, average packet sizes and more."

set_arch 64

configure64() {
    MAKE_ARGS_WS="-e COPT=\"$CFLAGS $CFLAGS64\" -f Makefile.Solaris"
}

save_function make_install _make_install
make_install() {
    for d in bin share/man/man1; do
        logcmd mkdir -p $DESTDIR$PREFIX/$d || logerr "mkdir failed"
    done

    MAKE_INSTALL_ARGS_WS="
        -e COPT=\"$CFLAGS $CFLAGS64\"
        BASEDIR=$DESTDIR$PREFIX INSTALL=$GNUBIN/install -f Makefile.Solaris
    "

    _make_install
}

init
download_source $PROG $PROG $VER
prep_build
patch_source
build -ctf
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
