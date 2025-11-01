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

PROG=fish
VER=4.3.3
PKG=ooce/shell/fish
SUMMARY="Fish is a smart and user-friendly command line shell"
DESC="friendly interactive shell"

SKIP_SSP_CHECK=1
SKIP_LICENCES=COPYING

BUILD_DEPENDS_IPS="
	ooce/developer/rust
	ooce/developer/cmake
	library/pcre2
	runtime/python-$PYTHONPKGVER
"

RUN_DEPENDS_IPS="
	library/pcre2
	runtime/python-$PYTHONPKGVER
"

XFORM_ARGS+=" -DPREFIX=${PREFIX#/}"

set_arch 64
set_clangver

CONFIGURE_OPTS+="
	-DCMAKE_BUILD_TYPE=Release
	-DCMAKE_INSTALL_PREFIX=$PREFIX
	-DCMAKE_VERBOSE_MAKEFILE=1
	-DCMAKE_INSTALL_SYSCONFDIR="/etc"
	-DSYS_PCRE2_INCLUDE_DIR="/usr/include/pcre"
	-DFISH_USE_SYSTEM_PCRE2=ON
	-DWITH_GETTEXT=ON
	-DWITH_DOCS=OFF
"

# use GNU msgfmt; otherwise the build fails
PATH="$GNUBIN:$PATH:$OOCEBIN"

crate_patch() {
    logmsg "Patching crates"
    logcmd $CARGO fetch --manifest-path $TMPDIR/$BUILDDIR/Cargo.toml \
        || logerr "Fetching crates failed"
    pushd $CARGO_HOME >/dev/null
    for patchfile in $SRCDIR/patches-crate/*.patch; do \
        gpatch --backup --version-control=numbered -p0 < $patchfile ; \
    done ;
    popd >/dev/null
}

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_PREFIX=$PREFIX
		-DCMAKE_VERBOSE_MAKEFILE=1
		-DCMAKE_INSTALL_SYSCONFDIR="/etc"
		-DSYS_PCRE2_INCLUDE_DIR="/usr/include/pcre"
		-DFISH_USE_SYSTEM_PCRE2=ON
		-DWITH_GETTEXT=ON
		-DBUILD_DOCS=OFF	
    "
}

init
download_source $PROG fish-$VER ""
patch_source
export CARGO_HOME=$TMPDIR/cargo_crates
mkdir -p $CARGO_HOME
crate_patch
prep_build cmake
build -noctf
#run_testsuite check
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
