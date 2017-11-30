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

# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.

#
# Load support functions
. ../../lib/functions.sh

PROG=nasm
VER=2.13.02
VERHUMAN=$VER
PKG=developer/nasm
SUMMARY="The Netwide Assembler"
DESC="$SUMMARY"

BUILDARCH=32

# Nasm uses INSTALLROOT instead of the more standard DESTDIR
make_install() {
    logmsg "--- make install"
    logcmd $MAKE INSTALLROOT=${DESTDIR} install || \
        logerr "--- Make install failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
