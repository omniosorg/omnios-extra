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

PROG=pwol
VER=1.5.2
PKG=ooce/network/pwol
SUMMARY="$PROG - pwol 1.5.2"
DESC="$PROG is a program to send Wake-on-LAN packets in order"
DESC+=" to wake up computers"

set_arch 64

set_mirror "$GITHUB/ptrrkssn/$PROG/archive"
set_checksum sha256 70e8352782b4a605f642c28585d9b26a83ed2d76fc44154aa8b9f3f7cb7c8c6e

init
download_source v$VER $PROG $VER
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
