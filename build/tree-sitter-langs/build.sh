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

PROG=tree-sitter-langs
VER=0.12.171
PKG=ooce/text/tree-sitter-langs
SUMMARY="$PROG"
DESC="Tree-sitter Language Bundle for Emacs"

set_arch 64

NO_SONAME_EXPECTED=1
SKIP_SSP_CHECK=1

build() {
    logmsg "Building 64-bit"

    pushd $TMPDIR/$BUILDDIR >/dev/null

    # a few builds fail; others terminate non-zero although the language
    # library built correctly. we don't check for build success but rather
    # check whether all libraries are present by comparing to a baseline
    logcmd ./script/compile all

    popd >/dev/null

    destdir="$DESTDIR$PREFIX/${LIBDIRS[amd64]}"
    logcmd $MKDIR -p $destdir || logerr "mkdir failed"

    pushd $TMPDIR/$BUILDDIR/bin >/dev/null

    for f in *.so; do
        logcmd $CP $f $destdir/libtree-sitter-$f || logerr "copying $f failed"
    done

    popd >/dev/null

    convert_ctf $destdir

    logmsg "comparing baseline"

    pushd $destdir >/dev/null

    logcmd $DIFF -u $SRCDIR/files/baseline <($LS -1) || logerr "baseline mismatch"

    popd >/dev/null
}

init
clone_github_source $PROG "$GITHUB/emacs-tree-sitter/$PROG" $VER
append_builddir $PROG
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
