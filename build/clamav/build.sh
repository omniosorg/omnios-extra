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

PROG=clamav
VER=0.104.2
PKG=ooce/system/clamav
SUMMARY="Clam Anti-virus"
DESC="$PROG is an open-source antivirus engine for detecting trojans, "
DESC+="viruses, malware & other malicious threats."

if [ $RELVER -lt 151036 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

SKIP_LICENCES='COPYING.*'
XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPKGROOT=$PROG
    -DUSER=clamav -DGROUP=clamav
"

CONFIGURE_OPTS_64=
CONFIGURE_OPTS="
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DAPP_CONFIG_DIRECTORY=/etc$PREFIX
    -DDATABASE_DIRECTORY=/var$PREFIX
    -DCLAMAV_USER=clamav
    -DCLAMAV_GROUP=clamav

    -DENABLE_MILTER=OFF
    -DENABLE_DOXYGEN=OFF
    -DENABLE_EXAMPLES=OFF
    -DENABLE_TESTS=OFF
    -DENABLE_SYSTEMD=OFF

    -DJSONC_LIBRARY=$OPREFIX/lib/$ISAPART64/libjson-c.so
"

function prepare_config {
    pushd $DESTDIR/etc$PREFIX >/dev/null || logerr "pushd etc"
    local tf=`mktemp`
    for f in clamd.conf freshclam.conf; do
        logcmd cp $f.sample $tf || logerr "cp $f"
        logcmd $PATCH -p1 -t -N $tf < $SRCDIR/files/$f.patch \
            || logerr "Patching $f failed"
        xform $tf > $f || logerr "xform $f failed"
    done
    rm -f $tf
    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build
add_notes README.install
prepare_config
xform files/clamav.xml > $TMPDIR/clamav.xml
install_smf -oocemethod ooce clamav.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
