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

PROG=glow
GITHUBORG=charmbracelet
VER=3.0.0
PKG=ooce/text/glow
SUMMARY="Render markdown on the CLI, with pizzazz!"
DESC="A terminal based markdown reader designed from the ground up to bring "
DESC+="out the beauty and power of the CLI"

set_arch 64
set_gover

build() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    typeset commit="`$GIT rev-parse HEAD`"

    logmsg "Building 64-bit"
    logcmd $GO build -p 2 -trimpath \
        -ldflags "-s -w -X main.Version=$VER -X main.CommitSHA=$commit" \
        -o $PROG . || logerr "Build failed"

    logmsg "Generating man page"
    logcmd -p env NO_COLOR=1 TERM=dumb ./$PROG man > $PROG.1 \
        || logerr "Failed to generate man page"

    logmsg "Generating shell completions"
    for shell in bash zsh fish; do
        logcmd -p env NO_COLOR=1 ./$PROG completion $shell > $PROG.$shell \
            || logerr "Failed to generate $shell completion"
    done

    popd >/dev/null
}

install_extra() {
    logmsg "Installing man page and shell completions"

    logcmd $MKDIR -p $DESTDIR$PREFIX/share/man/man1 \
        || logerr "Failed to create man install dir"
    logcmd $CP $TMPDIR/$BUILDDIR/$PROG.1 \
        $DESTDIR$PREFIX/share/man/man1/$PROG.1 \
        || logerr "Failed to install man page"

    logcmd $MKDIR -p $DESTDIR$PREFIX/share/bash-completion/completions \
        || logerr "Failed to create bash completion dir"
    logcmd $CP $TMPDIR/$BUILDDIR/$PROG.bash \
        $DESTDIR$PREFIX/share/bash-completion/completions/$PROG \
        || logerr "Failed to install bash completion"

    logcmd $MKDIR -p $DESTDIR$PREFIX/share/zsh/site-functions \
        || logerr "Failed to create zsh completion dir"
    logcmd $CP $TMPDIR/$BUILDDIR/$PROG.zsh \
        $DESTDIR$PREFIX/share/zsh/site-functions/_$PROG \
        || logerr "Failed to install zsh completion"

    logcmd $MKDIR -p $DESTDIR$PREFIX/share/fish/vendor_completions.d \
        || logerr "Failed to create fish completion dir"
    logcmd $CP $TMPDIR/$BUILDDIR/$PROG.fish \
        $DESTDIR$PREFIX/share/fish/vendor_completions.d/$PROG.fish \
        || logerr "Failed to install fish completion"
}

init
clone_go_source $PROG $GITHUBORG v$VER
patch_source
prep_build
build
install_go
install_extra
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
