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

PROG=helix
VER=25.01
PKG=ooce/editor/helix
SUMMARY="A post-modern modal text editor."
DESC="A kakoune / neovim inspired editor, written in Rust."

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

SKIP_SSP_CHECK=1
NO_SONAME_EXPECTED=1 # files in runtime dir

install_helix_runtime() {
    pushd $DESTDIR/$PREFIX >/dev/null || logerr "chdir $DESTDIR/$PREFIX"

    logcmd $MKDIR -p "share/runtime" || logerr "Failed to create runtime dir"

    logcmd $RSYNC -a $TMPDIR/$BUILDDIR/runtime/ share/runtime/ \
        || logerr "rsync runtime failed"

    # We have no control over the symlinks in this directory, so lets remove
    # the dangling ones now.
    find share/runtime -type l | while read link; do
        $READLINK -e "$link" >/dev/null || logcmd $RM "$link"
    done

    popd >/dev/null
}

init
prep_build
download_source -nodir $PROG $PROG $VER-source
patch_source
build_rust
install_rust hx
install_helix_runtime
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
