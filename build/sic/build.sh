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

# Copyright 2022 r7st r7st.guru@gmail.com

. ../../lib/build.sh

PROG=sic
VER=1.3
PKG=ooce/network/sic
SUMMARY="simple irc client"
DESC="sic is an extremely simple IRC client. It consists of less than "
DESC+="250 lines of code. It is the little brother of irc it."

set_arch 64

set_mirror "https://dl.suckless.org/"
set_checksum sha256 "30478fab3ebc75f2eb5d08cbb5b2fedcaf489116e75a2dd7197e3e9c733d65d2"
set_builddir $PROG-$VER

build64() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building 64-bit"
    make_clean
    make_prog64
    [ -z "$SKIP_BUILD_ERRCHK" ] && check_buildlog ${EXPECTED_BUILD_ERRS:-0}
    make_install64
    popd > /dev/null
}

init
download_source tools $PROG-$VER
prep_build
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker

