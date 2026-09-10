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

PROG=fzy
GITHUBORG=jhawthorn
VER=1.1
PKG=ooce/util/fzy
SUMMARY="A better fuzzy finder"
DESC="A fast, simple fuzzy text selector for the terminal, with an advanced "
DESC+="scoring algorithm"

set_arch 64

# Upstream ships a plain Makefile with no configure script.
pre_configure() { false; }

# No configure step; hand CFLAGS/LDFLAGS to make via the environment.
pre_make() {
    typeset arch=$1

    export CFLAGS="${CFLAGS[0]} ${CFLAGS[$arch]}"
    export LDFLAGS="${LDFLAGS[0]} ${LDFLAGS[$arch]}"
}

MAKE_INSTALL_ARGS+=" PREFIX=$PREFIX"

init
clone_github_source $PROG "$GITHUB/$GITHUBORG/$PROG" v$VER
append_builddir $PROG
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
