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

# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=ntpsec
VER=1.0.0
VERHUMAN=$VER
PKG=service/network/ntpsec
SUMMARY="A secure, hardened and improved Network Time Protocol implementation"
DESC="$SUMMARY"

BUILDARCH=64
XFORM_ARGS="-D PVER=$PYTHONVER"

# Required to generate man pages
BUILD_DEPENDS_IPS="ooce/text/asciidoc"
export PATH=$PATH:/opt/ooce/bin

# NTPsec uses the 'waf' build system

make_clean() {
    logcmd ./waf distclean
}

configure64() {
    logmsg "--- configure"
    BIN_ASCIIDOC=/opt/ooce/bin/asciidoc \
        BIN_A2X=/opt/ooce/bin/a2x \
        CC='gcc -m64' \
        logcmd ./waf configure \
        --prefix=/usr \
        --sysconfdir=/etc/inet \
        --refclock=all \
        --define=CONFIG_FILE=/etc/inet/ntp.conf \
        --python=/usr/bin/python$PYTHONVER \
        --pythondir=/usr/lib/python$PYTHONVER/vendor-packages \
        --pythonarchdir=/usr/lib/python$PYTHONVER/vendor-packages \
        --nopyc \
        --nopyo \
        --nopycache \
        || logerr "--- configure failed"
}

make_prog() {
    logmsg "--- build"
    logcmd ./waf build || logerr "--- build failed"
}

make_install() {
    logmsg "--- install"
    logcmd ./waf install \
        --destdir=$DESTDIR \
        || logerr "--- install failed"
}

install_ntpdate() {
    logcmd cp $TMPDIR/$BUILDDIR/attic/ntpdate $DESTDIR/usr/bin/ntpdate
    logcmd chmod 755 $DESTDIR/usr/bin/ntpdate
}

install_files() {
    logmsg "--- install files"

    logcmd mkdir -p $DESTDIR/etc/inet
    logcmd cp $SRCDIR/files/ntp.conf $DESTDIR/etc/inet/ntp.conf

    logcmd mkdir -p $DESTDIR/etc/security/auth_attr.d
    logcmd mkdir -p $DESTDIR/etc/security/prof_attr.d
    logcmd cp $SRCDIR/files/security/auth_attr \
        $DESTDIR/etc/security/auth_attr.d/ntp
    logcmd cp $SRCDIR/files/security/prof_attr \
        $DESTDIR/etc/security/prof_attr.d/ntp
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
logcmd cp $TMPDIR/$BUILDDIR/build/main/test.log $SRCDIR/testsuite.log
install_ntpdate
install_files
install_smf network ntpsec.xml ntpsec
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
