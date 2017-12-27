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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=asciidoc
VER=8.6.9
VERHUMAN=$VER
PKG=ooce/text/asciidoc
SUMMARY="AsciiDoc - text based documentation"
DESC="$SUMMARY"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS=" -DOPREFIX=$OPREFIX -DPREFIX=$PREFIX"

# Building twice fails due to xmllint failure. Always use a fresh copy of
# the source.
REMOVE_PREVIOUS=1

# Build 32-bit only and skip the arch-specific directories
BUILDARCH=32
CONFIGURE_OPTS="
    --sysconfdir=/etc/$OPREFIX
    --bindir=$PREFIX/bin
"

reset_configure_opts

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
