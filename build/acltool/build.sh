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

PROG=acltool
VER=1.16.2
PKG=ooce/file/acltool
SUMMARY="acltool - display and update NFSv4/ZFS/SMB ACLs"
DESC="acltool is a program to display and update NFSv4/ZFS/SMB ACLs "
DESC+="in a more sane way - and also works the same on OmniOS, Linux, "
DESC+="FreeBSD and MacOS."

set_arch 64

set_mirror "$GITHUB/ptrrkssn/$PROG/archive"
set_checksum sha256 \
    d54011efb3d5cc24aedad88e3684d1c9dea218515bb1f18d9caac33f8bbae501

init
download_source v$VER $PROG $VER
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
