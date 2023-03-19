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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="--disable-static"

addpath PKG_CONFIG_PATH $PREFIX/share/pkgconfig

LDFLAGS[i386]+=" -R$PREFIX/lib -lssp_ns"
LDFLAGS[amd64]+=" -R$PREFIX/lib/amd64"

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
