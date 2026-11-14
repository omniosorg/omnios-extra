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

PROG=rat-commander
VER=1.9.9
PKG=ooce/application/rat-commander
SUMMARY="A modern, dual pane file manager"
DESC="A spiritual successor to Midnight-Commander with modern features like "
DESC+="truecolor support and built-in process- and disk-explorer, disk "
DESC+="imager and network monitor."

BUILD_DEPENDS_IPS="
    ooce/developer/rust
"

set_arch 64
RUST_PROFILE=release

SKIP_SSP_CHECK=1
BMI_EXPECTED=1

init
download_source $PROG v$VER
patch_source
prep_build
export CARGO_PROFILE_RELEASE_STRIP=false
build_rust
PROG=rc install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
