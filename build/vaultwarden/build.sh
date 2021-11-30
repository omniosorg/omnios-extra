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

PROG=vaultwarden
VER=1.24.0
PKG=ooce/application/vaultwarden
SUMMARY="Bitwarden compatible server"
DESC="Unofficial Bitwarden compatible server written in Rust, formerly known "
DESC+="as bitwarden_rs"

DANIGARCIA=$GITHUB/dani-garcia
WEBVAULTVER=2.27.0

# The next vaultwarden version requires only the stable 1.25.0 rust version
# until then, use nightly.
RUST=rust-nightly-x86_64-unknown-illumos
RUSTVER=2022-01-23

set_arch 64

BASEDIR=$PREFIX/$PROG
CONFFILE=/etc$BASEDIR/env.template
WEBVAULTDIR=/var$BASEDIR/web-vault
EXECFILE=$PREFIX/bin/$PROG

BMI_EXPECTED=1
CARGO_ARGS="--features sqlite,mysql,postgresql"
BUILD_DEPENDS_IPS="
    database/sqlite-3
    ooce/library/mariadb-${MARIASQLVER//./}
    ooce/library/postgresql-${PGSQLVER//./}
"
export RUSTFLAGS="
    -C link-arg=-R$PREFIX/mariadb-$MARIASQLVER/lib/$ISAPART64
    -C link-arg=-R$PREFIX/pgsql-$PGSQLVER/lib/$ISAPART64
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

get_rust_nightly() {
    BUILDDIR=$RUST download_source -norecord rust/nightly/$RUSTVER $RUST

    logmsg "Installing rust nightly [$RUSTVER]"
    logcmd $TMPDIR/$RUST/install.sh \
        --prefix=$TMPDIR/_rust || logerr "installing rust"

    CARGO="$TMPDIR/_rust/bin/cargo"
    export PATH="$TMPDIR/_rust/bin:$PATH"
}

copy_sample_config() {
    local relative_conffile=${CONFFILE#/}
    local dest_confdir=$DESTDIR/${relative_conffile%/*}

    logmsg "-- copying sample config"
    logcmd mkdir -p "$dest_confdir" || logerr "mkdir failed"
    logcmd cp $TMPDIR/$BUILDDIR/.env.template $DESTDIR/$relative_conffile \
        || logerr "copying configs failed"
}

get_webvault() {
    local prog_repo=bw_web_builds
    local prog=web-vault
    local relative_webvaultdir=${WEBVAULTDIR#/}
    local dest_webvaultdir=$DESTDIR/${relative_webvaultdir%/*}

    # We need to clone the original bitwarden web pieces to incorporate the
    # licences into the final package.
    BUILDDIR= clone_github_source bitwarden \
        "$GITHUB/bitwarden/web" v$WEBVAULTVER

    note -n "Pulling v$WEBVAULTVER prebuilt $prog"

    set_mirror "$DANIGARCIA/$prog_repo/releases/download"
    set_checksum sha256 \
        af8cf8e608d507e44c64cd0813f79cd327feaede180f3e48a59133e4595049db

    BUILDDIR=$prog \
        download_source "v$WEBVAULTVER" bw_web_v$WEBVAULTVER

    logmsg "-- copying $prog"
    logcmd mkdir -p $DESTDIR/$relative_webvaultdir || logerr "mkdir failed"
    logcmd rsync -a $TMPDIR/$prog/ $DESTDIR/$relative_webvaultdir/ \
        || logerr "copying $prog failed"

}

init
get_rust_nightly
clone_github_source $PROG "$DANIGARCIA/$PROG" $VER
BUILDDIR+=/$PROG
patch_source
prep_build
build_rust $CARGO_ARGS
install_rust
strip_install
copy_sample_config
get_webvault
xform files/$PROG.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
