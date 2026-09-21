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

PROG=bmake
VER=20260824
PKG=ooce/developer/bmake
SUMMARY="NetBSD make"
DESC="A portable version of the NetBSD make(1) build tool, which understands "
DESC+="BSD makefiles"

set_arch 64
# Upstream publishes flat tarballs under .../pub/sjg, hence sjg as the
# download directory below.
set_mirror https://www.crufty.net/ftp/pub

# Upstream ships no .sha256 alongside the tarball, so the checksum is carried here.
set_checksum sha256 \
    76c6253a592dd55741be0b14805b9f7e0eb8442004146a978f24b20f37d2cb72

# No configure/make step: the real Makefile is BSD syntax, and boot-strap
# compiles the sources directly with $CC.

build() {
    # boot-strap builds in a <host-target> subdirectory, so it is given an
    # explicit object directory rather than one beside the source tree.
    OBJDIR=$TMPDIR/obj/$HOST_TARGET
    logcmd $MKDIR -p $TMPDIR/obj || logerr "Failed to create object directory"

    pushd $TMPDIR/obj >/dev/null

    # boot-strap's exit status reflects the unit tests rather than the
    # compilation, so the binary is checked instead.
    logmsg "Bootstrapping $PROG"
    logcmd env CC="$CC" $TMPDIR/$BUILDDIR/boot-strap --prefix=$PREFIX op=build

    OBJDIR=
    for d in $TMPDIR/obj/*/; do
        [ -x "$d$PROG" ] && OBJDIR="${d%/}"
    done
    [ -n "$OBJDIR" ] || logerr "boot-strap produced no $PROG binary"
    logmsg "-- built $OBJDIR/$PROG"

    popd >/dev/null
}

install_bmake() {
    pushd $TMPDIR/obj >/dev/null

    # The 'tested' sentinel makes op_install() skip its op_test() call, which
    # would otherwise abort the install on a test failure; the tests run under
    # run_testsuite below.
    logcmd $TOUCH $OBJDIR/tested || logerr "Failed to mark tests as run"

    logmsg "Installing $PROG"
    # INSTALL -- the Makefile calls install(1) with BSD syntax, which illumos
    # install(1) rejects; use the install-sh bmake bundles.
    # MANTARGET -- bmake defaults to a preformatted page in share/man/cat1.
    logcmd env CC="$CC" $TMPDIR/$BUILDDIR/boot-strap --prefix=$PREFIX \
        op=install INSTALL_DESTDIR=$DESTDIR \
        INSTALL="$TMPDIR/$BUILDDIR/install-sh" MANTARGET=man \
        || logerr "Installation failed"

    popd >/dev/null
}

# This must repeat upstream's own exclusions: a command-line variable replaces
# the makefile's BROKEN_TESTS rather than appending to it, and dropping them
# makes var-op-shell fail. deptgt-interrupt is added because it kills its own
# make with SIGINT, which takes the test shell with it here, so no .out is
# written -- and a failed prerequisite skips the comparison of every other test.
BROKEN_TESTS="deptgt-silent-jobs job-flags job-output-long-lines"
BROKEN_TESTS+=" opt-debug-x-trace sh-flags var-op-shell deptgt-interrupt"

run_tests() {
    TESTSUITE_MAKE="$OBJDIR/$PROG"
    MAKE_TESTSUITE_ARGS="-m $TMPDIR/$BUILDDIR/mk TEST_MAKE=$OBJDIR/$PROG"
    # A value containing spaces has to go through MAKE_TESTSUITE_ARGS_WS;
    # MAKE_TESTSUITE_ARGS is word-split.
    MAKE_TESTSUITE_ARGS_WS="'BROKEN_TESTS=$BROKEN_TESTS'"
    run_testsuite test unit-tests
}

init
set_builddir $PROG
download_source sjg $PROG $VER
patch_source
prep_build
build
run_tests
install_bmake
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
