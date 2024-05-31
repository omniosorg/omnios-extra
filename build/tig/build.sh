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

# Copyright 2022 Martin Samuelsson
# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=tig
VER=2.5.8
PKG=ooce/application/tig
SUMMARY="Tig: text-mode interface for Git"
DESC="Tig is an ncurses-based text-mode interface for git. \
    It functions mainly as a Git repository browser, but can \
    also assist in staging changes for commit at chunk level \
    and act as a pager for output from various Git commands."

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

MAKE_INSTALL_TARGET+=" install-doc-man"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
