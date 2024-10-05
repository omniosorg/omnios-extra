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

PROG=mc
PKG=ooce/application/mc
VER=4.8.32
SUMMARY="Midnight Commander"
DESC="A feature rich full-screen text mode application that allows you to copy, "
DESC+="move and delete files and whole directory trees, search for files and run "
DESC+="commands in the subshell. Internal viewer and editor are included."

BUILD_DEPENDS_IPS="
    ooce/library/slang
"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
test_relver '>=' 151047 && set_clangver

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc/$PREFIX
"
LDFLAGS[amd64]+=" -Wl,-R$OPREFIX/lib/amd64"
LDFLAGS[aarch64]+=" -Wl,-R$OPREFIX/lib"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
