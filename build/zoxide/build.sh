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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=zoxide
VER=0.9.9
PKG=ooce/terminal/zoxide
SUMMARY="A smarter cd command"
DESC="Remembers which directories you use most frequently, so you can "jump" to them in just a few keystrokes"

BUILD_DEPENDS_IPS="
    ooce/developer/rust
"

SKIP_SSP_CHECK=1

BMI_EXPECTED=1

CARGO_ARGS="--no-default-features"

set_arch 64

pre_build() {
	typeset arch=$1
	export CARGO_PROFILE_RELEASE_STRIP=none
	export RUSTFLAGS="-C link-arg=-R$PREFIX/${LIBDIRS[$arch]}"
}

init
clone_github_source $PROG "$GITHUB/ajeetdsouza/$PROG" v$VER
append_builddir $PROG
patch_source
prep_build
build_rust $CARGO_ARGS
install_rust
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
