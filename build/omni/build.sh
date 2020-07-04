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
#
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=omni
VER=github-latest
PKG=ooce/developer/omni
SUMMARY="OmniOS build management utility"
DESC=$SUMMARY
PREFIX=/opt/ooce

set_mirror "$OOCEGITHUB/$PROG/releases/download"

XFORM_ARGS="-D PREFIX=$PREFIX"

build() {
    logcmd mkdir -p "$DESTDIR/$PREFIX/$PROG"
    ( cd $TMPDIR/$BUILDDIR; find . | cpio -pvmud "$DESTDIR/$PREFIX/$PROG/" )
}

init
set_builddir $PROG-v$VER
download_source v$VER $PROG v$VER
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
