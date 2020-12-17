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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=fd
VER=8.2.1
PKG=ooce/util/fd
SUMMARY="find utility"
DESC="fd is a simple, fast and user-friendly alternative to find"

if [ $RELVER -lt 151028 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

BUILD_DEPENDS_IPS=ooce/developer/rust

set_arch 64

init
download_source $PROG v$VER
patch_source
prep_build
build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
