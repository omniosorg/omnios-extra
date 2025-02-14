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

PROG=clamav
VER=1.4.2
PKG=ooce/system/clamav
SUMMARY="Clam Anti-virus"
DESC="$PROG is an open-source antivirus engine for detecting trojans, "
DESC+="viruses, malware & other malicious threats."

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

# We want to populate the clang-related environment variables
# and set PATH to point to the correct llvm/clang version for
# the clamav bytecode runtime, but we want to build with gcc.
# currently only llvm 8 - 13 are supported
set_clangver 13

BASEPATH=$PATH set_gccver $DEFAULT_GCC_VER

SKIP_LICENCES='COPYING.*'
XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPKGROOT=$PROG
    -DUSER=clamav -DGROUP=clamav
"

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
    -DBYTECODE_RUNTIME=llvm
"
CONFIGURE_OPTS[amd64]="
    -DJSONC_LIBRARY=$OPREFIX/lib/amd64/libjson-c.so
"
LDFLAGS+=" -lncurses"

post_install() {
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

    add_notes README.install
    xform $SRCDIR/files/clamav.xml > $TMPDIR/clamav.xml
    install_smf -oocemethod ooce clamav.xml
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
