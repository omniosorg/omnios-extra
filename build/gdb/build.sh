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

PROG=gdb
PKG=ooce/developer/gdb
VER=10.1
SUMMARY="$PROG - GNU Debugger"
DESC="The GNU debugger"

OPREFIX=$PREFIX
PREFIX+=/$PROG

RUN_DEPENDS_IPS+=" shell/bash"
# gdb needs gdb to build - the one from the previous release is fine
BUILD_DEPENDS_IPS+=" ooce/developer/gdb"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --with-x=no
    --with-curses
    --enable-plugins
    --enable-tui
    --without-auto-load-safe-path
    --with-system-zlib
    --with-python=$PYTHON
"

CPPFLAGS+=" -D_REENTRANT"

export PATH=$GNUBIN:$PATH

# Generate illumos data files describing system calls and structures
# found in core files.
function generate {

    # System call table
    logmsg "--- generating system call table"
    {
        cat << EOM
<?xml version="1.0"?>
<!DOCTYPE feature SYSTEM "gdb-syscalls.dtd">
<syscalls_info>
EOM
        $EGREP $'^#define\tSYS_.*[0-9]$' /usr/include/sys/syscall.h \
            | while read _ call num; do
                printf '  <syscall name="%s" number="%d"/>\n' \
                    ${call#SYS_} $num
        done

        echo "</syscalls_info>"
    } > $TMPDIR/syscalls.xml
    echo $TMPDIR/syscalls.xml
    for arch in i386 amd64; do
        logcmd cp $TMPDIR/syscalls.xml \
            $TMPDIR/$EXTRACTED_SRC/gdb/syscalls/$arch-illumos.xml \
            || logerr "Could not install $arch system call table"
    done

    # Offset includes
    logmsg "--- generating offset information"
    pushd $TMPDIR
    for bits in 32 64; do
        flags=CFLAGS$bits
        logcmd -p $GENOFFSETS -s $CTFSTABS -r $CTFCONVERT \
            $CW --primary gcc,$GCC,gnu --noecho -- \
            $GENOFFSETS_CFLAGS ${!flags} \
            < $SRCDIR/files/offsets.in > offsets$bits.h
    done
    {
        sed < offsets32.h 's/\t0x/_32&/'
        sed < offsets64.h 's/\t0x/_64&/'
        $EGREP $'define\tPR(FN|ARG)SZ' /usr/include/sys/old_procfs.h
    } | tee illumos-offsets.h > $EXTRACTED_SRC/bfd/illumos-offsets.h
    popd

    logmsg "--- building feature files"
    logcmd $MAKE -C $TMPDIR/$EXTRACTED_SRC/gdb/features \
        GDB=$OOCEBIN/gdb cfiles \
        || logerr "feature build failed"
}

save_function make_prog64 _make_prog64
make_prog64() {
    _make_prog64 "$@"
    # Since we patched the doc directory out of the main makefile, build
    # the man pages separately now.
    logcmd $MAKE -C gdb/doc man install-man1 DESTDIR=$DESTDIR \
        || logerr "man build"
}

init
download_source $PROG $PROG $VER
patch_source
generate
prep_build autoconf -oot
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
