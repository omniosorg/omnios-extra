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

if [ $RELVER -lt 151035 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="--disable-static"

addpath PKG_CONFIG_PATH $PREFIX/share/pkgconfig

LDFLAGS32+=" -R$PREFIX/lib"
LDFLAGS64+=" -R$PREFIX/lib/$ISAPART64"

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
