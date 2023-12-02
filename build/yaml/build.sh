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

PROG=yaml
VER=0.2.5
PKG=ooce/library/yaml
SUMMARY="LibYAML"
DESC="$SUMMARY - A C library for parsing and emitting YAML."

set_clangver

# many false positives show up in macro warnings in the log
SKIP_BUILD_ERRCHK=1

TESTSUITE_FILTER='^[A-Z#0-9 ][A-Z#0-9 ]'

CONFIGURE_OPTS="--disable-static"

init
download_source $PROG $PROG $VER
prep_build
patch_source
build
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
