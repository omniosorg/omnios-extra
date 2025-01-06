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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=starship
VER=1.21.1
PKG=ooce/terminal/starship
SUMMARY="cross-shell prompt"
DESC="The minimal, blazing-fast, and infinitely customizable prompt for any shell!"

BUILD_DEPENDS_IPS="
    ooce/developer/rust
"

SKIP_SSP_CHECK=1

CARGO_ARGS="--no-default-features --features=gix-max-perf"

set_arch 64

pre_build() {
    typeset arch=$1

    export RUSTFLAGS="-C link-arg=-R$PREFIX/${LIBDIRS[$arch]}"
}

init
clone_github_source $PROG "$GITHUB/starship/$PROG" $VER 
append_builddir $PROG
patch_source
prep_build
build_rust $CARGO_ARGS
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
