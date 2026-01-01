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

PROG=syslog-ng
VER=4.10.2
PKG=ooce/system/syslog-ng
SUMMARY="A powerful, highly configurable monitoring and logging daemon"
DESC="An enhanced log daemon, supporting a wide range of input and output methods: syslog, unstructured text, queueing, SQL & NoSQL."

SKIP_SSP_CHECK=1
SKIP_LICENCES=COPYING

BUILD_DEPENDS_IPS="
	ooce/developer/cmake
	developer/versioning/git
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
	-DCMAKE_VERBOSE_MAKEFILE=1
	-DENABLE_MANPAGES=ON
	-DBUILD_TESTING=OFF
	-DENABLE_AFSNMP=OFF
	-DENABLE_JAVA=OFF
	-DENABLE_PYTHON=OFF
	-DENABLE_PYTHON_MODULES=OFF
	-DCMAKE_INSTALL_PREFIX=$PREFIX
	-DCMAKE_INSTALL_SYSCONFDIR=/etc
"

pre_configure() {
	# this file is missing from the tarball. It contains only some string-coloring escape sequences
	# see here: https://github.com/syslog-ng/syslog-ng/blob/ef85a01611537079c068437f0ec54dc13a65113e/cmake/common_helpers.cmake
	# creating an empty file to make cmake happy
	touch "$TMPDIR/src/cmake/common_helpers.cmake"
	
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_VERBOSE_MAKEFILE=1
        -DENABLE_MANPAGES=ON
        -DBUILD_TESTING=OFF
        -DENABLE_AFSNMP=OFF
        -DENABLE_JAVA=OFF
        -DENABLE_PYTHON=OFF
        -DENABLE_PYTHON_MODULES=OFF
        -DCMAKE_INSTALL_PREFIX=$PREFIX
		-DCMAKE_INSTALL_SYSCONFDIR=/etc
    "
}

init
download_source $PROG syslog-ng-$VER ""
patch_source
prep_build cmake
build -noctf
#run_testsuite check
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
