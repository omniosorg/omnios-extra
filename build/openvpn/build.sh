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
#
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=openvpn
VER=2.4.8
PKG=ooce/network/openvpn
LZOVER=2.10
SUMMARY="OpenVPN"
DESC="Flexible VPN solutions to secure your data communications, whether it's "
DESC+="for Internet privacy, remote access for employees, securing IoT, "
DESC+="or for networking Cloud data centers"

SKIP_LICENCES=Various

OPREFIX=$PREFIX
PREFIX+="/$PROG"
CONFPATH=/etc$PREFIX
VARPATH=/var$OPREFIX/$PROG

BUILD_DEPENDS_IPS="driver/tuntap ooce/compress/lz4"
RUN_DEPENDS_IPS="driver/tuntap"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

set_arch 64

init
prep_build

#########################################################################

# Download and build a static version of liblzo
CONFIGURE_OPTS="
    --prefix=/usr
    --disable-shared
"
CONFIGURE_OPTS_64=
build_dependency lzo lzo-$LZOVER lzo lzo $LZOVER
export LZO_CFLAGS="-I$DEPROOT/usr/include"
export LZO_LIBS="-L$DEPROOT/usr/lib -llzo2"

#########################################################################

install_config() {
    logcmd mkdir -p $DESTDIR/$CONFPATH
    for f in server client; do
        logmsg "Installing $f config file"
        logcmd cp $TMPDIR/$BUILDDIR/sample/sample-config-files/$f.conf $DESTDIR/$CONFPATH
    done
}

# Build 64-bit only and skip the arch-specific directories
CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
    --includedir=$OPREFIX/include
    --libdir=$OPREFIX/lib/$ISAPART64
"

export LZ4_CFLAGS="-I$OPREFIX/include"
export LZ4_LIBS="-L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64 -llz4"

download_source $PROG $PROG $VER
patch_source
build
install_config
install_smf network network-openvpn.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
