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
#
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=minidlna
VER=1.2.1
VERHUMAN=$VER
PKG=ooce/multimedia/minidlna
SUMMARY="MiniDLNA"
DESC="DLNA/UPnP-AV media server"

set_arch 64

OPREFIX=$PREFIX
PREFIX+="/$PROG"

BUILD_DEPENDS_IPS="
    ooce/library/libjpeg-turbo
    ooce/library/libogg
    ooce/library/libvorbis
    ooce/library/libexif
    ooce/library/libid3tag
    ooce/multimedia/ffmpeg
    ooce/audio/flac
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --with-db-path=/var$PREFIX/cache
    --with-log-path=/var/log$PREFIX
    ac_cv_header_sys_inotify_h=no
    ac_cv_func_inotify_init=no
"

default_config() {
    logmsg "--- Copying default config file"
    logcmd mkdir -p $DESTDIR/etc$PREFIX
    logcmd cp $TMPDIR/$BUILDDIR/${PROG}.conf $DESTDIR/etc$PREFIX \
     || logerr "Failed to copy default config file"
}

CFLAGS+=" -D__OmniOS__ -D_XOPEN_SOURCE=500 -D__EXTENSIONS__ -I$OPREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64 -lsocket -lsendfile"

init
prep_build
download_source $PROG $PROG $VER
patch_source
build
default_config
install_smf application $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
