#! /usr/bin/bash
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

#
# Copyright 2017 OmniTI Computer Consulting, Inc. All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#

# Usage:
#
# sudo-bits KAYAK_CLOBBER IMG_DSET CHECKOUTDIR PREBUILT_ILLUMOS DESTDIR \
#   PKGURL VER OLDUSER BATCHMODE
#
# Basically, we pass everything on the command line to avoid environment
# scraping that sudo normally does.
#

KAYAK_CLOBBER="$1"
IMG_DSET="$2"
CHECKOUTDIR="$3"
PREBUILT_ILLUMOS="$4"
DESTDIR="$5"
export PKGURL="$6"
VER="$7"
OLDUSER="$8"
BATCHMODE="$9"

export ROOT_OK=yes

# Save build.log...
mv build.log /tmp/bl.$$

# Load support functions (which starts new build.log...)
. ../../lib/functions.sh

# Restore build.log
mv /tmp/bl.$$ build.log
chown $OLDUSER build.log

# Honour (and possibly set) the BATCH flag.
[ "$BATCHMODE" = 1 ] && BATCH=1

[ "$UID" != "0" ] && logerr "--- The sudo-bits script needs to be run as root."

[ "$PREBUILT_ILLUMOS" = "/dev/null" ] && PBI_STRING="" \
    || PBI_STRING="PREBUILT_ILLUMOS=$PREBUILT_ILLUMOS"

if [ -n "$KAYAK_CLOBBER" -a "$KAYAK_CLOBBER" != 0 ]; then
    logmsg "Clobbering $IMG_DSET"
    logcmd /sbin/zfs destroy -r $IMG_DSET
fi
zfs list -H $IMG_DSET 2>/dev/null || logcmd /sbin/zfs create $IMG_DSET

pushd $CHECKOUTDIR/kayak > /dev/null || logerr "Cannot change to src dir"
logmsg "Building miniroot"
logcmd gmake BUILDSEND=$IMG_DSET $PBI_STRING DESTDIR=$DESTDIR install-tftp \
    || logerr "miniroot build failed"

# So the user's build.sh can cleanup after itself.
chown -R $OLDUSER $DESTDIR

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
