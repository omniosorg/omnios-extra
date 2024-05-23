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

PROG=tree-sitter-langs
VER=0.12.196
PKG=ooce/text/tree-sitter-langs
SUMMARY="$PROG"
DESC="Tree-sitter Language Bundle for Emacs"

set_arch 64
set_nodever

SKIP_SSP_CHECK=1
SKIP_BUILD_ERRCHK=1

# Some of the parsers have very large enums. Let's take what CTF data we can
# get.
CTF_FLAGS+=" -s"

NPM_LANG_LIST="arduino astro cpp commonlisp hlsl glsl toml typescript"
declare -gA NPM_LANGS; for npm in $NPM_LANG_LIST; do NPM_LANGS[$npm]=1; done

configure_arch() {
    logmsg "--- checking out submodules"
    logcmd $GIT submodule update --init --checkout --jobs $MJOBS \
        || logerr "Failed to check out submodules"

}

build_lang() {
    typeset lang=$1
    typeset dir=repos/${2:-$lang}

    typeset ROOT="$PWD"

    logmsg "---- building $lang"

    pushd $dir >/dev/null || logerr "Could not change into repos/$lang"

    typeset soname=${lang//_/-}.so
    typeset args="$CPPFLAGS -shared -fPIC -Wl,-h,$soname -o $ROOT/bin/$soname"

    # If we do not remove the JSON rust bindings and let them be re-generated,
    # the build fails due to a locale incompatibility.
    [ "$lang" == json ] && logcmd $RM -f bindings/rust/build.rs

    if [ -n "${NPM_LANGS[$lang]}" ]; then
        logcmd $NODEPATH/bin/npm set progress=false
        logcmd $NODEPATH/bin/npm install
    fi

    # A few builds fail; others terminate non-zero although the language
    # library built correctly. We don't check for build success but rather
    # check whether all libraries are present by comparing to a baseline
    # later on.
    if ! logcmd $OOCEBIN/tree-sitter generate; then
        logmsg -e "Generating $lang failed"
    elif [ -f src/scanner.cc ]; then
        logcmd $GXX $args $CXXFLAGS src/scanner.cc -xc src/parser.c
    elif [ -f src/scanner.c ]; then
        logcmd $GCC $args $CFLAGS src/scanner.c src/parser.c
    else
        logcmd $GCC $args $CFLAGS src/parser.c
    fi

    popd >/dev/null
}

make_arch() {
    typeset arch="$1"

    subsume_arch $arch CPPFLAGS CFLAGS CXXFLAGS
    CPPFLAGS+=" -Isrc"
    CXXFLAGS+=" -fno-exceptions"

    logmsg "--- building 64-bit ($((MJOBS)) jobs)"
    while read lang; do
        typeset dir=$lang
        case $lang in
            xml|csv|ocaml)      dir+="/$lang" ;;
            ocaml-interface)    dir+="/interface" ;;
        esac
        build_lang $lang $dir &
        parallelise $MJOBS
    done < <($GIT submodule foreach --quiet 'echo ${sm_path#*/}')
    wait

    build_lang dtd xml/dtd
}

make_install() {
    typeset arch=$1

    typeset destdir="$DESTDIR$PREFIX/${LIBDIRS[$arch]}"

    logcmd $MKDIR -p $destdir || logerr "mkdir failed"

    pushd bin >/dev/null || logerr "Could not change into bin/"
    for f in *.so; do
        logcmd $CP $f $destdir/libtree-sitter-$f || logerr "copying $f failed"
    done
    popd >/dev/null

    logmsg "--- comparing baseline"

    (cd $destdir; logcmd -p $LS -1) > $TMPDIR/baseline
    if ! logcmd $DIFF -u $SRCDIR/files/baseline $TMPDIR/baseline; then
        logmsg -e "Baseline mismatch"
        logmsg -n "The new baseline file is in $TMPDIR/baseline"
        logerr "Aborting build due to baseline mismatch"
    fi
}

init
clone_github_source $PROG "$GITHUB/emacs-tree-sitter/$PROG" $VER
append_builddir $PROG
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
