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
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=openvpn
VER=2.5.0
PKG=ooce/network/openvpn
LZOVER=2.10
SUMMARY="OpenVPN"
DESC="Flexible VPN solutions to secure your data communications, whether it's "
DESC+="for Internet privacy, remote access for employees, securing IoT, "
DESC+="or for networking Cloud data centers"

# source from https://github.com/skvadrik/re2c (required to build auth-ldap)
RE2CVER=2.0.3
AUTHLDAPVER=2.0.4

SKIP_LICENCES=Various

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="driver/tuntap compress/lz4"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG -DVER=$VER
    -DPKGROOT=$PROG
    -DAUTHLDAP=$AUTHLDAPVER
"

set_arch 64

init
prep_build

#########################################################################

save_buildenv

# Download and build a static version of liblzo
CONFIGURE_OPTS="
    --prefix=/usr
    --disable-shared
"
CONFIGURE_OPTS_64=
build_dependency lzo lzo-$LZOVER lzo lzo $LZOVER
export LZO_CFLAGS="-I$DEPROOT/usr/include"
export LZO_LIBS="-L$DEPROOT/usr/lib -llzo2"

restore_buildenv

#########################################################################

# Build 64-bit only and skip the arch-specific directories
CONFIGURE_OPTS_64+="
    --includedir=$OPREFIX/include
    --libdir=$OPREFIX/lib/$ISAPART64
"

if [ $RELVER -lt 151035 ]; then
    # lz4 was moved to core in r151035
    export LZ4_CFLAGS="-I$OPREFIX/include"
    export LZ4_LIBS="-L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64 -llz4"
fi

download_source $PROG $PROG $VER
patch_source
run_autoreconf -i
build
install_smf ooce network-openvpn.xml

#########################################################################

# Download and build additional plugins

#########################################################################

# Download and build re2c which is required to build auth-ldap
build_dependency -noctf re2c re2c-$RE2CVER $PROG/re2c re2c $RE2CVER # C++
export PATH+=":$DEPROOT/$PREFIX/bin"

#########################################################################

# Download and build auth-ldap plugin
PLUGIN=auth-ldap
LIBDIR=$OPREFIX/lib/$ISAPART64/$PROG/plugins

save_function configure64 _configure64
configure64() {
    run_inbuild "./regen.sh"
    _configure64
}

CONFIGURE_OPTS_64="
    --libdir=$LIBDIR
    --with-openldap=$OPREFIX
    --with-openvpn=$DESTDIR/$OPREFIX/include
    OBJC=$CC
    OBJCFLAGS=-std=gnu11
"
CFLAGS+=" -fPIC"

build_dependency -merge $PLUGIN $PROG-$PLUGIN-$PLUGIN-$AUTHLDAPVER \
    $PROG/$PLUGIN $PLUGIN $AUTHLDAPVER

#########################################################################

manifest_start $TMPDIR/manifest.$PLUGIN
manifest_add $LIBDIR $PROG-$PLUGIN.so
manifest_finalise

manifest_uniq $TMPDIR/manifest.{$PROG,$PLUGIN}

RUN_DEPENDS_IPS="ooce/network/openvpn" \
    PKG=$PKG-auth-ldap SUMMARY="OpenVPN Auth-LDAP Plugin" \
    DESC="username/password authentication via LDAP for OpenVPN 2.x." \
    make_package -seed $TMPDIR/manifest.$PLUGIN $PLUGIN.mog

RUN_DEPENDS_IPS="driver/tuntap" \
    make_package -seed $TMPDIR/manifest.$PROG $PROG.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
