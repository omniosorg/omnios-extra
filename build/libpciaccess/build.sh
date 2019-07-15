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
# Copyright 2018 Thomas Merkel
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libpciaccess
VER=0.15
PKG=ooce/library/libpciaccess
SUMMARY="PCI access utility library from X.org"
DESC="The pciaccess library wraps platform-dependent PCI access "
DESC+="methods in a convenient library."

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
