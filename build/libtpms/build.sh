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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libtpms
VER=0.10.0
PKG=ooce/library/libtpms
SUMMARY="$PROG"
DESC="$PROG - library that targets the integration of TPM functionality "
DESC+="into hypervisors"

set_clangver

export MAKE

CONFIGURE_OPTS="
    --disable-static
"

CPPFLAGS+=" -DOOCEVER=$RELVER"

init
download_source $PROG v$VER
patch_source
prep_build autoconf -autoreconf
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
