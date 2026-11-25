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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=stalwart
VER=1.2.0
PKG=ooce/network/stalwart
SUMMARY="Stalwart mail and collaboration server"
DESC="Mail and collaboration server with JMAP, IMAP4, POP3, SMTP, "
DESC+="CalDAV, CardDAV and WebDAV support"

# Stalwart builds against its own fork of rust-rocksdb, which bundles
# RocksDB 11.8.1 as a submodule. That fork needs the patches in
# patches-rocksdb/ to build on illumos, so it is cloned next to the Stalwart
# source and used via a path override (patches/03-local-librocksdb-sys.patch).
# When updating Stalwart, set this to the librocksdb-sys commit recorded in
# Stalwart's Cargo.lock and re-base patches-rocksdb/.
RUSTROCKSDBREV=f6169ca36d74c15637f8c6396c34e82aa73d0d47

set_arch 64

BASEDIR=$PREFIX/$PROG
EXECFILE=$PREFIX/bin/$PROG

# Build only AGPL-licensed features. The default feature set includes
# 'enterprise', which pulls in code under the proprietary Stalwart
# Enterprise License.
CARGO_ARGS="--no-default-features --features rocks,keep,exchange"

BUILD_DEPENDS_IPS="
    ooce/developer/rust
    ooce/developer/clang-$DEFAULT_CLANG_VER
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DBASEDIR=${BASEDIR#/}
    -DEXECFILE=$EXECFILE
    -DUSER=$PROG
    -DGROUP=$PROG
    -DPROG=$PROG
"

pre_build() {
    # librocksdb-sys generates its bindings with bindgen, which needs libclang
    export LIBCLANG_PATH="$PREFIX/llvm-$DEFAULT_CLANG_VER/lib"
}

post_install() {
    typeset arch=$1

    _destdir=$DESTDIR
    cross_arch $arch && _destdir+=.$arch
}

init
clone_github_source $PROG "$GITHUB/stalwartlabs/$PROG" v$VER
# A full clone (depth 0) is needed to check out a specific commit
clone_github_source -submodules rust-rocksdb \
    "$GITHUB/stalwartlabs/rust-rocksdb" $RUSTROCKSDBREV "" 0
save_builddir
append_builddir rust-rocksdb
patch_source patches-rocksdb
restore_builddir
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
