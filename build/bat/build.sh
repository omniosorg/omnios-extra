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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=bat
VER=0.18.0
PKG=ooce/util/bat
SUMMARY="A cat clone with wings"
DESC="A cat(1) clone with syntax highlighting and Git integration."

# clang is a build-time requirement for 0.12.x
CLANGVER=11.1

BUILD_DEPENDS_IPS="
    ooce/developer/rust
    ooce/developer/clang-${CLANGVER//./}
"

set_arch 64

# ansi_colours wants gnu-ar
export AR="$USRBIN/gar"
export LIBCLANG_PATH="$PREFIX/clang-$CLANGVER/lib"

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
