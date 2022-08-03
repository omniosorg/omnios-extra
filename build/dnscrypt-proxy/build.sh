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

PROG=dnscrypt-proxy
PKG=ooce/network/dnscrypt-proxy
VER=2.1.2
SUMMARY="DNS proxy with support for encrypted DNS protocols"
DESC="A flexible DNS proxy, with support for modern encrypted DNS protocols"
DESC+=" such as DNSCrypt v2 and DNS-over-HTTP/2."

set_arch 64
set_gover 1.18

BASEDIR=$PREFIX/$PROG
CONFFILE=/etc$BASEDIR/$PROG.conf
EXECFILE=$PREFIX/bin/$PROG

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DCONFFILE=$CONFFILE
    -DUSER=dnscrypt
    -DGROUP=dnscrypt
    -DPROG=$PROG
"

build() {
    pushd $TMPDIR/$BUILDDIR/$PROG > /dev/null

    logmsg "Building 64-bit"
    logcmd go build || logerr "Build failed"
    logcmd ./dnscrypt-proxy -version || logerr "$PROG failed"

    popd >/dev/null
}

copy_sample_config() {
    local relative_conffile=${CONFFILE#/}
    local dest_confdir=$DESTDIR/${relative_conffile%/*}

    logmsg "-- copying sample config"
    logcmd mkdir -p "$dest_confdir" || logerr "mkdir failed"
    logcmd cp $TMPDIR/$BUILDDIR/$PROG/example-$PROG.toml \
        $DESTDIR/$relative_conffile || logerr "copying configs failed"
}

init
clone_go_source $PROG DNSCrypt $VER
patch_source
prep_build
build
copy_sample_config
install_go $PROG/$PROG $PROG
xform files/$PROG.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
