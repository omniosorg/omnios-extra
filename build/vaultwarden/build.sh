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

PROG=vaultwarden
VER=1.34.3
PKG=ooce/application/vaultwarden
SUMMARY="Bitwarden compatible server"
DESC="Unofficial Bitwarden compatible server written in Rust, formerly known "
DESC+="as bitwarden_rs"

DANIGARCIA=$GITHUB/dani-garcia
# https://github.com/dani-garcia/bw_web_builds/releases
WEBVAULTVER=2025.7.0
WEBVAULTSHA256=81ab0ab3ce3f3d25776e4d6ac11982e2a328d41a8cc992bc1fcd149c638f3eb7

set_arch 64

BASEDIR=$PREFIX/$PROG
CONFFILE=/etc$BASEDIR/env.template
WEBVAULTDIR=/var$BASEDIR/web-vault
EXECFILE=$PREFIX/bin/$PROG

BMI_EXPECTED=1

CARGO_ARGS="--features sqlite,mysql,postgresql"

BUILD_DEPENDS_IPS="
    ooce/developer/rust
    ooce/library/mariadb-${MARIASQLVER//./}
    ooce/library/postgresql-${PGSQLVER//./}
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DUSER=$PROG
    -DGROUP=$PROG
    -DPROG=$PROG
"

SKIP_LICENCES=bitwarden

pre_build() {
    typeset arch=$1

    export RUSTFLAGS+="
        -C link-arg=-L${SYSROOT[$arch]}$PREFIX/mariadb-$MARIASQLVER/${LIBDIRS[$arch]}
        -C link-arg=-L${SYSROOT[$arch]}$PREFIX/pgsql-$PGSQLVER/${LIBDIRS[$arch]}
        -C link-arg=-R$PREFIX/mariadb-$MARIASQLVER/${LIBDIRS[$arch]}
        -C link-arg=-R$PREFIX/pgsql-$PGSQLVER/${LIBDIRS[$arch]}
    "
}

post_install() {
    typeset arch=$1

    _destdir=$DESTDIR
    cross_arch $arch && _destdir+=.$arch

    local relative_conffile=${CONFFILE#/}
    local dest_confdir=$_destdir/${relative_conffile%/*}

    logmsg "-- copying sample config"
    logcmd $MKDIR -p "$dest_confdir" || logerr "mkdir failed"
    logcmd $CP $TMPDIR/$BUILDDIR/.env.template $_destdir/$relative_conffile \
        || logerr "copying configs failed"

    local prog_repo=bw_web_builds
    local prog=web-vault
    local relative_webvaultdir=${WEBVAULTDIR#/}
    local dest_webvaultdir=$_destdir/${relative_webvaultdir%/*}

    # We need to clone the original bitwarden web pieces to incorporate the
    # licences into the final package.
    BUILDDIR= clone_github_source bitwarden \
        "$GITHUB/bitwarden/web" v$WEBVAULTVER

    note -n "Pulling v$WEBVAULTVER prebuilt $prog"

    set_mirror "$DANIGARCIA/$prog_repo/releases/download"
    set_checksum sha256 $WEBVAULTSHA256

    BUILDDIR=$prog \
        download_source "v$WEBVAULTVER" bw_web_v$WEBVAULTVER

    logmsg "-- copying $prog"
    logcmd $MKDIR -p $_destdir/$relative_webvaultdir || logerr "mkdir failed"
    logcmd $RSYNC -a --delete $TMPDIR/$prog/ $_destdir/$relative_webvaultdir/ \
        || logerr "copying $prog failed"

    xform files/$PROG.xml > $TMPDIR/$PROG.xml
    DESTDIR=$_destdir install_smf ooce $PROG.xml
}

init
clone_github_source $PROG "$DANIGARCIA/$PROG" $VER
append_builddir $PROG
patch_source
prep_build
build_rust $CARGO_ARGS
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
