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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pam_radius
VER=3.0.0
PKG=ooce/security/pam_radius
SUMMARY="RADIUS PAM module"
DESC="PAM to RADIUS authentication module"

test_relver '>=' 151051 && set_clangver

set_builddir $PROG-release_${VER//./_}

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

NO_SONAME_EXPECTED=1

LDFLAGS[i386]+=" -lssp_ns"

save_variables CFLAGS LDFLAGS

pre_configure() {
    typeset arch=$1

    restore_variables CFLAGS LDFLAGS

    subsume_arch $arch CFLAGS
    subsume_arch $arch LDFLAGS

    CFLAGS+=" $CTF_CFLAGS"
    CFLAGS+=" -DCONF_FILE=\\\"/etc$PREFIX/$PROG/${PROG}_auth.conf\\\""
    LDFLAGS+=" -L${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]} -lsocket"
}

pre_install() {
    typeset arch=$1

    PAMDIR=$PREFIX/lib/${LIBDIRS[$arch]/lib/security}

    logcmd $MKDIR -p $DESTDIR$PAMDIR || logerr "mkdir failed"
    logcmd $MKDIR -p $DESTDIR/etc$PREFIX/$PROG || logerr "mkdir failed"

    logcmd $CP $TMPDIR/$BUILDDIR/${PROG}_auth.so $DESTDIR$PAMDIR \
        || logerr "copying PAM module failed"
    logcmd $CP $TMPDIR/$BUILDDIR/${PROG}_auth.conf $DESTDIR/etc$PREFIX/$PROG \
        || logerr "copying PAM config failed"

    # no install target
    false
}

init
download_source $PROG release_${VER//./_}
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
