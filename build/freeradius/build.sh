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

PROG=freeradius
PKG=ooce/server/freeradius
VER=3.2.1
TALLOCVER=2.3.3
MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
SUMMARY="FreeRADIUS $MAJVER"
DESC="The open source implementation of RADIUS, an IETF protocol for AAA "
DESC+="(Authorisation, Authentication, and Accounting)."

OPREFIX=$PREFIX
PREFIX+=/$PROG

# talloc ships its own licence that refers out to LGPLv3
SKIP_LICENCES=LGPLv3

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG-$MAJVER
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
    -DDsVERSION=-$sMAJVER
    -DUSER=radius -DUID=74
    -DGROUP=radius -DGID=74
"

set_builddir $PROG-server-$VER
set_arch 64
set_standard XPG4v2

SKIP_RTIME_CHECK=1
NO_SONAME_EXPECTED=1

init
prep_build

## build talloc dependency
save_buildenv

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --disable-python
"
build_dependency -merge talloc talloc-$TALLOCVER $PROG talloc $TALLOCVER
# Extract the talloc licence
sed '/^\*/q' < $TMPDIR/talloc-$TALLOCVER/talloc.c > $TMPDIR/LICENCE.talloc

restore_buildenv

note -n "Building $PROG"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --with-logdir=/var/log$PREFIX
    --localstatedir=/var$PREFIX
    --with-raddbdir=/etc$PREFIX
    --libdir=$PREFIX/lib/$ISAPART64
    --with-talloc-include-dir=$DESTDIR$PREFIX/include
    --with-talloc-lib-dir=$DESTDIR$PREFIX/lib/$ISAPART64
"

# This prevents the build from embedding the temporary build directory into the
# runpath of every object.
MAKE_ARGS_WS="
    TALLOC_LDFLAGS=\"-L$DESTDIR$PREFIX/lib/$ISAPART64 \
        -R$PREFIX/lib/$ISAPART64\"
"

# To find OpenLDAP
CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

download_source $PROG "$PROG-server" $VER
patch_source
MAKE_INSTALL_ARGS="R=$DESTDIR" build -ctf
xform files/freeradius-template.xml > $TMPDIR/$PROG-$sMAJVER.xml
install_smf ooce $PROG-$sMAJVER.xml
add_notes README.server-install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
