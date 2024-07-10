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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pass
VER=1.7.4
PKG=ooce/util/pass
SUMMARY="password store"
DESC="$PROG - the standard unix password manager"

GETOPTVER=1.1.6

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_builddir password-store-$VER

RUN_DEPENDS_IPS="
    developer/versioning/git
    file/gnu-coreutils
    shell/bash
    ooce/file/tree
    ooce/security/gnupg
"

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

# No configure
pre_configure() { false; }

init
prep_build

#########################################################################

# Download and build getopt

export PREFIX CFLAGS

build_dependency -merge getopt getopt-$GETOPTVER $PROG/getopt getopt $GETOPTVER

#########################################################################

MAKE_INSTALL_ARGS="PREFIX=$PREFIX"

download_source $PROG $BUILDDIR
patch_source
build -noctf    # shell script
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
