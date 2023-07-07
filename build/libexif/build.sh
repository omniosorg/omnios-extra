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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libexif
VER=0.6.21
PKG=ooce/library/libexif
SUMMARY="libexif"
DESC="Reads and writes EXIF metainformation from and to image files."

test_relver '>=' 151041 && set_clangver

OPREFIX=$PREFIX
PREFIX+="/$PROG"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --disable-static
"
CONFIGURE_OPTS[i386]="
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --libdir=$OPREFIX/lib/amd64
"
CONFIGURE_OPTS[aarch64]+="
    --libdir=$OPREFIX/lib
"

LDFLAGS[i386]+=" -lssp_ns"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
