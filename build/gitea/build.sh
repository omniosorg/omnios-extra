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

PROG=gitea
PKG=ooce/application/gitea
VER=1.27.3
SUMMARY="Git with a cup of tea"
DESC="Git with a cup of tea, painless self-hosted git service"

set_builddir $PROG-src-$VER

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_gover

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

BUILD_DEPENDS_IPS+="
	network/rsync
"
RUN_DEPENDS_IPS=developer/versioning/git

# gitea build wants GNU grep from 1.11.x on
export PATH="$GNUBIN:$PATH"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    subsume_arch amd64 LDFLAGS
    export LDFLAGS=" \
    -X gitea.dev/modules/setting.CustomPath=/var$PREFIX/custom \
    -X gitea.dev/modules/setting.CustomConf=/etc$PREFIX/app.ini \
    -X gitea.dev/modules/setting.AppWorkPath=/var$PREFIX \
    "

    logmsg "Building 64-bit"
    TAGS="bindata sqlite sqlite_mattn sqlite_unlock_notify" logcmd $MAKE build \
        || logerr "Build failed"

    typeset cfg="`./gitea help | $SED -n '
            /DEFAULT CONFIGURATION:/,$ {
                /AppPath/n
                p
            }
        '`"
    logmsg "$cfg"
    for p in \
        WorkPath:/var$PREFIX \
        CustomPath:/var$PREFIX/custom \
        ConfigFile:/etc$PREFIX/app.ini; do
        typeset var=${p%%:*}
        typeset val=${p#*:}
        echo "$cfg" | grep -q "$var:[[:space:]]*$val\$" \
            || logerr "$var is not $val"
    done

    # Gitea version <ver> built with go<ver>
    [ "`./gitea --version | awk '{print $3}'`" = "$VER" ] \
        || logerr "version patch failed."
    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "mkdir"
    logcmd cp $TMPDIR/$BUILDDIR/$PROG $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "Cannot install binary"

    logcmd mkdir -p $DESTDIR/etc/$PREFIX || logerr "mkdir etc"
    logcmd mkdir -p $DESTDIR/var/$PREFIX/{custom,data} || logerr "mk data"

    logcmd cp $TMPDIR/$BUILDDIR/custom/conf/app.example.ini \
        $DESTDIR/etc/$PREFIX/ || logerr "cp app.example.ini"

    for dir in templates options public; do
        logcmd rsync -a {$TMPDIR/$BUILDDIR,$DESTDIR/var/$PREFIX}/$dir/ \
            || logerr "rsync $dir failed"
    done
}

init
download_source $PROG $PROG-src $VER
patch_source
prep_build
build
install
install_smf application gitea.xml gitea
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
