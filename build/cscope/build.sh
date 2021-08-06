#!/usr/bin/bash
#
# {{{
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2020 Carsten Grzemba
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=cscope
VER=15.9
PKG=ooce/developer/cscope
SUMMARY="Cscope is a developer's tool for browsing source code"
DESC="Cscope is a developer's tool for browsing source code. It has an impeccable"
DESC+="Unix pedigree, having been originally developed at Bell Labs back in the"
DESC+="days of the PDP-11. Cscope was part of the official AT&T Unix distribution"
DESC+="for many years, and has been used to manage projects involving 20 million" 
DESC+="lines of code!"

# COPYING do not mention the BSD license type, only README
SKIP_LICENCES=BSD

set_mirror "https://downloads.sourceforge.net/"
set_checksum sha256 "c5505ae075a871a9cd8d9801859b0ff1c09782075df281c72c23e72115d9f159"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

CFLAGS+=" -D_FILE_OFFSET_BITS=64"
LDFLAGS64+=" -Wl,-zignore"

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
