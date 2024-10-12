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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

test_relver '>=' 151053 && set_clangver

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="--disable-static"

addpath PKG_CONFIG_PATH $PREFIX/share/pkgconfig

LDFLAGS[i386]+=" -Wl,-R$PREFIX/${LIBDIRS[i386]} -lssp_ns"
LDFLAGS[amd64]+=" -Wl,-R$PREFIX/${LIBDIRS[amd64]}"

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
