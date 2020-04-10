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

# Copyright 2020 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=tree
VER=1.8.0
PKG=ooce/file/tree
SUMMARY="File system tree viewer"
DESC="The tree utility recursively displays the contents of \
directories in a tree-like format"

set_arch 64

# No configure
configure64() { :; }

MAKE_ARGS_WS="
    -e
    CFLAGS=\"$CFLAGS $CFLAGS64\"
    LDFLAGS=\"$LDFLAGS $LDFLAGS64\"
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
MAKE_INSTALL_ARGS="prefix=$DESTDIR/$PREFIX" build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
