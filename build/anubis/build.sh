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

PROG=anubis
PKG=ooce/application/anubis
GITHUBORG=TecharoHQ
VER=1.25.0
SUMMARY="$PROG HTTP defence proxy"
DESC="$PROG weighs the soul of incoming HTTP requests to stop bots"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_gover

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DUSER=$PROG -DGROUP=$PROG
"

build() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logmsg "Building 64-bit"
    logcmd $MAKE || logerr "Build failed"

    popd >/dev/null
}

install_config() {
    logmsg "Installing configuration files"

    logcmd $MKDIR -p $DESTDIR/etc$PREFIX || logerr "mkdir etc failed"

    # The default environment file is taken from the upstream distribution,
    # prefixed with a note on how service instances are managed on OmniOS.
    cat << EOM > $DESTDIR/etc$PREFIX/default.env
# Template configuration for instances of the anubis service.
#
# To protect a backend service, copy this file to
# /etc$PREFIX/<instance>.env, customise it, then create and enable an
# SMF service instance:
#	svccfg -s anubis add <instance>
#	svcadm enable anubis:<instance>
#
# This file must be readable by the '$PROG' service user. If it contains
# secrets, restrict it with 'chgrp $PROG' and 'chmod 640'.
#
# An example bot policy file is installed at $PREFIX/share/botPolicies.yaml;
# copy it alongside this file and point POLICY_FNAME at it to customise
# policies. See https://anubis.techaro.lol/docs/admin/installation for all
# available options.

EOM
    cat $TMPDIR/$BUILDDIR/run/default.env >> $DESTDIR/etc$PREFIX/default.env \
        || logerr "Cannot install default.env"

    logcmd $MKDIR -p $DESTDIR$PREFIX/share || logerr "mkdir share failed"
    logcmd $CP $TMPDIR/$BUILDDIR/data/botPolicies.yaml \
        $DESTDIR$PREFIX/share/botPolicies.yaml \
        || logerr "Cannot install botPolicies.yaml"
}

init
clone_go_source $PROG $GITHUBORG v$VER
patch_source
prep_build
build
install_go var/anubis anubis
install_go var/robots2policy robots2policy
install_config
xform $SRCDIR/files/$PROG.xml > $TMPDIR/$PROG.xml
xform $SRCDIR/files/$PROG > $TMPDIR/$PROG
install_smf -oocemethod ooce $PROG.xml $PROG
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
