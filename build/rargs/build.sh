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

PROG=rargs
VER=0.3.0
PKG=ooce/util/rargs
SUMMARY="$PROG"
DESC="xargs + awk with pattern-matching support"

BUILD_DEPENDS_IPS="ooce/developer/rust"

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
