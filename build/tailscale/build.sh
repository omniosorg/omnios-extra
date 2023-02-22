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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=tailscale
PKG=ooce/network/tailscale
VER=1.36.1
SUMMARY="Tailscale"
DESC="The easiest, most secure way to use WireGuard and 2FA."

if [ $RELVER -lt 151044 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

RUN_DEPENDS_IPS="driver/tuntap"

XFORM_ARGS+="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DSERVICE=$PKG
"
set_arch 64
set_gover

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    export CGO_ENABLED=0
    export GOOS=illumos
    logcmd bash -x ./build_dist.sh --box ./cmd/tailscaled \
        || logerr "failed to compile tailscaled"
    logcmd /usr/bin/elfedit \
        -e "ehdr:ei_osabi ELFOSABI_SOLARIS" \
        -e "ehdr:ei_abiversion EAV_SUNW_CURRENT" \
        tailscaled \
        || logerr "failed to fixup elf headers"
    popd >/dev/null
}

install() {
    mkdir -p $DESTDIR/$PREFIX/sbin
    cp $TMPDIR/$BUILDDIR/tailscaled $DESTDIR/$PREFIX/sbin/
}

init
# Use nshalman fork until it is fully upstreamed
clone_go_source $PROG nshalman "v$VER-sunos"
prep_build
build
install
xform files/$PROG.xml > $TMPDIR/network-$PROG.xml
install_smf ooce network-$PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
