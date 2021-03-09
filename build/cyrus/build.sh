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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=cyrus
VER=3.2.6
PKG=ooce/network/cyrus-imapd
SUMMARY="Cyrus IMAP is an email, contacts and calendar server"
DESC="$SUMMARY"

JANSSONVER=2.13.1
ICUVER=68.2
ICALVER=3.0.9

OPREFIX="$PREFIX"
PREFIX+="/$PROG"

SKIP_LICENCES='*attribution*'
SKIP_RTIME_CHECK=1

set_arch 64
set_builddir $PROG-imapd-$VER

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DUSER=cyrus -DGROUP=cyrus
    -DRUNDIR=var/run/cyrus
    -DJANSSON=$JANSSONVER
    -DICU=$ICUVER
    -DICAL=$ICALVER
"

init
prep_build autoconf -autoreconf

#########################################################################
# Download and build bundled dependencies

save_buildenv

build_dependency -ctf jansson jansson-$JANSSONVER $PROG/jansson v$JANSSONVER

CONFIGURE_OPTS+=" --disable-tests --disable-samples"
build_dependency -ctf icu4c icu/source $PROG/icu icu4c-${ICUVER//./_}-src

restore_buildenv

depinc=$DEPROOT$PREFIX/include
deplib=$DEPROOT$PREFIX/lib/$ISAPART64

addpath PKG_CONFIG_PATH64 $deplib/pkgconfig

CPPFLAGS+=" -I$depinc"
LDFLAGS64+=" -L$deplib"

CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

LDFLAGS+=" -R$PREFIX/lib/$ISAPART64"

## Build ical dependency, which uses cmake

save_buildenv

CONFIGURE_CMD="$CMAKE ."
CONFIGURE_OPTS_64=
CONFIGURE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DICAL_BUILD_DOCS=OFF
    -DENABLE_GTK_DOC=OFF
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib/$ISAPART64
    -DCMAKE_LIBRARY_ARCHITECTURE=$ISAPART64
"
RUN_AUTORECONF=

build_dependency libical libical-$ICALVER $PROG/libical libical $ICALVER

restore_buildenv

#########################################################################

note -n "Building Cyrus-imapd"

export KRB5_LIBS="-L/usr/lib/$ISAPART64 -lkrb5"
export KRB_LIBS="-lkrb5"
export KRB5_CFLAGS="-I/usr/include/kerberosv5"
CPPFLAGS+=" $KRB5_CFLAGS"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --enable-replication
    --enable-murder
    --enable-autocreate
    --enable-http
    --enable-calalarmd
    --enable-idled
    --with-sasl=$OPREFIX
"
CONFIGURE_OPTS_64+=" --libexecdir=$PREFIX/libexec"

save_function make_install _make_install
make_install() {
    _make_install "$@"

    # Copy in the dependency libraries

    pushd $deplib >/dev/null
    for lib in libical* libjansson* libicu*; do
        [[ $lib = *.so.* && -f $lib && ! -h $lib ]] || continue
        tgt=`echo $lib | cut -d. -f1-3`
        logmsg "--- installing library $lib -> $tgt"
        logcmd cp $lib $DESTDIR/$PREFIX/lib/$ISAPART64/$tgt \
            || logerr "cp $tgt"
    done
    popd >/dev/null

    pushd $DESTDIR/$PREFIX >/dev/null

    # Unfortunately, libtool insists on adding $DEPROOT to the runtime
    # library path in each binary and library. Fixing this up post-install
    # for now, there may be a better way to do it.
    typeset rpath="$PREFIX/lib/$ISAPART64:$OPREFIX/lib/$ISAPART64"
    rpath+=":/usr/gcc/$GCCVER/lib/$ISAPART64"

    for f in bin/* sbin/* libexec/* lib/$ISAPART64/*; do
        [ -f $f -a ! -h $f ] || continue
        logmsg "--- fixing runpath in $f"
        logcmd elfedit -e "dyn:value -s RUNPATH $rpath" $f
        logcmd elfedit -e "dyn:value -s RPATH $rpath" $f
    done

    # The perl commands end up with a mangled library path as the cyrus
    # installer assumes that the default site_perl and vendor_perl directories
    # exist under the perl prefix, and they don't on OmniOS.
    for f in cyradm installsieve sieveshell; do
        logmsg "--- fixing perl paths in $f"
        logcmd sed -i "/Boilerplate.*fixsearchpath/,/^##/c\\
use lib '$PREFIX/lib/perl/$SPERLVER';
            " bin/$f
    done

    popd >/dev/null
}

download_source cyrus $PROG-imapd $VER
patch_source
run_autoreconf -fi
build -ctf
for f in cyrus.conf imapd.conf cyrus.xml cyrus-setup; do
    xform files/$f > $TMPDIR/$f
done
install_inetservices
install_smf -oocemethod ooce $PROG.xml cyrus-setup
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
