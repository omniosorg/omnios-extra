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

# Copyright 2011-2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../common.sh

PROG=perl
PKG=ooce/developer/aarch64-perl
VER=5.42.0
MAJVER=${VER%.*}
SUMMARY="Perl $MAJVER Programming Language"
DESC="A highly capable, feature-rich programming language"

CROSSVER=1.6.2

set_arch 64
CTF_FLAGS+=" -s"

CROSSTOOLS=$PREFIX/bin
PREFIX+=/perl5/$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DMAJVER=$MAJVER
"

# Perl bundles a lot of shared objects with its extensions
NO_SONAME_EXPECTED=1
SKIP_SSP_CHECK=1

BUILD_DEPENDS_IPS="text/gnu-sed"

# perl-cross requires GNU tools
export PATH="$GNUBIN:$PATH"

init
prep_build

save_variables BUILDDIR EXTRACTED_SRC
set_builddir $PROG-cross-$CROSSVER
download_source $PROG $PROG-cross $CROSSVER
patch_source patches-$PROG-cross
restore_variables BUILDDIR EXTRACTED_SRC

configure_amd64() {
    logcmd $RSYNC -a $TMPDIR/$PROG-cross-$CROSSVER/* $TMPDIR/$BUILDDIR/ \
        || logerr "rsync perl-cross failed"

    logmsg "--- configure (64-bit)"
    # A note about 'myuname'. In previous OmniOS releases this was set to be
    # undefined, but as of the r151041 bloody cycle it has been set to 'sunos'.
    # In particular, this makes some modules make better choices about things
    # like compiler flags (Crypt::OpenSSL:X509 is one), but there is a risk
    # that some modules might assume that myuname=='sunos' => Sun studio
    # rather than checking 'ccname'.
    logcmd $CONFIGURE_CMD \
        --target=$TRIPLET64 \
        --host-libs="m" \
        --host-set-osname=solaris \
        --host-set-use64bitall=define \
        -Dccdlflags= \
        -Dusethreads \
        -Duseshrplib \
        -Dusemultiplicity \
        -Duselargefiles \
        -Duse64bitall \
        -Dmyhostname=localhost \
        -Umydomain \
        -Dmyuname=sunos \
        -Dosname=solaris \
        -Dcf_by=$DISTRO_LC-builder \
        -Dcf_email=$PUBLISHER_EMAIL \
        -Dcc=$CROSSTOOLS/$TRIPLET64-gcc \
        -Dcpp=$CROSSTOOLS/$TRIPLET64-cpp \
        -Dld=$CROSSTOOLS/ld \
        -Dar=$CROSSTOOLS/$TRIPLET64-ar \
        -Dnm=$CROSSTOOLS/$TRIPLET64-nm \
        -Dranlib=$CROSSTOOLS/$TRIPLET64-ranlib \
        -Dreadelf=$CROSSTOOLS/$TRIPLET64-readelf \
        -Dobjdump=$CROSSTOOLS/$TRIPLET64-objdump \
        -Doptimize="-O3 $CTF_CFLAGS" \
        -Dprefix=${PREFIX} \
        -Dvendorprefix=${PREFIX} \
        -Dbin=${PREFIX}/bin \
        -Dsitebin=${PREFIX}/bin \
        -Dvendorbin=${PREFIX}/bin \
        -Dscriptdir=${PREFIX}/bin \
        -Dsitescript=${PREFIX}/bin \
        -Dvendorscript=${PREFIX}/bin \
        -Dsitelib=/usr/perl5/site_perl/$MAJVER \
        -Dvendorlib=/usr/perl5/vendor_perl/$MAJVER \
        -Darchlib=${PREFIX}/lib/aarch64-solaris \
        -Ulocincpth= \
        -Uloclibpth= \
        -Dlibs="-lsocket -lnsl -lm -lc" \
        -Dusrinc=${PREFIX}/include \
        -Dincpth=${PREFIX}/include \
        -Dlibpth=${PREFIX}/lib \
        || logerr "--- Configure failed"

    logcmd sed -i "
        s/^d_setenv=.*/d_setenv='undef'/g
        s/^d_unsetenv=.*/d_unsetenv='undef'/g
        s/^ccdlflags=.*/ccdlflags=''/g
    " xconfig.sh
}

make_install_amd64() {
    logmsg "--- make install"

    for d in bin lib/aarch64-solaris-64/CORE; do
        logcmd $MKDIR -p $DESTDIR$PREFIX/$d || logerr "mkdir $d failed"
    done
    logcmd $CP $TMPDIR/$BUILDDIR/miniperl $DESTDIR$PREFIX/bin \
        || logerr "cp miniperl failed"
    logcmd $RSYNC -a $TMPDIR/$BUILDDIR/lib/* \
        $DESTDIR$PREFIX/lib/aarch64-solaris-64/ \
        || logerr "rsync lib failed"
    logcmd $CP -f $TMPDIR/$BUILDDIR/*.h \
        $DESTDIR$PREFIX/lib/aarch64-solaris-64/CORE/ \
        || logerr "rsync include failed"
}

download_source $PROG $PROG $VER
patch_source
# building miniperl is racy
MAKE_JOBS= MAKE_ARGS="miniperl" build
configure_amd64() { :; }
MAKE_ARGS="xconfig.h modules" build
xform files/perl > $TMPDIR/perl
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
