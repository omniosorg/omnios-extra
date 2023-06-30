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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/build.sh

PROG=conditional-obsolete

PKG=ooce/obsolete/network/socat
test_relver '>=' 151031 && publish_manifest "" network-socat.p5t
PKG=ooce/obsolete/compress/lz4
test_relver '>=' 151035 && publish_manifest "" compress-lz4.p5t
PKG=ooce/obsolete/compress/zstd
test_relver '>=' 151035 && publish_manifest "" compress-zstd.p5t
PKG=ooce/obsolete/developer/clang-130
test_relver '>=' 151036 && publish_manifest "" developer-clang-130.p5t
PKG=ooce/obsolete/developer/llvm-130
test_relver '>=' 151036 && publish_manifest "" developer-llvm-130.p5t

exit 0

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
