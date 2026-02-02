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

PROG=direnv
VER=2.37.1
PKG=ooce/util/direnv
SUMMARY="unclutter your .profile"
DESC="A shell extension that can load and unload environment variables "
DESC+="depending on the current directory."

set_arch 64
set_gover

MAKE_INSTALL_ARGS+=" PREFIX=$PREFIX"
pre_configure() { false; }

init
download_source $PROG v$VER
patch_source
prep_build
build -noctf
run_testsuite test-go
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
