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

PROG=fzf
GITHUBORG=junegunn
VER=0.74.4
PKG=ooce/util/fzf
SUMMARY="A command-line fuzzy finder"
DESC="An interactive filter for any list -- files, command history, processes, "
DESC+="git branches -- with shell key bindings and completion"

RUN_DEPENDS_IPS="
    shell/bash
"

set_arch 64
set_gover

# Upstream builds every fzf release binary without cgo (goreleaser).
export CGO_ENABLED=0

# FZF_VERSION is pinned to $VER so the stamped version matches the package
# version; FZF_REVISION stays the commit hash.
build() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    typeset rev="`$GIT log -n 1 --pretty=format:%h --abbrev=8`"
    logmsg "Building 64-bit (version $VER, revision $rev)"
    logcmd $MAKE FZF_VERSION=$VER FZF_REVISION=$rev bin/fzf \
        || logerr "Build failed"

    popd >/dev/null
}

install_extra() {
    typeset src=$TMPDIR/$BUILDDIR

    logmsg "Installing fzf-tmux"
    logcmd $MKDIR -p $DESTDIR$PREFIX/bin || logerr "mkdir bin failed"
    logcmd $CP $src/bin/fzf-tmux $DESTDIR$PREFIX/bin/fzf-tmux \
        || logerr "Cannot install fzf-tmux"
    logcmd $CHMOD 0755 $DESTDIR$PREFIX/bin/fzf-tmux || logerr "chmod failed"

    logmsg "Installing man pages"
    logcmd $MKDIR -p $DESTDIR$PREFIX/share/man/man1 || logerr "mkdir man failed"
    for m in fzf fzf-tmux; do
        logcmd $CP $src/man/man1/$m.1 $DESTDIR$PREFIX/share/man/man1/$m.1 \
            || logerr "Cannot install $m.1"
    done

    logmsg "Installing bash completion"
    logcmd $MKDIR -p $DESTDIR$PREFIX/share/bash-completion/completions \
        || logerr "mkdir bash-completion failed"
    logcmd $CP $src/shell/completion.bash \
        $DESTDIR$PREFIX/share/bash-completion/completions/$PROG \
        || logerr "Cannot install bash completion"

    # The .nu files are skipped: nushell is not packaged for OmniOS.
    logmsg "Installing shell integration"
    logcmd $MKDIR -p $DESTDIR$PREFIX/share/$PROG/shell \
        || logerr "mkdir shell failed"
    for f in key-bindings.bash completion.zsh key-bindings.zsh \
             completion.fish key-bindings.fish; do
        logcmd $CP $src/shell/$f $DESTDIR$PREFIX/share/$PROG/shell/$f \
            || logerr "Cannot install $f"
    done

    logmsg "Installing preview helper"
    logcmd $CP $src/bin/fzf-preview.sh $DESTDIR$PREFIX/share/$PROG/ \
        || logerr "Cannot install fzf-preview.sh"
    logcmd $CHMOD 0755 $DESTDIR$PREFIX/share/$PROG/fzf-preview.sh \
        || logerr "chmod failed"
}

init
clone_go_source $PROG $GITHUBORG v$VER
patch_source
prep_build
build
install_go bin/fzf
install_extra
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
