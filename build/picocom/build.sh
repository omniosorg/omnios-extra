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

PROG=picocom
VER=3.1
PKG=ooce/terminal/picocom
SUMMARY="Minimal dumb-terminal emulation program"
DESC="picocom is a minimal dumb-terminal emulation program. It is, in "
DESC+="principle, very much like minicom, only it's 'pico' instead of 'mini'!"

# We build from a commit later than the 3.1 release to pick up some fixes that
# we need. Bump DASHREV whenever moving the hash forwards.
HASH=1acf1ddabaf3576b4023c4f6f09c5a3e4b086fb8
DASHREV=1

set_builddir $PROG-$HASH

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

pre_configure() {
    typeset arch=$1

    # We want to inject our CFLAGS into the build to enable things like the
    # stack protector.
    subsume_arch $arch CFLAGS
    MAKE_ARGS=-e

    # No configure
    false
}

# No install target
make_install() {
    typeset destdir="$DESTDIR$PREFIX"

    logcmd $MKDIR -p $destdir/bin $destdir/share/man/man1 \
        || logerr "mkdir failed"
    logcmd $CP $PROG $destdir/bin/ || logerr "Failed to copy $PROG"
    logcmd $CP $PROG.1 $destdir/share/man/man1/ \
        || logerr "Failed to copy $PROG.1"
}

init
download_source $PROG $PROG $HASH
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
