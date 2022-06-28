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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=mattermost
VER=7.0.1
MMCTLVER=7.0.0
PKG=ooce/application/mattermost
SUMMARY="$PROG"
DESC="All your team communication in one place, "
DESC+="instantly searchable and accessible anywhere."

set_arch 64
set_gover 1.18
set_nodever

BUILD_DEPENDS_IPS+="
    ooce/library/libpng
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

export BUILD_NUMBER=$VER
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH64
export PATH="$GNUBIN:$PATH"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

# Unfortunately, the mattermost webapp has a number of dependencies which are
# specified with ssh:// URLs for accessing github. npm is unable to retrieve
# these unless the build user has an SSH key for accessing github, and that key
# cannot be protected with a passphrase.
# To work around this, we create a git config file that does URL rewrites to
# translate these back to https://github.com/ and a small git stub to force use
# of that config file since 'npm' strips the environment before invoking git.
gitenv() {
    GITCONFIG=$TMPDIR/gitconfig
    : > $GITCONFIG
    logcmd git config -f $GITCONFIG url."github.com/".insteadOf git@github.com/
    logcmd git config -f $GITCONFIG url."https://".insteadOf ssh://

    GITBIN=$TMPDIR/gitbin
    logcmd rm -rf $GITBIN
    logcmd mkdir $GITBIN || logerr "Cannot create $GITBIN"
    cat << EOM > $GITBIN/git
#!/bin/sh
GIT_CONFIG_GLOBAL=$GITCONFIG /usr/bin/git "\$@"
EOM
    logcmd chmod +x $GITBIN/git

    PATH="$GITBIN:$PATH"
}

build() {
    prog="$1"; shift

    note -n "Building $prog"

    EXTRACTED_SRC+=/$prog patch_source patches-$prog

    export GOPATH=$TMPDIR/$BUILDDIR/$prog/_deps

    pushd $TMPDIR/$BUILDDIR/$prog > /dev/null
    logcmd $MAKE "$@" || logerr "Build failed"
    popd >/dev/null

    logmsg "Fixing permissions on $prog dependencies"
    logcmd chmod -R u+w $GOPATH
}

install() {
    logcmd mkdir -p $DESTDIR/$OPREFIX || logerr "mkdir"

    logcmd rsync -a $TMPDIR/$BUILDDIR/$PROG-server/dist/$PROG \
        $DESTDIR/$OPREFIX/ || logerr "copying dist"

    logcmd cp $TMPDIR/$BUILDDIR/mmctl/mmctl $DESTDIR/$PREFIX/bin \
        || logerr "copying mmctl"

    logmsg "Creating config path"
    logcmd mkdir -p $DESTDIR/etc/$PREFIX || logerr "creating config dir"
    logcmd mv $DESTDIR/$PREFIX/config/* $DESTDIR/etc/$PREFIX \
        || logerr "copying config"
}

init
prep_build
gitenv
save_variables BUILDDIR EXTRACTED_SRC
clone_go_source mmctl $PROG v$MMCTLVER
restore_variables BUILDDIR EXTRACTED_SRC
clone_go_source "$PROG-server" $PROG v$VER
restore_variables BUILDDIR EXTRACTED_SRC
clone_github_source -dependency "$PROG-webapp" \
    "$GITHUB/$PROG/$PROG-webapp" v$VER
((EXTRACT_MODE)) && exit
build mmctl "ADVANCED_VET=FALSE"

if [ $RELVER -lt 151033 ]; then
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH32"
    export LDFLAGS=" -R$OPREFIX/lib"
else
    export LDFLAGS=" -R$OPREFIX/lib/$ISAPART64"
fi
build $PROG-webapp build
export LDFLAGS=

build $PROG-server build-illumos package-illumos
install
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
