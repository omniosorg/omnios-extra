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

PROG=tree
VER=2.1.0
PKG=ooce/file/tree
SUMMARY="File system tree viewer"
DESC="The tree utility recursively displays the contents of \
directories in a tree-like format"

set_arch 64
[ $RELVER -ge 151045 ] && set_clangver

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        -e
        CFLAGS=\"$CFLAGS ${CFLAGS[$arch]}\"
        LDFLAGS=\"$LDFLAGS ${LDFLAGS[$arch]}\"
    "

    MAKE_INSTALL_ARGS="
        DESTDIR=$DESTDIR/$PREFIX/bin
        PREFIX=$PREFIX
        MANDIR=$DESTDIR/$PREFIX/share/man
    "

    # no configure
    false
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
