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

PROG=git-absorb
VER=0.6.13
PKG=ooce/developer/git-absorb
SUMMARY="Automatically absorb changes into staged commits"
DESC="You have a feature branch with a few commits. "
DESC+="Your teammate reviewed the branch and pointed out a few bugs. "
DESC+="You have fixes for the bugs, but you don't want to shove them all into "
DESC+="an opaque commit that says fixes, because you believe in atomic commits."

BUILD_DEPENDS_IPS="
    ooce/developer/rust
"

set_arch 64

init
download_source $PROG $VER
patch_source
prep_build
build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
