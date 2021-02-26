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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=munin
VER=2.0.67
PKG=ooce/application/munin
SUMMARY="munin"
DESC="A networked resource monitoring tool that can help "
DESC+="analyse resource trends."

[ $RELVER -lt 151033 ] && RUN_DEPENDS_IPS+=" runtime/perl-64"

set_arch 64

SKIP_LICENCES=GPLv2

# some perl modules require gnu-tar to unpack
# set PATH to default pgsql version as the mediated version
# might be changed by the user
export PATH="$PREFIX/pgsql-$PGSQLVER/bin:$GNUBIN:$PATH"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DUSER=munin -DGROUP=munin
    -DPKGROOT=$PROG
"

reset_configure_opts

# No configure
CONFIGURE_CMD="/usr/bin/true"

# munin does not build with parallel make
NO_PARALLEL_MAKE=1

get_deps() {
    deproot=$TMPDIR/_deproot
    logmsg "--- downloading cpanm"
    $CURL -s -L https://cpanmin.us | logcmd perl - -L $deproot -n Carton \
        || logerr "failed to download cpanm"

    for i in server node; do
        logmsg "--- downloading perl modules for $i"
        PERL_CPANM_HOME=$deproot PERL_CARTON_PATH=$deproot/$i \
            PERL5LIB=$deproot/lib/perl5 logcmd $deproot/bin/carton install \
            --cpanfile=$SRCDIR/files/cpanfile-$i \
            || logerr "failed to install perl modules for $i"
        logcmd rm -f $SRCDIR/files/cpanfile-$i.snapshot
        logcmd mkdir -p $DESTDIR/$i/$PREFIX || logerr "mkdir failed for $i"
        logcmd rsync -a $deproot/$i/lib/perl5/ $DESTDIR/$i/$PREFIX/lib/ \
            || logerr "copying perl modules failed for $i"
    done
}

# Some files are present in both node and server.
# Generate a list of those files so that we deliver them in node only.
find_dups() {
    logmsg "Generating list of duplicate files in the node and server" >/dev/stderr

    pushd $DESTDIR >/dev/null || logerr "pushd"
    for i in node server; do
        $FD . $i -H -tf -tl | cut -d/ -f2- | sort \
            > $TMPDIR/$i.files
    done
    comm -12 $TMPDIR/node.files $TMPDIR/server.files > $TMPDIR/dups.files
    popd >/dev/null
    wc -l < $TMPDIR/dups.files
}

fix_perllib() {
    path="$1"
    dir="$2"

    $RIPGREP -l --max-depth=1 '^#!.+perl' $dir | while read f; do
        sed -i "/^use  *strict/a\\
use lib qw($path);
" $f
    done
}

save_function make_install make_install_
make_install() {
    # install node
    MAKE_INSTALL_TARGET="install-common-prime install-node-prime "
    MAKE_INSTALL_TARGET+="install-plugins-prime"
    DESTDIR=$DESTDIR/node make_install_

    # install server
    MAKE_INSTALL_TARGET="install"
    DESTDIR=$DESTDIR/server make_install_

    # Remove files which are also shipped as part of node
    typeset -i num=`find_dups`
    logmsg "-- Pruning $num duplicates"
    pushd $DESTDIR/server >/dev/null || logerr "pushd"
    cat $TMPDIR/dups.files | xargs rm -f
    popd >/dev/null

    for d in bin sbin lib lib/plugins; do
        fix_perllib "$PREFIX/lib" $DESTDIR/node/$PREFIX/$d
        fix_perllib "$PREFIX/lib $OPREFIX/rrdtool/lib/perl/$SPERLVER" \
            $DESTDIR/server/$PREFIX/$d
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
get_deps
PERL5LIB=$DESTDIR/server/$PREFIX/lib build
strip_install

for i in node server; do
    PKG=ooce/application/munin-$i ##IGNORE##
    PKGE=`url_encode $PKG`
    SUMMARY="munin - $i"
    xform files/$PROG-$i.xml > $TMPDIR/$PROG-$i.xml
    if [ -f files/$PROG-$i ]; then
        DESTDIR=$DESTDIR/$i install_smf -oocemethod \
            ooce $PROG-$i.xml $PROG-$i
    else
        DESTDIR=$DESTDIR/$i install_smf ooce $PROG-$i.xml
    fi
    DESTDIR=$DESTDIR/$i make_package $i.mog
done

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
