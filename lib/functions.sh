#!/bin/bash
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
# Copyright (c) 2014 by Delphix. All rights reserved.
# Copyright 2015 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.
#

#############################################################################
# functions.sh
#############################################################################
# Helper functions for building packages that should be common to all build
# scripts
#############################################################################

# Set a basic path - it will be modified once config.sh is loaded
export PATH=/usr/bin:/usr/sbin:/usr/gnu/bin

[ -n "$BLIBDIR" ] || BLIBDIR=$(realpath ${BASH_SOURCE[0]%/*})
ROOTDIR=${BLIBDIR%/*}

. $BLIBDIR/config.sh
[ -f $BLIBDIR/site.sh ] && . $BLIBDIR/site.sh
$MKDIR -p $TMPDIR
BASE_TMPDIR=$TMPDIR

BASEPATH=/usr/ccs/bin:$USRBIN:/usr/sbin:$OOCEBIN:$GNUBIN:$SFWBIN
export PATH=$BASEPATH

#############################################################################
# Process command line options
#############################################################################
process_opts() {
    SCREENOUT=
    FLAVOR=
    CLIFLAVOR=
    BUILDARCH=
    set_arch "$DEFAULT_ARCH" default
    CLIBUILDARCH=
    BATCH=
    AUTOINSTALL=
    DEPVER=
    SKIP_PKGLINT=
    SKIP_HARDLINK=
    SKIP_PKG_DIFF=
    REBASE_PATCHES=
    SKIP_TESTSUITE=
    SKIP_CHECKSUM=
    EXTRACT_MODE=0
    MOG_TEST=
    while getopts "bcimM:Ppstf:ha:d:Llr:x" opt; do
        case $opt in
            a)
                set_arch "$OPTARG"
                CLIBUILDARCH="$OPTARG"
                cross_arch $CLIBUILDARCH && SKIP_TESTSUITE=1
                ;;
            b)
                BATCH=1 # Batch mode - exit on error
                SKIP_PKG_DIFF=1
                ;;
            c)
                USE_CCACHE=1
                ;;
            d)
                DEPVER=$OPTARG
                ;;
            f)
                FLAVOR="$OPTARG"
                CLIFLAVOR="$OPTARG" # Used to see if the script overrides
                ;;
            \?|h)
                show_synopsis; show_usage
                exit
                ;;
            i)
                AUTOINSTALL=1
                ;;
            l)
                SKIP_PKGLINT=1
                ;;
            L)
                SKIP_HARDLINK=1
                ;;
            m)
                MOG_TEST=1
                ;;
            M)
                logmsg -n "-- Will retrieve files from $OPTARG"
                set_mirror "$OPTARG"
                set_checksum none
                ;;
            P)
                REBASE_PATCHES=1
                ;;
            p)
                SCREENOUT=1
                ;;
            r)
                PKGSRVR=$OPTARG
                ;;
            s)
                SKIP_CHECKSUM=1
                ;;
            t)
                SKIP_TESTSUITE=1
                ;;
            x)
                (( EXTRACT_MODE++ ))
                ;;
        esac
    done
}

#############################################################################
# Show usage information
#############################################################################
show_synopsis() {
    $CAT << EOM
Usage: $0 [-blt] [-f FLAVOR] [-h] [-a i386|amd64|aarch64|32|64|x86] [-d DEPVER]
EOM
}

show_usage() {
    $CAT << EOM
  -a ARCH   : build 32/64 bit only, or both (default: both)
  -b        : batch mode (exit on errors without asking)
  -c        : use 'ccache' to speed up (re-)compilation
  -d DEPVER : specify an extra dependency version (no default)
  -f FLAVOR : build a specific package flavor
  -h        : print this help text
  -i        : autoinstall mode (install build deps)
  -l        : skip pkglint check
  -L        : skip hardlink target check
  -m        : re-generate final mog from local.mog (mog test mode)
  -M URL    : retrieve files from URL instead of OmniOS mirror
  -M /PATH  : retrieve files from (absolute) PATH instead of OmniOS mirror
  -p        : output all commands to the screen as well as log file
  -P        : re-base patches on latest source
  -r REPO   : specify the IPS repo to use
              (default: $PKGSRVR)
  -s        : skip checksum comparison
  -t        : skip test suite
  -x        : download and extract source only
  -xx       : as -x but also apply patches
EOM
}

print_config() {
    $CAT << EOM

BLIBDIR:                $BLIBDIR
ROOTDIR:                $ROOTDIR
TMPDIR:                 $TMPDIR
DTMPDIR:                $DTMPDIR

Mirror:                 $MIRROR
Publisher:              $PKGPUBLISHER
Production IPS Repo:    $IPS_REPO
Repository:             $PKGSRVR
Privilege Escalation:   $PFEXEC

EOM
}

#############################################################################
# Log output of a command to a file
#############################################################################
pipelog() {
    $TEE -a $LOGFILE 2>&1
}

logcmd() {
    typeset preserve_stdout=0
    [ "$1" = "-p" ] && shift && preserve_stdout=1
    echo Running: "$@" >> $LOGFILE
    if [ -z "$SCREENOUT" ]; then
        if [ "$preserve_stdout" = 0 ]; then
            "$@" >> $LOGFILE 2>&1
        else
            "$@"
        fi
    else
        if [ "$preserve_stdout" = 0 ]; then
            echo Running: "$@"
            "$@" | pipelog
            return ${PIPESTATUS[0]}
        else
            "$@"
        fi
    fi
}

c_highlight="`$TPUT setaf 2`"
c_error="`$TPUT setaf 1`"
c_note="`$TPUT setaf 6`"
c_reset="`$TPUT sgr0`"
logmsg() {
    typeset highlight=0
    [ "$1" = "-h" ] && shift && highlight=1
    [ "$1" = "-e" ] && shift && highlight=2
    [ "$1" = "-n" ] && shift && highlight=3

    echo "$logprefix$@" >> $LOGFILE
    case $highlight in
        1) echo "$c_highlight$logprefix$@$c_reset" ;;
        2) echo "$c_error$logprefix$@$c_reset" ;;
        3) echo "$c_note$logprefix$@$c_reset" ;;
        *) echo "$logprefix$@" ;;
    esac
}

logerr() {
    [ "$1" = "-b" ] && BATCH=1 && shift
    # Print an error message and ask the user if they wish to continue
    logmsg -e "$@" >> /dev/stderr
    if [ -z "$BATCH" ]; then
        ask_to_continue "An Error occurred in the build. "
    else
        exit 1
    fi
}

note() {
    typeset xarg=
    [ "$1" = "-h" ] && xarg=$1 && shift
    [ "$1" = "-e" ] && xarg=$1 && shift
    [ "$1" = "-n" ] && xarg=$1 && shift
    logmsg ""
    logmsg $xarg "***"
    logmsg $xarg "*** $@"
    logmsg $xarg "***"
}

ask_to_continue_() {
    MSG=$2
    STR=$3
    RE=$4
    # Ask the user if they want to continue or quit in the event of an error
    echo -n "${1}${MSG} ($STR) "
    read
    while [[ ! "$REPLY" =~ $RE ]]; do
        echo -n "${MSG} ($STR) "
        read
    done
}

function print_elapsed {
    typeset s=$1
    printf '%dh%dm%ds' $((s/3600)) $((s%3600/60)) $((s%60))
}

ask_to_continue() {
    ask_to_continue_ "${1}" "Do you wish to continue anyway?" "y/n" "[yYnN]"
    if [[ "$REPLY" == "n" || "$REPLY" == "N" ]]; then
        logmsg -e "===== Build aborted ====="
        exit 1
    fi
    logmsg "===== User elected to continue after prompt. ====="
}

ask_to_install() {
    ati_PKG=$1
    MSG=$2
    if [ -n "$AUTOINSTALL" ]; then
        logmsg "Auto-installing $ati_PKG..."
        logcmd $PFEXEC $PKGCLIENT install $ati_PKG || \
            logerr "pkg install $ati_PKG failed"
        return
    fi
    if [ -n "$BATCH" ]; then
        logmsg -e "===== Build aborted ====="
        exit 1
    fi
    ask_to_continue_ "$MSG " "Install/Abort/Skip?" "i/a/s" "[iIaAsS]"
    case $REPLY in
        i|I)
            logcmd $PFEXEC $PKGCLIENT install $ati_PKG \
                || logerr "pkg install failed"
            ;;
        s|S)
            # Skip
            ;;
        *)
            logmsg -e "===== Build aborted ====="
            exit 1
    esac
}

ask_to_pkglint() {
    ask_to_continue_ "" "Do you want to run pkglint?" \
        "y/n" "[yYnN]"
    [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]
}

ask_to_testsuite() {
    ask_to_continue_ "" "Do you want to run the test-suite?" \
        "y/n" "[yYnN]"
    [[ "$REPLY" == "y" || "$REPLY" == "Y" ]]
}

#############################################################################
# Copyright string
#############################################################################

copyright_string() {
    echo "Copyright (c) 2017-`date +%Y`" \
        "OmniOS Community Edition (OmniOSce) Association."
}

#############################################################################
# URL encoding for package names, at least
#############################################################################

# This isn't real URL encoding, just a couple of common substitutions
url_encode() {
    [ $# -lt 1 ] && logerr "Not enough arguments to url_encode()"
    local encoded="$1";
    echo $* | $SED -e '
        s!/!%2F!g
        s!+!%2B!g
        s/%../_/g
    '
}

#############################################################################
# ASCII character to number
#############################################################################

# Turn the letter component of the version into a number for IPS versioning
ord26() {
    local ASCII=$(printf '%d' "'$1")
    ASCII=$((ASCII - 64))
    [[ $ASCII -gt 32 ]] && ASCII=$((ASCII - 32))
    echo $ASCII
}

set_coredir() {
    # Change the core pattern so that core files contain all available
    # information and are stored centrally in the provided directory
    coreadm -P all -p $1/core.%f.%t.%p
}

#############################################################################
# Utilities
#############################################################################

min_rel() {
    typeset ver="${1:-ver}"

    if test_relver '<' $ver; then
        logmsg "--- $PKG is not built for r$RELVER"
        exit 0
    fi
}

max_rel() {
    typeset ver="${1:-ver}"

    if test_relver '>' $ver; then
        logmsg "--- $PKG is not built for r$RELVER"
        exit 0
    fi
}

parallelise() {
    local num="${1:-1}"
    while [ "`jobs -rp | wc -l`" -ge "$num" ]; do
        sleep 1
    done
}

in_list() {
    typeset list=${1:?list}
    typeset key=${2:?key}
    typeset v

    for v in $list; do
        [ "$v" = "$key" ] && return 0
    done
    return 1
}

valid_arch() {
    in_list "$ARCH_LIST" "$1"
}

cross_arch() {
    in_list "$CROSS_ARCH" "$1"
}

# This is a crude function to determine if the current build is purely a cross
# arch one. It should not be used widely and we need something better if we're
# going to support multi-arch builds in a single run (which is still up for
# debate).
is_cross() {
    [[ ! $BUILDARCH = *amd64* ]]
}

#############################################################################
# Set up tools area
#############################################################################

init_tools() {
    BASEPATH=$TMPDIR/tools:$BASEPATH
    [ -d $TMPDIR/tools ] && return
    logcmd $MKDIR -p $TMPDIR/tools || logerr "mkdir tools failed"
    # Disable any commands that should not be used for the build
    for cmd in cc CC; do
        logcmd $LN -sf /bin/false $TMPDIR/tools/$cmd || logerr "ln $cmd failed"
    done
}

#############################################################################
# Compiler version
#############################################################################

SSPFLAGS=
set_ssp() {
    case "$1" in
        none)   SSPFLAGS=; SKIP_SSP_CHECK=1 ;;
        strong) SSPFLAGS="-fstack-protector-strong" ;;
        basic)  SSPFLAGS="-fstack-protector" ;;
        all)    SSPFLAGS="-fstack-protector-all" ;;
        *)      logerr "Unknown stack protector variant ($1)" ;;
    esac
    typeset LCFLAGS=`echo ${CFLAGS[0]} | $SED 's/-fstack-protector[^ ]*//'`
    typeset LCXXFLAGS=`echo ${CXXFLAGS[0]} | $SED 's/-fstack-protector[^ ]*//'`
    CFLAGS[0]="$LCFLAGS $SSPFLAGS"
    CXXFLAGS[0]="$LCFLAGS $SSPFLAGS"
    [ -z "$2" ] && logmsg "-- Set stack protection to '$1'"
}

set_gccver() {
    GCCVER="$1"
    [ -z "$2" ] && logmsg "-- Setting GCC version to $GCCVER"
    GCCPATH="/opt/gcc-$GCCVER"
    GCC="$GCCPATH/bin/gcc"
    GXX="$GCCPATH/bin/g++"
    CC=$GCC
    CXX=$GXX
    [ -x "$GCC" ] || logerr "Unknown compiler version $GCCVER"
    PATH="$GCCPATH/bin:$BASEPATH"
    if [ -n "$USE_CCACHE" ]; then
        [ -x $CCACHE_PATH/ccache ] || logerr "Ccache is not installed"
        PATH="$CCACHE_PATH:$PATH"
    fi
    export GCC GXX GCCVER GCCPATH PATH

    CFLAGS[0]="${FCFLAGS[_]} ${FCFLAGS[$GCCVER]}"
    CXXFLAGS[0]="${FCFLAGS[_]} ${FCFLAGS[$GCCVER]}"
    CTF_CFLAGS="${CTFCFLAGS[_]} ${CTFCFLAGS[$GCCVER]}"

    set_ssp strong $2
}

set_crossgcc() {
    typeset arch=${1:?arch}

    logmsg "-- Setting GCC for cross compilation to $arch"
    GCCPATH="$CROSSTOOLS/$arch"
    GCC="$GCCPATH/bin/gcc"
    GXX="$GCCPATH/bin/g++"
    CC=$GCC
    CXX=$GXX
    [ -x "$GCC" ] || logerr "Unknown compiler version $GCCVER"
    PATH="$GCCPATH/bin:$BASEPATH"
    if [ -n "$USE_CCACHE" ]; then
        [ -x $CCACHE_PATH/ccache ] || logerr "Ccache is not installed"
        PATH="$CCACHE_PATH:$PATH"
    fi
    [[ ${CFLAGS[$arch]} =~ *--sysroot* ]] \
        || CFLAGS[$arch]+=" --sysroot=${SYSROOT[$arch]}"
    [[ ${CXXFLAGS[$arch]} =~ *--sysroot* ]] \
        || CXXFLAGS[$arch]+=" --sysroot=${SYSROOT[$arch]}"

    PKG_CONFIG_SYSROOT_DIR=${SYSROOT[$arch]}
    PKG_CONFIG_LIBDIR="${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]}/pkgconfig"
    PKG_CONFIG_LIBDIR+=":${SYSROOT[$arch]}$OOCEOPT/${LIBDIRS[$arch]}/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR PKG_CONFIG_LIBDIR

    [[ $CONFIGURE_CMD =~ $CMAKE* ]] && CONFIGURE_OPTS[$arch]+="
        -DCMAKE_FIND_ROOT_PATH=${SYSROOT[$arch]}
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
    "
}

set_clangver() {
    CLANGVER="${1:-$DEFAULT_CLANG_VER}"
    [ -z "$2" ] && logmsg "-- Setting clang version to $CLANGVER"
    CLANGPATH="/opt/ooce/llvm-$CLANGVER"
    CC="$CLANGPATH/bin/clang"
    CXX="$CLANGPATH/bin/clang++"
    [ -x "$CC" ] || logerr "Unknown compiler version $CLANGVER"
    PATH="$CLANGPATH/bin:$BASEPATH"
    if [ -n "$USE_CCACHE" ]; then
        [ -x $CCACHE_PATH/ccache ] || logerr "Ccache is not installed"
        PATH="$CCACHE_PATH:$PATH"
    fi
    export CC CXX CLANGVER CLANGPATH PATH

    CFLAGS[0]="${FCFLAGS[_]}"
    CXXFLAGS[0]="${FCFLAGS[_]}"
    CTF_CFLAGS="${CTFCFLAGS[_]} ${CTFCFLAGS[$DEFAULT_GCC_VER]}"

    set_ssp strong $2
}

#############################################################################
# OpenSSL version
#############################################################################

set_opensslver() {
    [ -d /usr/ssl-$1 ] || logerr "Unknown OpenSSL version $1"
    FORCE_OPENSSL_VERSION=$1
    OPENSSLVER=$1
    OPENSSLPATH=/usr/ssl-$1
    PATH=$OPENSSLPATH/bin:$PATH
    logmsg "-- Setting OpenSSL version to $FORCE_OPENSSL_VERSION"
}

#############################################################################
# Go version
#############################################################################

set_gover() {
    GOVER="${1:-$DEFAULT_GO_VER}"
    logmsg "-- Setting Go version to $GOVER"
    GO_PATH="/opt/ooce/go-$GOVER"
    GO=$GO_PATH/bin/go
    PATH="$GO_PATH/bin:$PATH"
    GOROOT_BOOTSTRAP="$GO_PATH"
    GOOS=illumos
    GOARCH=amd64

    [ "$TMPDIR" = "$BASE_TMPDIR" ] \
        && GOCACHE="$BASE_TMPDIR/$PROG-$VER/go-build" \
        || GOCACHE="$TMPDIR/go-build"

    # go binaries contain BMI instructions even when built on an older CPU
    BMI_EXPECTED=1
    # skip rtime check for go builds
    SKIP_RTIME_CHECK=1
    # skip SSP check for go builds
    SKIP_SSP_CHECK=1
    export PATH GOROOT_BOOTSTRAP GOOS GOARCH GOCACHE

    BUILD_DEPENDS_IPS+=" ooce/developer/go-${GOVER//./}"
}

#############################################################################
# node.js version
#############################################################################

set_nodever() {
    NODEVER="${1:-$DEFAULT_NODE_VER}"
    logmsg "-- Setting node.js version to $NODEVER"
    NODEPATH="/opt/ooce/node-$NODEVER"
    PATH="$NODEPATH/bin:$PATH"
    export PATH

    BUILD_DEPENDS_IPS+=" ooce/runtime/node-$NODEVER"
}

#############################################################################
# Ruby version
#############################################################################

set_rubyver() {
    RUBYVER="${1:-$DEFAULT_RUBY_VER}"
    logmsg "-- Setting Ruby version to $RUBYVER"
    RUBYPATH="/opt/ooce/ruby-$RUBYVER"
    PATH="$RUBYPATH/bin:$PATH"
    export PATH

    BUILD_DEPENDS_IPS+=" ooce/runtime/ruby-${RUBYVER//./}"
}

#############################################################################
# zig version
#############################################################################

set_zigver() {
    ZIGVER="${1:-$DEFAULT_ZIG_VER}"
    logmsg "-- Setting zig version to $ZIGVER"
    ZIGPATH="/opt/ooce/zig-$ZIGVER"
    PATH="$ZIGPATH/bin:$PATH"
    export PATH

    [ -x "$ZIGPATH/bin/zig" ] || logerr "Unknown zig version $ZIGVER"

    BUILD_DEPENDS_IPS+=" ooce/developer/zig-${ZIGVER//./}"
}

#############################################################################
# Default configure options.
#############################################################################

reset_configure_opts() {
    typeset arch

    # If it's the global default (/usr), we want sysconfdir to be /etc
    # otherwise put it under PREFIX
    [ $PREFIX = "/usr" ] && SYSCONFDIR=/etc || SYSCONFDIR=/etc$PREFIX

    for arch in $ARCH_LIST; do
        CONFIGURE_OPTS[$arch]="
            --prefix=$PREFIX
            --sysconfdir=$SYSCONFDIR
            --includedir=$PREFIX/include
        "
    done

    if [ -n "$FORGO_ISAEXEC" ]; then
        for arch in $ARCH_LIST; do
            case $arch in
                amd64)
                    CONFIGURE_OPTS[$arch]+="
                        --bindir=$PREFIX/bin
                        --sbindir=$PREFIX/sbin
                        --libdir=$PREFIX/lib/$arch
                        --libexecdir=$PREFIX/libexec/$arch
                    "
                    ;;
                *)
                    CONFIGURE_OPTS[$arch]+="
                        --bindir=$PREFIX/bin
                        --sbindir=$PREFIX/sbin
                        --libdir=$PREFIX/lib
                        --libexecdir=$PREFIX/libexec
                    "
                    ;;
            esac
        done
    else
        for arch in $ARCH_LIST; do
            case $arch in
                i386)
                    CONFIGURE_OPTS[$arch]+="
                        --bindir=$PREFIX/bin/$arch
                        --sbindir=$PREFIX/sbin/$arch
                        --libdir=$PREFIX/lib
                        --libexecdir=$PREFIX/libexec
                    "
                    ;;
                amd64)
                    CONFIGURE_OPTS[$arch]+="
                        --bindir=$PREFIX/bin/$arch
                        --sbindir=$PREFIX/sbin/$arch
                        --libdir=$PREFIX/lib/$arch
                        --libexecdir=$PREFIX/libexec/$arch
                    "
                    ;;
                aarch64)
                    CONFIGURE_OPTS[$arch]+="
                        --bindir=$PREFIX/bin
                        --sbindir=$PREFIX/sbin
                        --libdir=$PREFIX/lib
                        --libexecdir=$PREFIX/libexec
                    "
                    ;;
            esac
        done
    fi

    # Cross compiler options - this will evolve
    for arch in $CROSS_ARCH; do
        CONFIGURE_OPTS[$arch]+="
            --host=${TRIPLETS[$arch]}
        "
    done
}

clear_archflags() {
    flatten_variables CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
}

set_standard() {
    typeset -i xcurses=0
    while [[ "$1" = -* ]]; do
        case $1 in
            -xcurses)  xcurses=1 ;;
        esac
        shift
    done
    typeset st="$1"
    typeset var="${2:-CPPFLAGS}"
    [ -n "${STANDARDS[$st]}" ] || logerr "Unknown standard $st"
    declare -n _var=$var
    _var[0]+=" ${STANDARDS[$st]}"

    # When selecting XPG4v2 or later, we must also use the X/Open curses
    # library, as long as we were not called with "-nocurses"
    ((xcurses)) || return
    case $st in
        XPG4v2|XPG5|XPG6)
            typeset x=/usr/xpg4
            _var[0]="-I$x/include ${_var[0]}"
            LDFLAGS[i386]="-L$x/lib -R$x/lib ${LDFLAGS[i386]}"
            LDFLAGS[amd64]="-L$x/lib/amd64 -R$x/lib/amd64 ${LDFLAGS[amd64]}"
            ;;
    esac
}

forgo_isaexec() {
    FORGO_ISAEXEC=1
    reset_configure_opts
}

set_arch() {
    typeset arch="${1:?arch}"

    case "$BUILDARCH:$arch" in
        *:all)          BUILDARCH="$ARCH_LIST" ;;
        *:aarch64)      ;&
        *:amd64)        ;&
        *:i386)         BUILDARCH=$arch ;;
        *:"i386 amd64") ;&
        *:x86)          BUILDARCH="i386 amd64" ;;
        *i386*:64)      BUILDARCH=${BUILDARCH/i386/} ;;
        *amd64*:32)     BUILDARCH=${BUILDARCH/amd64/} ;;
        aarch64:64)     ;;
        aarch64:32)     logerr "32-bit is not valid for $BUILDARCH" ;;
        *)              logerr "Unknown architecture ($BUILDARCH:$arch)" ;;
    esac
    [ -z "$2" ] && forgo_isaexec
    for a in $BUILDARCH; do
        valid_arch $a || logerr "$a is not a supported architecture."
    done
    trim_variable BUILDARCH
}

check_mediators() {
    OPENSSLVER=`$PKGCLIENT mediator -H openssl 2>/dev/null | $NAWK '{print $3}'`
    if [ "$OPENSSLVER" != "$EXP_OPENSSLVER" ]; then
        if [ -n "$OPENSSL_TEST" ]; then
            logmsg -h "--- OpenSSL version $OPENSSLVER but OPENSSL_TEST is set"
        else
            logerr "--- OpenSSL $OPENSSLVER should not be used for build"
        fi
    fi
    OPENSSLPATH=/usr/ssl-$OPENSSLVER

    typeset _med=`$PKGCLIENT mediator -H python3 2>/dev/null | \
        $NAWK '{print $3}'`
    if [ -n "$_med" -a "$_med" != "$PYTHON3VER" ]; then
        logerr "--- Python3 mediator is set incorrectly ($_med)"
    fi
}

basic_build_requirements() {
    local needed=""
    [ -x $GCCPATH/bin/gcc ] || needed+=" developer/gcc$GCCVER"
    [ -x /usr/bin/ar ] || needed+=" developer/object-file"
    [ -x /usr/bin/ld ] || needed+=" developer/linker"
    [ -x /usr/bin/gmake ] || needed+=" developer/build/gnu-make"
    [ -f /usr/include/sys/types.h ] || needed+=" system/header"
    [ -f /usr/include/math.h ] || needed+=" system/library/math"
    if [ -n "$needed" ]; then
        logmsg "You appear to be missing some basic build requirements."
        logmsg "To fix this run:"
        logmsg " "
        logmsg "  $PFEXEC pkg install$needed"
        if [ -n "$BATCH" ]; then
            logmsg -e "===== Build aborted ====="
            exit 1
        fi
        echo
        for i in "$needed"; do
           ask_to_install $i "--- Build-time dependency $i not found"
        done
    fi
    check_mediators
}

#############################################################################
# Libtool -nostdlib hacking
# libtool doesn't put -nostdlib in the shared archive creation command
# we need it sometimes.
#############################################################################

libtool_nostdlib() {
    FILE="$1"
    EXTRAS="$2"
    logcmd perl -pi -e \
        's#(\$CC.*\$compiler_flags)#$1 -nostdlib '"$EXTRAS"'#g;' $FILE \
        || logerr "--- Patching libtool:$FILE for -nostdlib support failed"
}

#############################################################################
# Initialisation function
#############################################################################

init_repo() {
    typeset repo=${1:-$PKGSRVR}

    if [[ "$repo" == file:/* ]]; then
        typeset rpath="`echo $repo | $SED 's^file:/*^/^'`"
        if [ ! -f "$rpath/pkg5.repository" ]; then
            logmsg "-- Initialising local repo at $rpath"
            $PKGREPO create $rpath || logerr "Could not create local repo"
            $PKGREPO add-publisher -s $rpath $PKGPUBLISHER || \
                logerr "Could not set publisher on local repo"
        fi
    fi
}

typeset -A REPOS SYSROOT
init_sysroot() {
    typeset arch=${1?arch}
    typeset repo=${2?repo}

    [ "${REPOS[$arch]}" = $repo ] && return

    [ -d $CROSSTOOLS/$arch ] || logerr "$CROSSTOOLS/$arch not found"

    init_repo $repo

    typeset sysroot=$BASE_TMPDIR/sysroot.$arch
    if [ ! -d $sysroot ]; then
        tmpsysroot=$sysroot.$$

        logmsg "-- Creating $arch sysroot"
        logcmd $PKGCLIENT image-create --zone \
            --publisher $PKGPUBLISHER=$repo \
            --variant variant.arch=$arch \
            --facet doc.man=false \
            $tmpsysroot || logerr "Could not initialise $arch sysroot"
        logcmd $PKGCLIENT -R $tmpsysroot \
            set-property flush-content-cache-on-success True
        logmsg "--- Seeding initial $arch sysroot"
        case $arch in
            aarch64)
                logcmd $PKGCLIENT -R $tmpsysroot set-publisher \
                    -g ${BRAICH_REPO} $PKGPUBLISHER
                logcmd $PKGCLIENT -R $tmpsysroot set-publisher \
                    -g ${BRAICH_REPO} omnios
                logcmd -p $PKGCLIENT -R $tmpsysroot install '*'
                logcmd cp /etc/zones/SUNWdefault.xml $tmpsysroot/etc/zones/
                ;;
            *)
                logcmd $RSYNC -a $CROSSTOOLS/$arch/sysroot/ $tmpsysroot \
                    || logerr "Could not sync initial sysroot"
                ;;
        esac
        if [ -d $sysroot ]; then
            logcmd rm -rf $tmpsysroot
        else
            logcmd mv $tmpsysroot $sysroot
        fi
    else
        logcmd $PKGCLIENT -R $sysroot install '*'
    fi

    REPOS[$arch]=$repo
    SYSROOT[$arch]=$sysroot
}

update_sysroot() {
    typeset arch

    for arch in ${!SYSROOT[@]}; do
        logmsg "--- updating sysroot for $arch"
        logcmd $PKGCLIENT -R ${SYSROOT[$arch]} install '*'
        # Exit status 4 means "nothing to do", so we accept that as success.
        (($? == 0 || $? == 4)) || logerr "--- sysroot update failed"
    done
}

init_repos() {
    init_repo $PKGSRVR
    $PKGREPO get -s $PKGSRVR > /dev/null 2>&1 || \
        logerr "The PKGSRVR ($PKGSRVR) isn't available. All is doomed."

    for arch in $BUILDARCH; do
        if cross_arch $arch; then
                [[ $PKGSRVR == file:/* ]] \
                    || logerr "Can only build $arch to a file based repo."
                init_sysroot $arch ${PKGSRVR%%/}.$arch
                DESTDIRS+=" $DESTDIR.$arch"
        fi
    done
}

github_latest() {
    logmsg "-- Retrieving latest release version from github"

    [[ $MIRROR = $GITHUB/* ]] \
        || logerr "Cannot use github latest without github mirror"

    local repoprog=`echo $MIRROR | cut -d/ -f4-5`
    local ep=$GITHUBAPI/repos/$repoprog/releases

    local filter="map(select (.draft == false)"
    if [ "$VER" != github-latest-prerelease ]; then
        filter+=" | select (.prerelease == false)"
    fi
    filter+=") | first | .tag_name"

    local tag=`$CURL -s $ep | $JQ -r "$filter"`
    [ -n "$tag" -a "$tag" != "null" ] \
        || logerr "--- Could not retrieve latest version from github"

    VER="${tag#v}"
    logmsg "--- Github release $tag, set VER=$VER"
}

init() {
    # Ensure key variables are set
    for var in PKG SUMMARY DESC; do
        declare -n _var=$var
        [ -n "$_var" ] || logerr "$var may not be empty."
    done

    # Print out current settings
    logmsg "Package name: $PKG"

    # Selected flavor
    if [ -z "$FLAVOR" ]; then
        logmsg "Selected flavor: None (use -f to specify a flavor)"
    else
        logmsg "Selected Flavor: $FLAVOR"
    fi
    if [ -n "$CLIFLAVOR" -a "$CLIFLAVOR" != "$FLAVOR" ]; then
        logmsg "NOTICE - The flavor was overridden by the build script."
        logmsg "The flavor specified on the command line was: $CLIFLAVOR"
    fi

    # Build arch
    logmsg "Selected build arch: $BUILDARCH"
    if [ -n "$CLIBUILDARCH" -a "$CLIBUILDARCH" != "$BUILDARCH" ]; then
        logmsg "NOTICE - The build arch was overridden by the build script."
        logmsg "The build arch specified on the command line was: $CLIBUILDARCH"
    fi

    # Extra dependency version
    if [ -z "$DEPVER" ]; then
        logmsg "Extra dependency: None (use -d to specify a version)"
    else
        logmsg "Extra dependency: $DEPVER"
    fi

    [[ "$VER" = github-latest* ]] && github_latest

    # Blank out the source code location
    _ARC_SOURCE=

    # BUILDDIR can be used to manually specify what directory the program is
    # built in (i.e. what the tarball extracts to). This defaults to the name
    # and version of the program, which works in most cases.
    [ -z "$BUILDDIR" ] && BUILDDIR=$PROG-$VER
    # Preserve the original BUILDDIR since this can be changed for an
    # out-of-tree build
    EXTRACTED_SRC=$BUILDDIR

    # Build each package in a sub-directory of the temporary area.
    # In addition to keeping everything related to a package together,
    # this also prevents problems with packages which have non-unique archive
    # names (1.2.3.tar.gz) or non-unique prog names.
    [ -n "$PROG" ] || logerr "\$PROG is not defined for this package."
    [ "$TMPDIR" = "$BASE_TMPDIR" ] && TMPDIR="$BASE_TMPDIR/$PROG-$VER"
    [ "$DTMPDIR" = "$BASE_TMPDIR" ] && DTMPDIR="$TMPDIR"

    # Update the core file directory
    set_coredir $TMPDIR

    # We might need to encode some special chars
    PKGE=$(url_encode $PKG)
    # For DESTDIR the '%' can cause problems for some install scripts
    PKGD=${PKGE//%/_}
    DESTDIR=$TMPDIR/${PKGD}_pkg
    DESTDIRS=$DESTDIR

    P5M_FINAL=$TMPDIR/$PKGE.p5m
    P5M_GEN=$P5M_FINAL.gen
    P5M_MOG=$P5M_FINAL.mog
    P5M_DEPGEN=$P5M_FINAL.dep

    if [ -n "$MOG_TEST" ]; then
        DONT_REMOVE_INSTALL_DIR=1
        SKIP_TESTSUITE=1
        if [ ! -r $P5M_GEN ]; then
            note -e "mog test - no previous mog file found, full build."
            MOG_TEST=
        else
            logmsg -n "mog test - found previous mog file, skipping build."
            SKIP_DOWNLOAD=1
            SKIP_PATCH_SOURCE=1
            SKIP_BUILD=1
        fi
    fi

    if ((EXTRACT_MODE == 0)); then
        init_repos
        verify_depends
    fi

    if [ -n "$FORCE_OPENSSL_VERSION" ]; then
        CFLAGS[0]="-I/usr/ssl-$FORCE_OPENSSL_VERSION/include ${CFLAGS[0]}"
        LDFLAGS[i386]="-L/usr/ssl-$FORCE_OPENSSL_VERSION/lib ${LDFLAGS[i386]}"
        LDFLAGS[amd64]="-L/usr/ssl-$FORCE_OPENSSL_VERSION/lib/amd64 "
        LDFLAGS[amd64]+="${LDFLAGS[amd64]}"
    fi

    # Create symbolic links to build area
    logcmd $MKDIR -p $TMPDIR
    [ -h $SRCDIR/tmp ] && $RM -f $SRCDIR/tmp
    logcmd $LN -sf $TMPDIR $SRCDIR/tmp
    [ -h $TMPDIR/src ] && $RM -f $TMPDIR/src
    logcmd $LN -sf $BUILDDIR $TMPDIR/src
}

set_builddir() {
    BUILDDIR="$1"
    EXTRACTED_SRC="$1"
}

append_builddir() {
    BUILDDIR+="/$1"
    EXTRACTED_SRC+="/$1"
}

save_builddir() {
    save_variable BUILDDIR $*
    save_variable EXTRACTED_SRC $*
}

restore_builddir() {
    restore_variable BUILDDIR $*
    restore_variable EXTRACTED_SRC $*
}

set_patchdir() {
    PATCHDIR="$1"
}

#############################################################################
# Verify any dependencies
#############################################################################

verify_depends() {
    logmsg "Verifying dependencies"
    # Support old-style runtime deps
    if [ -n "$DEPENDS_IPS" -a -n "$RUN_DEPENDS_IPS" ]; then
        # Either old way or new, not both.
        logerr "DEPENDS_IPS is deprecated. Please list all runtime dependencies in RUN_DEPENDS_IPS."
    elif [ -n "$DEPENDS_IPS" -a -z "$RUN_DEPENDS_IPS" ]; then
        RUN_DEPENDS_IPS=$DEPENDS_IPS
    fi
    # If only DEPENDS_IPS is used, assume the deps are build-time as well
    if [ -z "$BUILD_DEPENDS_IPS" -a -n "$DEPENDS_IPS" ]; then
        BUILD_DEPENDS_IPS=$DEPENDS_IPS
    fi
    for i in $BUILD_DEPENDS_IPS; do
        logmsg "-- Checking for build dependency $i"
        # Trim indicators to get the true name (see make_package for details)
        case ${i:0:1} in
            \=|\?)
                i=${i:1}
                ;;
            \-)
                # If it's an exclude, we should error if it's installed rather
                # than missing
                i=${i:1}
                logcmd $PKGCLIENT info -q $i \
                    && logerr "--- $i should not be installed during build."
                continue
                ;;
        esac
        logcmd $PKGCLIENT info -q $i \
            || ask_to_install "$i" "--- Build-time dependency $i not found"
    done
}

#############################################################################
# People that need these should call them explicitly
#############################################################################

run_inbuild() {
    logmsg "Running $*"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd "$@" || logerr "Failed to run $*"
    popd > /dev/null
}

run_autoheader() { run_inbuild autoheader "$@"; }
run_autoreconf() { run_inbuild autoreconf "$@"; }
run_autoconf() { run_inbuild autoconf "$@"; }
run_automake() { run_inbuild automake "$@"; }
run_aclocal() { run_inbuild aclocal "$@"; }

#############################################################################
# Stuff that needs to be done/set before we start building
#############################################################################

prep_build() {
    typeset style=${1:-autoconf}; shift

    for flag in "$@"; do
        case $flag in
            -oot)
                OUT_OF_TREE_BUILD=1
                ;;
            -keep)
                DONT_REMOVE_INSTALL_DIR=1
                ;;
            -autoreconf)
                [ $style = autoconf ] \
                    || logerr "-autoreconf is only valid for autoconf builds"
                RUN_AUTORECONF=1
                ;;
            -*)
                logerr "Unknown prep_build flag - $flag"
                ;;
        esac
    done

    logmsg "Preparing for $style build"

    # Generate timestamps
    typeset now=`TZ=UTC $DATE +%s`
    typeset TS_SRC_EPOCH=$((now - 60))
    typeset TS_OBJ_EPOCH=$((now - 30))
    typeset TS_FMT="%Y%m%dT%H%M%SZ"
    typeset TS_SRC=`$DATE -r $TS_SRC_EPOCH +$TS_FMT`
    typeset TS_OBJ=`$DATE -r $TS_OBJ_EPOCH +$TS_FMT`

    # Python is patched to use the value of this variable as the timestamp that
    # it embeds in .pyc files. We need to make sure that this embedded
    # timestamp matches the timestamp that the packaging system will apply to
    # the corresponding source .py file.
    export FORCE_PYC_TIMESTAMP=$TS_SRC_EPOCH

    # These tokens are used by rules in lib/mog/global-transforms.mog to
    # automatically apply timestamp attributes to python modules and their
    # compiled form. They can also be used by other packages in their local.mog
    SYS_XFORM_ARGS+=" -DTS_SRC=$TS_SRC -DTS_OBJ=$TS_OBJ"

    logmsg "--- Creating temporary installation directory"

    if [ -z "$DONT_REMOVE_INSTALL_DIR" ]; then
        for dir in $DESTDIRS; do
            logcmd $CHMOD -R u+w $dir >/dev/null 2>&1
            logcmd $RM -rf $dir || \
                logerr "Failed to remove old install directory $dir"
            logcmd $MKDIR -p $dir || \
                logerr "Failed to create install directory $dir"
            done
    fi

    logcmd $RM -f "$TMPDIR/frag.mog"

    [ -n "$OUT_OF_TREE_BUILD" ] \
        && CONFIGURE_CMD=$TMPDIR/$BUILDDIR/$CONFIGURE_CMD

    local _cmakeopts=
    case "$style" in
        autoconf)
            CONFIGURE_OPTS[0]+="
                --disable-silent-rules
                --disable-maintainer-mode
            "
            ;;
        autoconf-like)
            ;;
        cmake+ninja)
            _cmakeopts="-GNinja"
            MAKE=$NINJA
            TESTSUITE_MAKE=$MAKE
            MAKE_TESTSUITE_ARGS=
            ;& # fallthrough
        cmake)
            OUT_OF_TREE_BUILD=1
            MULTI_BUILD=1
            CONFIGURE_CMD="$CMAKE $_cmakeopts $TMPDIR/$BUILDDIR"
            ;;
        gyp+ninja)
            MAKE=$NINJA
            TESTSUITE_MAKE=$MAKE
            MAKE_TESTSUITE_ARGS=
            CONFIGURE_CMD="$GYP"
            ;;
        meson)
            OUT_OF_TREE_BUILD=1
            MULTI_BUILD=1
            MAKE=$NINJA
            TESTSUITE_MAKE=$MAKE
            MAKE_TESTSUITE_ARGS=
            CONFIGURE_CMD="/usr/lib/python$PYTHONVER/bin/meson setup"
            CONFIGURE_CMD+=" $TMPDIR/$BUILDDIR"
            PATH=$OOCEBIN:$PATH
            ;;
    esac

    if [ -n "$OUT_OF_TREE_BUILD" ]; then
        logmsg "-- Setting up for out-of-tree build"
        BUILDDIR+=-build
        [ -d $TMPDIR/$BUILDDIR ] && logcmd $RM -rf $TMPDIR/$BUILDDIR
        logcmd $MKDIR -p $TMPDIR/$BUILDDIR
    fi

    # Create symbolic links to build area
    [ -h $TMPDIR/build ] && $RM -f $TMPDIR/build
    logcmd $LN -sf $BUILDDIR $TMPDIR/build
    # ... and to DESTDIR
    for dir in $DESTDIRS; do
        if [[ ${dir##*/} = *.* ]]; then
            tgt=pkg.${dir##*.}
        else
            tgt=pkg
        fi
        [ -h $TMPDIR/$tgt ] && $RM -f $TMPDIR/$tgt
        logcmd $LN -sf ${dir##*/} $TMPDIR/$tgt
    done
}

#############################################################################
# Applies patches contained in $PATCHDIR (default patches/)
#############################################################################

check_for_patches() {
    local patchdir="$1"; shift
    local reason="$1"; shift

    logmsg "Checking for patches in $patchdir/ ($reason)"

    if [ ! -d "$SRCDIR/$patchdir" ]; then
        logmsg "--- No patches directory found"
        return 1
    fi
    if [ ! -f "$SRCDIR/$patchdir/series" ]; then
        logmsg "--- No series file (list of patches) found"
        return 1
    fi
    return 0
}

patch_file() {
    local patchdir="${1:?patchdir}"; shift
    local filename="${1:?filename}"; shift

    if [ ! -f $SRCDIR/$patchdir/$filename ]; then
        logmsg "--- Patch file $filename not found; skipping patch"
        return
    fi

    # Note - if --strip is specified more than once, then the last one takes
    # precedence, so we can specify --strip at the beginning to set the default.
    if ! logcmd $PATCH --batch --forward --strip=1 "$@" \
        < $SRCDIR/$patchdir/$filename; then
        logerr "--- Patch $filename failed"
    else
        logmsg "--- Applied patch $filename"
    fi
}

apply_patches() {
    local patchdir="${1:-$PATCHDIR}"
    local series="${2:-series}"

    if ! check_for_patches $patchdir "in order to apply them"; then
        logmsg "--- Not applying any patches"
        return
    fi

    logmsg "Applying patches"
    pushd $TMPDIR/$EXTRACTED_SRC > /dev/null
    exec 3<"$SRCDIR/$patchdir/$series" || logerr "Could not open patch series"
    while read LINE <&3; do
        [[ $LINE = \#* ]] && continue
        # Split Line into filename+args
        patch_file $patchdir $LINE
    done
    exec 3<&-
    popd > /dev/null
}

rebase_patches() {
    local patchdir="${1:-$PATCHDIR}"
    local series="${2:-series}"

    if ! check_for_patches $patchdir "in order to re-base them"; then
        logmsg -e "--- No patches to re-base"
        return
    fi

    logmsg "-- Re-basing patches"

    local xsrcdir=$TMPDIR/$EXTRACTED_SRC
    local root=${xsrcdir%/*}
    local dir=${xsrcdir##*/}

    pushd $root > /dev/null || logerr "chdir $root failed"
    logmsg "Archiving unpatched $dir"
    logcmd $RSYNC -ac --delete $dir{,.unpatched}/ || logerr "rsync $dir failed"

    # Read the series file for patch filenames
    # Use a separate file handle so that logerr() can be used in the loop
    exec 3<"$SRCDIR/$patchdir/$series" || logerr "Could not open patch series"
    while read LINE <&3; do
        [[ $LINE = \#* ]] && continue

        local patchfile="$SRCDIR/$patchdir/${LINE%% *}"
        [ -f $patchfile ] || continue

        logcmd $RSYNC -ac --delete $dir{,~}/ || logerr "rsync $dir~ failed"
        ( cd $dir && patch_file $patchdir $LINE )
        logcmd $MV $patchfile{,~} || logerr "mv $patchfile{,~}"
        # Extract the original patch header text
        $SED -n '
            /^---/q
            /^diff -/q
            p
            ' < $patchfile~ > $patchfile
        $GDIFF -wpruN --no-dereference --exclude='*.orig' $dir{~,} >> $patchfile
        local stat=$?
        if ((stat != 1)); then
            logcmd $MV $patchfile{~,}
            logerr "Could not generate new patch ($stat)"
        else
            logcmd $RM -f $patchfile~
            # Normalise the header lines so that they do not change with each
            # run.
            $SED -i '
                    /^diff -wpruN/,/^\+\+\+ / {
                        s% [^ ~/]*\(~*\)/% a\1/%g
                        s%[0-9][0-9][0-9][0-9]-[0-9].*%1970-01-01 00:00:00%
                    }
                ' $patchfile
        fi
    done
    exec 3<&-

    logmsg "Restoring unpatched $dir"
    logcmd $RSYNC -ac --delete $dir{.unpatched,}/ || logerr "rsync $dir failed"
    popd > /dev/null

    # Now the patches have been re-based, -pX is no longer required.
    $SED -i 's/ -p.*//' "$SRCDIR/$patchdir/$series"
}

patch_source() {
    [ -n "$SKIP_PATCH_SOURCE" ] && return
    [ -n "$REBASE_PATCHES" ] && rebase_patches "$@"
    apply_patches "$@"
    hook post_patch "$TMPDIR/$EXTRACTED_SRC"
    [ -z "$*" -a $EXTRACT_MODE -ge 1 ] && exit
    [ -n "$GOPATH" ] && logcmd go clean -cache
}

#############################################################################
# Attempt to download the given resource to the current directory.
#############################################################################
# Parameters
#   $1 - resource to get
#
get_resource() {
    typeset RESOURCE="$1"

    if [ -n "$MIRRORCACHE" -a -f "$MIRRORCACHE/$RESOURCE" ]; then
        logcmd $CP $MIRRORCACHE/$RESOURCE . && return
    fi

    case $MIRROR in
        /*)  logcmd $CP $MIRROR/$RESOURCE . ;;
        *)  $WGET -a $LOGFILE $MIRROR/$RESOURCE ;;
    esac
    typeset -i stat=$?

    if ((stat == 0)) && [ -n "$MIRRORCACHE" ]; then
        logcmd $MKDIR -p $MIRRORCACHE/${RESOURCE%/*}
        logcmd $CP ${RESOURCE##*/} $MIRRORCACHE/${RESOURCE%/*}
    fi

    return $stat
}

set_checksum() {
    typeset alg="$1"
    typeset sum="$2"

    if [ "$alg" = "none" ]; then
        SKIP_CHECKSUM=1
        return
    fi

    $DIGEST -l | $EGREP -s "^$alg$" || logerr "Unknown checksum algorithm $alg"

    CHECKSUM_VALUE="$alg:$sum"
}

verify_checksum() {
    typeset found=0

    logmsg "Verifying checksum of downloaded file."

    if [[ "$CHECKSUM_VALUE" = *:* ]]; then
        alg=${CHECKSUM_VALUE%:*}
        sum=${CHECKSUM_VALUE#*:}
        found=1
    else
        for alg in sha512 sha384 sha256; do
            [ -f "$FILENAME.$alg" ] || get_resource $DLDIR/$FILENAME.$alg
            [ -f "$FILENAME.$alg" ] || continue

            sum=`$NAWK '{print $1}' "$FILENAME.$alg"`
            found=1
            break
        done
    fi

    if [ $found -eq 1 ]; then
        typeset filesum=`$DIGEST -a $alg $FILENAME`
        if [ "$sum" = "$filesum" ]; then
            logmsg "Checksum verified using $alg"
        else
            logerr "Checksum of downloaded file does not match."
        fi
    else
        logerr "Could not find checksum for download"
    fi
}

#############################################################################
# Download source tarball if needed and extract it
#############################################################################
# Parameters
#   $1 - directory name on the server
#   $2 - program name
#   $3 - program version
#   $4 - target directory
#   $5 - passed to extract_archive
#
# E.g.
#       download_source myprog myprog 1.2.3 will try:
#       http://mirrors.omnios.org/myprog/myprog-1.2.3.tar.gz
download_source() {
    [ -n "$SKIP_DOWNLOAD" ] && return

    typeset -i record_arc=1
    typeset -i dependency=0
    typeset -i nodir=0
    while [[ $1 = -* ]]; do
        case $1 in
            -norecord)      record_arc=0 ;;
            -dependency)    dependency=1 ;;
            -nodir)         nodir=1 ;;
            *)              logerr "Unknown download_source option, $1" ;;
        esac
        shift
    done

    local DLDIR="$1"; shift
    local PROG="$1"; shift
    local VER="$1"; shift
    local TARGETDIR="$1"; shift
    local EXTRACTARGS="$@"
    local FILENAME

    local ARCHIVEPREFIX="$PROG"
    [ -n "$VER" ] && ARCHIVEPREFIX+="-$VER"
    [ -z "$TARGETDIR" ] && TARGETDIR="$TMPDIR"

    # Create TARGETDIR if it doesn't exist
    if [ ! -d "$TARGETDIR" ]; then
        logmsg "Creating target directory $TARGETDIR"
        logcmd $MKDIR -p $TARGETDIR
    fi

    pushd $TARGETDIR >/dev/null

    logmsg "Checking for source directory"
    if [ -d "$BUILDDIR" ]; then
        logmsg "--- Source directory found, removing"
        logcmd $RM -rf "$BUILDDIR" || logerr "Failed to remove source directory"
    else
        logmsg "--- Source directory not found"
    fi

    logmsg "Checking for $PROG source archive"
    find_archive $ARCHIVEPREFIX FILENAME
    if [ -z "$FILENAME" ]; then
        logmsg "--- Archive not found."
        logmsg "Downloading archive"
        for ext in $ARCHIVE_TYPES; do
            get_resource $DLDIR/$ARCHIVEPREFIX.$ext && break
        done
        find_archive $ARCHIVEPREFIX FILENAME
        [ -z "$FILENAME" ] && logerr "Unable to find downloaded file."
        logmsg "--- Downloaded $FILENAME"
    else
        logmsg "--- Found $FILENAME"
    fi
    ((record_arc)) && \
        _ARC_SOURCE+="${_ARC_SOURCE:+ }$SRCMIRROR/$DLDIR/$FILENAME"

    # Fetch and verify the archive checksum
    [ -z "$SKIP_CHECKSUM" ] && verify_checksum

    # Extract the archive
    logmsg "Extracting archive: $FILENAME"
    if ((nodir)); then
        mkdir $BUILDDIR || logerr "Failed to mkdir $BUILDDIR"
        pushd $BUILDDIR
    else
        pushd $TARGETDIR >/dev/null
    fi
    logcmd extract_archive $TARGETDIR/$FILENAME $EXTRACTARGS \
        || logerr "--- Unable to extract archive."
    popd >/dev/null

    # Make sure the archive actually extracted some source where we expect
    if [ ! -d "$BUILDDIR" ]; then
        logerr "--- Extracted source is not in the expected location" \
            " ($BUILDDIR)"
    fi

    CLEAN_SOURCE=1

    popd >/dev/null

    ((EXTRACT_MODE == 1 && dependency == 0)) && exit
}

# Finds an existing archive and stores its value in a variable whose name
#   is passed as a second parameter
# Example: find_archive myprog-1.2.3 FILENAME
#   Stores myprog-1.2.3.tar.gz in $FILENAME
find_archive() {
    local base="$1"
    local var="$2"
    local ext
    for ext in $ARCHIVE_TYPES; do
        [ -f "$base.$ext" ] || continue
        eval "$var=\"$base.$ext\""
        break
    done
}

# Extracts various types of archive
extract_archive() {
    local file="$1"; shift
    case $file in
        *.tar.zst)          $ZSTD -dc $file | $TAR -xvf - $* ;;
        *.tar.xz)           $XZCAT $file | $TAR -xvf - $* ;;
        *.tar.bz2)          $BUNZIP2 -dc $file | $TAR -xvf - $* ;;
        *.tar.lz)           $LZIP -dc $file | $TAR -xvf - $* ;;
        *.tar.gz|*.tgz)     $GZIP -dc $file | $TAR -xvf - $* ;;
        *.7z)               $SEVENZ x $file $* ;;
        *.zip)              $UNZIP $file $* ;;
        *.tar)              $TAR -xvf $file $* ;;
        # May as well try tar. It's GNU tar which does a fair job at detecting
        # the compression format.
        *)                  $TAR -xvf $file $* ;;
    esac
}

set_mirror() {
    MIRROR="$@"
    SRCMIRROR="$@"
}

#############################################################################
# Export source from github or local clone
#############################################################################

clone_github_source() {
    typeset -i dependency=0
    [ "$1" = "-dependency" ] && { dependency=1; shift; }

    typeset prog="$1"
    typeset src="$2"
    typeset branch="$3"
    typeset local="$4"
    typeset depth="${5:-1}"
    typeset fresh=0

    logmsg "$prog -> $TMPDIR/$BUILDDIR/$prog"
    [ -d $TMPDIR/$BUILDDIR ] || logcmd $MKDIR -p $TMPDIR/$BUILDDIR
    pushd $TMPDIR/$BUILDDIR > /dev/null

    if [ -n "$local" -a -d "$local" ]; then
        logmsg "-- syncing $prog from local clone"
        logcmd $RSYNC -ar $local/ $prog/ || logerr "rsync failed."
        logcmd $GIT -C $prog clean -fdx
        fresh=1
    elif [ ! -d $prog ]; then
        logcmd $GIT clone --no-single-branch --depth $depth $src $prog \
            || logerr "clone failed"
        fresh=1
    else
        logmsg "Using existing checkout"
    fi
    if [ -n "$branch" ]; then
        if ! logcmd $GIT -C $prog checkout $branch; then
            typeset _branch=$branch
            branch="`$GIT -C $prog rev-parse --abbrev-ref HEAD`"
            logmsg "No $_branch branch, using $branch."
        fi
    fi
    if [ "$fresh" -eq 0 ]; then
        if [ -n "$branch" ]; then
            logcmd $GIT -C $prog reset --hard $branch \
                || logerr "failed to reset branch"
            logcmd $GIT -C $prog pull --rebase origin $branch \
                || logerr "failed to pull"
        fi
        logcmd $GIT -C $prog clean -fdx
    fi

    $GIT -C $prog --no-pager show --shortstat

    _ARC_SOURCE+="${_ARC_SOURCE:+ }$src/tree/$branch"

    ((EXTRACT_MODE == 1 && dependency == 0)) && exit

    popd > /dev/null
}

#############################################################################
# Get go source from github
#############################################################################

clone_go_source() {
    typeset prog="$1"
    typeset src="$2"
    typeset branch="$3"
    typeset deps="${4-_deps}"

    clone_github_source -dependency $prog "$GITHUB/$src/$prog" $branch

    set_builddir "$BUILDDIR/$prog"

    pushd $TMPDIR/$BUILDDIR > /dev/null

    [ -z "$GOPATH" ] && GOPATH="$TMPDIR/$BUILDDIR/$deps"
    export GOPATH

    logmsg "Getting go dependencies"
    logcmd go get -d ./... || logerr "failed to get dependencies"

    logmsg "Fixing permissions on dependencies"
    logcmd $CHMOD -R u+w $GOPATH

    ((EXTRACT_MODE == 1)) && exit

    popd > /dev/null
}

#############################################################################
# Make the package
#############################################################################

run_pkglint() {
    typeset repo="$1"
    typeset mf="$2"

    typeset _repo=
    if [ ! -f $BASE_TMPDIR/lint/pkglintrc ]; then
        logcmd $MKDIR $BASE_TMPDIR/lint
        (
            $CAT << EOM
[pkglint]
use_progress_tracker = True
log_level = INFO
do_pub_checks = True
pkglint.exclude = pkg.lint.opensolaris pkg.lint.pkglint_manifest.PkgManifestChecker.naming
version.pattern = *,5.11-0.
pkglint001.5.report-linted = True

EOM
            echo "pkglint.action005.1.missing-deps = \\c"
            for pkg in `$NAWK '
                $3 == "" {
                    printf("pkg:/%s ", $2)
                }' $ROOTDIR/doc/baseline`; do
                echo "$pkg \\c"
            done
            echo
        ) > $BASE_TMPDIR/lint/pkglintrc
        _repo="-r $repo -r $IPS_REPO -r $OB_IPS_REPO"
    fi
    echo $c_note
    logcmd -p $PKGLINT -f $BASE_TMPDIR/lint/pkglintrc \
        -c $BASE_TMPDIR/lint/cache $mf $_repo \
        || logerr "----- pkglint failed"
    echo $c_reset
}

pkgmeta() {
    typeset key="$1"
    typeset val="$2"

    [[ $key = info.source-url* && ! $val = *://* ]] \
        && val="$SRCMIRROR/$val"
    echo set name=$key value=\"$val\"
}

# Start building a partial manifest
#   manifest_start <filename>
manifest_start() {
    PARTMF="$1"
    SEEDMF=$TMPDIR/manifest.seed
    :>$PARTMF
    generate_manifest $SEEDMF
}

# Add a directory, and the files directly underneath, to a partial manifest.
# Optional arguments indicate sub-directories to recurse one level into.
#   manifest_add_dir <directory> [subdir]...
manifest_add_dir() {
    typeset dir=${1#/}; shift
    logmsg "---- Adding dir '$dir'"
    (
        $RIPGREP "^dir.* path=$dir(\$|\\s)" $SEEDMF
        $RIPGREP "^(file|link|hardlink).* path=$dir/[^/]+(\$|\\s)" $SEEDMF
    ) >> $PARTMF
    for d in "$@"; do
        manifest_add_dir "$dir/$d"
    done
}

# Add a file/link/hardlink to a partial manifest.
#   manifest_add <directory> <pattern> [pattern]...
manifest_add() {
    typeset dir=${1#/}; shift

    for f in "$@"; do
        $RIPGREP "^(file|link|hardlink).* path=$dir/$f(\$|\\s)" $SEEDMF
    done >> $PARTMF
}

# Finalise a partial manifest.
# Takes care of adding any necessary 'dir' actions to support files which
# have been added and sorts the result, removing duplicate lines. Only
# directories under one of the provided prefixes are included
#   manifest_finalise <manifest> <prefix> [prefix]...
manifest_finalise() {
    typeset mf=${1:?mf}; shift
    typeset tf=`$MKTEMP`

    logmsg "-- Finalising ${mf##*/}"

    logcmd $CP $mf $tf || logerr "cp $mf $tf"

    typeset prefix
    for prefix in "$@"; do
        prefix=${prefix#/}
        logmsg "--- determining implicit directories for $prefix"
        $RIPGREP "^dir.* path=$prefix(\$|\\s)" $SEEDMF >> $tf
        $RIPGREP "(file|link|hardlink).* path=$prefix/" $mf \
            | $SED "
                s^.*path=$prefix/^^
                s^  *target=.*$^^
                s^/[^/]*$^^
        " | $SORT -u | while read dir; do
            logmsg "---- $dir"
            while :; do
                $RIPGREP "^dir.* path=$prefix/$dir(\$|\\s)" $SEEDMF >> $tf
                [[ $dir = */* ]] || break
                dir=`dirname $dir`
            done
        done
    done
    $SORT -u < $tf > $mf
    logcmd $RM -f $tf
}

# Create a manifest file containing all of the lines that are not present
# in the manifests given.
#   manifest_uniq <new manifest> <old manifest> [old manifest]...
manifest_uniq() {
    typeset dst="$1"; shift

    typeset tf=`$MKTEMP`
    typeset mftmp=`$MKTEMP`
    typeset seedtmp=`$MKTEMP`
    $SORT -u < $SEEDMF > $seedtmp

    for mf in "$@"; do
        $SORT -u < $mf > $mftmp
        logcmd -p $COMM -13 $mftmp $seedtmp > $tf
        logcmd $MV $tf $seedtmp
    done
    logcmd $MV $seedtmp $dst
    logcmd $RM -f $tf $mftmp
}

generate_manifest() {
    typeset outf="$1"

    [ -n "$DESTDIR" -a -d "$DESTDIR" ] || logerr "DESTDIR does not exist"

    check_symlinks "$DESTDIR"
    if [ -z "$BATCH" ]; then
        [ -z "$SKIP_RTIME_CHECK" ] && check_rtime
        [ -z "$SKIP_SSP_CHECK" ] && check_ssp
        check_soname
    fi
    check_bmi
    logmsg "--- Generating package manifest from $DESTDIR"
    typeset GENERATE_ARGS=
    if [ -n "$HARDLINK_TARGETS" ]; then
        for f in $HARDLINK_TARGETS; do
            GENERATE_ARGS+="--target $f "
        done
    fi
    logcmd -p $PKGSEND generate $GENERATE_ARGS $DESTDIR > $outf.raw \
        || logerr "---- Failed to generate manifest"
    # `pkgsend generate` will produce a manifest based on the files it
    # finds under $DESTDIR. It will set the ownership and group in generated
    # lines to root:bin, but will copy the mode attribute from the file it
    # finds. The modes of files in this directory do generally accurately
    # reflect executability, but other bits may be set depending on how the
    # temporary directory is set up. For example, in a shared build workspace
    # there could be extended ACLs to maintain writeability by the owning
    # group, or the sticky group attribute may be set on directories.
    # Rather than implicitly trusting the mode that is found, we normalise it
    # to something more generic.
    sed  -E '
        # Strip off any special attributes such as setuid or sticky group
        s/\<mode=0[[:digit:]]+([[:digit:]]{3})\>/mode=0\1/
        # Reduce group/other permissions
        s/\<mode=0([75])[[:digit:]]{2}\>/mode=0\155/
        s/\<mode=0([64])[[:digit:]]{2}\>/mode=0\144/
        # Convert unexpected modes to something reasonable
        s/\<mode=02[[:digit:]]{2}\>/mode=0644/
        s/\<mode=0[13][[:digit:]]{2}\>/mode=0755/
    ' < $outf.raw > $outf || logerr "---- Failed cleaning manifest permissions"
}

convert_version() {
    declare -n var=$1
    local _var=$var

    if [[ $var =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T* ]]; then
        ## Convert ISO-formatted time
        var=${var%T*}
        var=${var//-/.}
    elif [[ $var = *[a-z] ]]; then
        ## Convert single trailing alpha character
        var="${var:0: -1}.`ord26 ${var: -1}`"
    elif [[ $var = *p[0-9] ]]; then
        ## Convert trailing pX
        var=${var//p/.}
    elif [[ $var = *.pl[0-9]* ]]; then
        ## Convert trailing plX
        var=${var//pl/}
    elif [[ $var = *-P[0-9] ]]; then
        # Convert trailing -P (as used by ISC bind)
        var=${var//-P/.}
    fi

    ## Strip leading zeros in version components.
    var=`echo $var | $SED -e 's/\.0*\([0-9]\)/.\1/g;'`

    [ "$var" = "$_var" ] || logmsg "--- Converted version '$_var' -> '$var'"
}

build_archmog() {
    typeset arch=$1

    typeset x="-DARCH=$arch -D${arch}_ONLY="
    typeset a
    for a in $NATIVE_ARCH $CROSS_ARCH; do
        [ $arch = $a ] && continue
        x+=" -D${a}_ONLY=#"
    done
    echo "$x"
}

make_package() {
    logmsg "-- building package $PKG"

    typeset -a cross=
    typeset -i native=0

    for arch in $BUILDARCH; do
        if cross_arch $arch; then
            cross+=($arch)
        else
            ((native++))
        fi
    done

    if ((native)); then
        logmsg "--- packaging native arch"
        hook pre_package $NATIVE_ARCH
        XFORM_ARGS+=" `build_archmog $NATIVE_ARCH`" make_package_impl "$@"
        hook pre_package $NATIVE_ARCH
    fi
    for carch in ${cross[*]}; do
        logmsg "--- packaging $c"
        hook pre_package $carch
        DESTDIR+=.$carch \
            PKGSRVR=${REPOS[$carch]} \
            PKG_IMAGE=${SYSROOT[$carch]} \
            XFORM_ARGS+=" `build_archmog $carch`" \
            make_package_impl "$@"
        hook post_package $carch
    done
}

manifest_mode_map() {
    typeset src="$1"

    $PKGFMT -u < $src | $AWK '
        /^file|^dir/ {
            delete map
            split($0, a)
            for (el in a) {
                if (split(a[el], b, "=") == 2)
                    map[b[1]] = b[2]
            }
            if ("path" in map && "mode" in map)
                printf("%4s %6d %s|\n", $1, map["mode"], map["path"])
        }
    '
}

make_package_impl() {
    PKGE=`url_encode $PKG`

    typeset seed_manifest=
    typeset -i legacy=0
    while [[ "$1" = -* ]]; do
        case "$1" in
            -seed)  [ -n "$2" -a -f "$2" ] \
                        || logerr "Seed manifest '$2' not found"
                    seed_manifest=$2; shift
                    ;;
            -legacy) legacy=1 ;;
            *)      logerr "Unknown option to make_package - $1" ;;
        esac
        shift
    done

    [ -z "$LOCAL_MOG_FILE" -a -f $SRCDIR/local.mog ] && LOCAL_MOG_FILE=local.mog
    typeset EXTRA_MOG_FILE="$1"
    typeset FINAL_MOG_FILE="$2"
    typeset FRAG_MOG_FILE=
    [[ -n "$LOCAL_MOG_FILE" && ! "$LOCAL_MOG_FILE" = /* ]] \
        && LOCAL_MOG_FILE="$SRCDIR/$LOCAL_MOG_FILE"
    [[ -n "$EXTRA_MOG_FILE" && ! "$EXTRA_MOG_FILE" = /* ]] \
        && EXTRA_MOG_FILE="$SRCDIR/$EXTRA_MOG_FILE"
    [[ -n "$FINAL_MOG_FILE" && ! "$FINAL_MOG_FILE" = /* ]] \
        && FINAL_MOG_FILE="$SRCDIR/$FINAL_MOG_FILE"
    [ -s "$TMPDIR/frag.mog" ] && FRAG_MOG_FILE=$TMPDIR/frag.mog

    case $FLAVOR in
        ""|default) FLAVORSTR="" ;;
        *) FLAVORSTR="$FLAVOR-" ;;
    esac
    typeset DESCSTR="$DESC"
    [ -n "$FLAVORSTR" ] && DESCSTR="$DESCSTR ($FLAVOR)"

    # Temporary file paths
    typeset MANUAL_DEPS=$TMPDIR/${PKGE}.deps.mog
    typeset GLOBAL_MOG_FILE=
    test_relver '>=' 151041 && GLOBAL_MOG_FILE=global-transforms.mog \
        || GLOBAL_MOG_FILE=legacy-global-transforms.mog
    typeset MY_MOG_FILE=$TMPDIR/${PKGE}.mog

    # Version cleanup

    [ -z "$VERHUMAN" ] && VERHUMAN="$VER"

    convert_version VER
    typeset XVER=$VER
    typeset PVER=$RELVER.$DASHREV
    convert_version XVER
    convert_version PVER

    FMRI="${PKG}@${XVER},${SUNOSVER}-${PVER}"

    # Mog files are transformed in several stages
    #
    #        $DESTDIR           +-------------+   fix      +----------+
    #   `pkgsend generate` ---> |.p5m.gen.raw | --perms--> | .p5m.gen |
    #                           +-------------+            +----------+
    #                                                            |
    #        +--------+                                          v
    #        |.p5m.mog| <--------------------------------- `pkgmogrify`
    #        +--------+
    #            |
    #            v                 +---------+
    #   `pkgdepend generate` ----> |.p5m.dep |
    #                              +---------+
    #                                   |
    #   +-------------+                 v
    #   |.p5m.dep.res | <------ `pkgdepend resolve`
    #   +-------------+
    #            |
    #            v               +-------------+
    #       `pkgmogrify` ------> |.p5m (final) |
    #                            +-------------+

    if [ -z "$MOG_TEST" ]; then
        if [ -n "$seed_manifest" ]; then
            logcmd $CP $seed_manifest $P5M_GEN || logerr "seed copy failed"
        elif [ -n "$DESTDIR" ]; then
            generate_manifest $P5M_GEN
        else
            logmsg "--- Looks like a meta-package. Creating empty manifest"
            logcmd $TOUCH $P5M_GEN || \
                logerr "------ Failed to create empty manifest"
        fi
        [ -z "$BATCH" ] && check_libabi "$PKG" "$P5M_GEN"
    fi

    # Package metadata
    logmsg "--- Generating package metadata"
    if [ "$OVERRIDE_SOURCE_URL" = "none" ]; then
        _ARC_SOURCE=
    elif [ -n "$OVERRIDE_SOURCE_URL" ]; then
        _ARC_SOURCE="$OVERRIDE_SOURCE_URL"
    fi
    (
        pkgmeta pkg.fmri            "$FMRI"
        pkgmeta pkg.summary         "$SUMMARY"
        pkgmeta pkg.description     "$DESCSTR"
        pkgmeta publisher           "$PUBLISHER_EMAIL"
        pkgmeta pkg.human-version   "$VERHUMAN"
        [ $legacy -eq 1 ] && pkgmeta pkg.legacy true
        if [[ $_ARC_SOURCE = *\ * ]]; then
            _asindex=0
            for _as in $_ARC_SOURCE; do
                pkgmeta "info.source-url.$_asindex" "$_as"
                ((_asindex++))
            done
        elif [ -n "$_ARC_SOURCE" ]; then
            pkgmeta info.source-url "$_ARC_SOURCE"
        fi
    ) > $MY_MOG_FILE

    # Transforms
    logmsg "--- Applying transforms"
    exec 3>"$TMPDIR/mog.stderr"
    logcmd -p $PKGMOGRIFY -P /dev/fd/3 -I $BLIBDIR/mog \
        $SYS_XFORM_ARGS \
        $XFORM_ARGS \
        $P5M_GEN \
        $MY_MOG_FILE \
        $LOCAL_MOG_FILE \
        $GLOBAL_MOG_FILE \
        $EXTRA_MOG_FILE \
        $FRAG_MOG_FILE \
        | $PKGFMT -u > $P5M_MOG
    (( PIPESTATUS[0] == 0 )) || logerr "pkgmogrify failed"
    exec 3>&-

    if [ -z "$BATCH" -a -s "$TMPDIR/mog.stderr" ]; then
        $CAT "$TMPDIR/mog.stderr" | while read l; do
            logmsg -e "$l"
        done
        logerr "Warnings from mogrify process"
    fi

    if [ -z "$BATCH" -a -f "$P5M_GEN.raw" ]; then
        logmsg "--- Checking for permission overrides"
        # Check for permissions set by the package install scripts which are
        # not being preserved. Since the local mog may have added or removed
        # files and directories, this is a bit more work than a simple diff.
        #
        manifest_mode_map $P5M_GEN.raw > $TMPDIR/permdiff.raw.$$
        manifest_mode_map $P5M_MOG > $TMPDIR/permdiff.mog.$$

        # Find the list of files common to both manifests and generate grep
        # patterns to extract the corresponding lines from the mode maps.
        for f in raw mog; do
            $AWK '{print $3}' < $TMPDIR/permdiff.$f.$$ \
                | $SORT > $TMPDIR/permdiff.$f.paths.$$
        done
        logcmd -p $COMM -12 $TMPDIR/permdiff.{raw,mog}.paths.$$ \
            | $SED 's/.*/ &/' > $TMPDIR/permdiff.patt.$$

        if ! $GDIFF -U0 --color=always --minimal \
            <($GREP -Ff $TMPDIR/permdiff.patt.$$ $TMPDIR/permdiff.raw.$$) \
            <($GREP -Ff $TMPDIR/permdiff.patt.$$ $TMPDIR/permdiff.mog.$$) \
            > $TMPDIR/permdiff.$$; then
                echo
                # Not anchored due to colour codes in file
                $EGREP -v '(\-\-\-|\+\+\+|\@\@) ' $TMPDIR/permdiff.$$ \
                    | $SED 's/\|//'
                note "Some permissions were overridden:"
                logcmd $RM -f $TMPDIR/permdiff.$$
                [ -z "$PERMDIFF_NOASK" ] && ask_to_continue
        fi
        logcmd $RM -f $TMPDIR/permdiff.*.$$
    fi

    if [ -n "$DESTDIR" ]; then
        check_licences
        [ -z "$SKIP_HARDLINK" -a -z "$BATCH" ] \
            && check_hardlinks "$P5M_MOG" "$HARDLINK_TARGETS"
    fi

    logmsg "--- Resolving dependencies"
    (
        set -e
        logcmd -p $PKGDEPEND generate -md $DESTDIR -d $SRCDIR $P5M_MOG \
            > $P5M_DEPGEN
        logcmd $PKGDEPEND resolve -m $P5M_DEPGEN
    ) || logerr "--- Dependency resolution failed"
    logmsg "--- Detected dependencies"
    $GREP '^depend ' $P5M_DEPGEN.res | while read line; do
        logmsg "$line"
    done
    echo > "$MANUAL_DEPS"
    if [ -n "$RUN_DEPENDS_IPS" ]; then
        logmsg "------ Adding manual dependencies"
        for i in $RUN_DEPENDS_IPS; do
            # IPS dependencies have multiple types, of which we care about four:
            #    require, optional, incorporate, exclude
            # For backward compatibility, assume no indicator means type=require
            # FMRI attributes are implicitly rooted so we don't have to prefix
            # 'pkg:/' or worry about ambiguities in names
            local DEPTYPE="require"
            local EXTRA=
            case ${i:0:1} in
                \=)
                    DEPTYPE="incorporate"
                    i=${i:1}
                    shopt -s extglob
                    typeset facet=${i##pkg:+(/)}
                    facet=${facet%@*}
                    EXTRA=" facet.version-lock.$facet=true"
                    ;;
                \?)
                    DEPTYPE="optional"
                    i=${i:1}
                    ;;
                \-)
                    DEPTYPE="exclude"
                    i=${i:1}
                    ;;
            esac
            case $i in
                *@)
                    depname=${i%@}
                    i=${i::-1}
                    explicit_ver=true
                    ;;
                *@*)
                    depname=${i%@*}
                    explicit_ver=true
                    ;;
                *)
                    depname=$i
                    explicit_ver=false
                    ;;
            esac
            # ugly grep, but pkgmogrify doesn't seem to provide any way to add
            # actions while avoiding duplicates (except maybe by running it
            # twice, using drop transform on the first run)
            if $GREP -q "^depend .*fmri=[^ ]*$depname" "${P5M_DEPGEN}.res"; then
                autoresolved=true
            else
                autoresolved=false
            fi
            if $autoresolved && [ "$DEPTYPE" = "require" ]; then
                if $explicit_ver; then
                    escaped_depname="$(python -c "import re; print re.escape(r'$depname')")"
                    echo "<transform depend fmri=(.+/)?$escaped_depname -> set fmri $i>" >> $MANUAL_DEPS
                fi
            else
                echo "depend type=$DEPTYPE fmri=$i$EXTRA" >> $MANUAL_DEPS
            fi
        done
    fi
    logcmd -p $PKGMOGRIFY $SYS_XFORM_ARGS $XFORM_ARGS "${P5M_DEPGEN}.res" \
        "$MANUAL_DEPS" $FINAL_MOG_FILE | $PKGFMT -u > $P5M_FINAL
    logmsg "--- Final dependencies"
    $GREP '^depend ' $P5M_FINAL | while read line; do
        logmsg "$line"
    done

    logmsg "--- Formatting manifest"
    logcmd $PKGFMT -s $P5M_FINAL

    $FGREP -q '$(' $P5M_FINAL \
        && logerr "------ Manifest contains unresolved variables"

    if [ -z "$SKIP_PKGLINT" ] && ( [ -n "$BATCH" ] || ask_to_pkglint ); then
        run_pkglint $PKGSRVR $P5M_FINAL
    fi

    logmsg "--- Publishing package to $PKGSRVR"
    hook pre_publish
    if [ -z "$BATCH" ]; then
        logmsg "Intentional pause:" \
            "Last chance to sanity-check before publication!"
        ask_to_continue
    fi
    if [ -n "$DESTDIR" ]; then
        typeset SEND_ARGS=
        if [ -n "$PKG_INCLUDE_TS" ]; then
            for p in $PKG_INCLUDE_TS; do
                SEND_ARGS+="-T $p "
            done
        fi
        logcmd $PKGSEND -s $PKGSRVR publish -d $DESTDIR \
            -d $TMPDIR/$EXTRACTED_SRC \
            -d $SRCDIR $SEND_ARGS $P5M_FINAL || \
        logerr "------ Failed to publish package"
    else
        # If we're a metapackage (no DESTDIR) then there are no directories
        # to check
        logcmd $PKGSEND -s $PKGSRVR publish $P5M_FINAL || \
            logerr "------ Failed to publish package"
    fi
    logmsg "--- Published $FMRI"

    [ -z "$SKIP_PKG_DIFF" ] && diff_package $FMRI

    return 0
}

publish_manifest_impl() {
    typeset arch="$1"
    typeset pmf="$2"
    typeset root="$3"

    [ -n "$root" ] && root="-d $root"

    logcmd -p $PKGMOGRIFY -P /dev/fd/3 -I $BLIBDIR/mog \
        $SYS_XFORM_ARGS $XFORM_ARGS `build_archmog $arch` $pmf \
        | $PKGFMT -u > $pmf.$arch.final

    if [ -z "$SKIP_PKGLINT" ] && ( [ -n "$BATCH" ] || ask_to_pkglint ); then
        run_pkglint $PKGSRVR $pmf.$arch.final
    fi

    logcmd $PKGSEND -s $PKGSRVR publish $root $pmf.$arch.final \
        || logerr "pkgsend failed"
}

publish_manifest() {
    local pkg=$1
    local pmf=$2
    local root=$3

    typeset -a cross=
    typeset -i native=0

    typeset x="
        -DPKGPUBLISHER=$PKGPUBLISHER
        -DRELVER=$RELVER
        -DPVER=$PVER
        -DSUNOSVER=$SUNOSVER
        -DPKGPUBEMAIL=$PUBLISHER_EMAIL
    "

    for arch in $BUILDARCH; do
        if cross_arch $arch; then
            cross+=($arch)
        else
            ((native++))
        fi
    done

    exec 3>"$TMPDIR/mog.stderr"

    if ((native)); then
        logmsg "--- packaging native arch"

        XFORM_ARGS+="$x" publish_manifest_impl $NATIVE_ARCH "$pmf" "$root"
    else
        for carch in ${cross[*]}; do
            logmsg "--- packaging $arch"

            PKGSRVR=${REPOS[$carch]} \
                PKG_IMAGE=${SYSROOT[$carch]} \
                XFORM_ARGS+="$x" \
                publish_manifest_impl "$carch" "$pmf" "$root"
            done
    fi

    [ -n "$pkg" -a -z "$SKIP_PKG_DIFF" ] && diff_latest $pkg
}

build_xform_sed() {
    XFORM_SED_CMD=

    for kv in $SYS_XFORM_ARGS $XFORM_ARGS; do
        typeset k=${kv%%=*}
        typeset v=${kv#*=}
        typeset _v

        # Escape special characters.
        # If $v contains wildcards like "*", then the following "echo"
        # causes them to get expanded into filenames in the current
        # directory. To avoid this, we temporarily disable globbing ...
        set -o noglob
        _v="`echo $v | $SED '
            s/[&$^\\]/\\\&/g
        '`"
        set +o noglob

        XFORM_SED_CMD+="
            s^\$(${k:2})^$_v^g
        "
    done
}

# Transform a file using the translations defined in $SYS_XFORM_ARGS and
# $XFORM_ARGS
xform() {
    local file="$1"

    [ -n "$XFORM_SED_CMD" ] || build_xform_sed

    $SED "$XFORM_SED_CMD" < $file
}

#############################################################################
# Package diffing
#############################################################################

# Create a list of the items contained within a package in a format suitable
# for comparing with previous versions. We don't care about changes in file
# content, just whether items have been added, removed or had their attributes
# such as ownership changed.
pkgitems() {
    $PKGCLIENT contents -m "$@" 2>&1 | $PKGFMT -u | $SED -E "
        # Remove signatures
        /^signature/d
        # Remove version numbers from the package FMRI
        /name=pkg.fmri/s/@.*//
        /human-version/d
        # Remove version numbers from dependencies
        /^depend/s/@[^ ]+//g
        # Remove file hashes
        s/^file [^ ]+/file/
        s/ chash=[^ ]+//
        s/ elfhash=[^ ]+//
        s/ pkg.content-hash=[^ ]+//g
        # Remove file sizes
        s/ pkg.[c]?size=[0-9]+//g
        # Remove timestamps
        s/ timestamp=[^ ]+//
        $PKGDIFF_HELPER
    "
}

diff_packages() {
    local srcrepo="${1:?}"
    local srcfmri="${2:?}"
    local dstrepo="${3:?}"
    local dstfmri="${4:?}"

    if [ -n "$BATCH" ]; then
        of=$TMPDIR/pkg.diff.$$
        echo "Package: $fmri" > $of
        if ! $GDIFF -u \
            <(pkgitems -g $srcrepo $srcfmri) \
            <(pkgitems -g $dstrepo $dstfmri) \
            >> $of; then
                    logmsg -e "----- $srcfmri has changed"
                    logcmd $MV $of $TMPDIR/pkg.diff
                    return 1
        else
            logcmd $RM -f $of
            return 0
        fi
    else
        logmsg "--- Comparing old package with new"
        if ! $GDIFF -U0 --color=always --minimal \
            <(pkgitems -g $srcrepo $srcfmri) \
            <(pkgitems -g $dstrepo $dstfmri) \
            > $TMPDIR/pkgdiff.$$; then
                echo
                # Not anchored due to colour codes in file
                $EGREP -v '(\-\-\-|\+\+\+|\@\@) ' $TMPDIR/pkgdiff.$$
                note "Differences found between old and new packages"
                logcmd $RM -f $TMPDIR/pkgdiff.$$
                [ -z "$PKGDIFF_NOASK" ] && ask_to_continue
        fi
        logcmd $RM -f $TMPDIR/pkgdiff.$$
    fi
}

diff_package() {
    local fmri="$1"
    local xfmri=${fmri%@*}

    diff_packages $IPS_REPO $xfmri $PKGSRVR $fmri
}

diff_latest() {
    typeset fmri="`$PKGCLIENT list -nvHg $PKGSRVR $1 | $NAWK 'NR==1{print $1}'`"
    logmsg "-- Generating diffs for $fmri"
    diff_package $fmri
}

#############################################################################
# Re-publish packages from one repository to another, changing the publisher
#############################################################################

republish_packages() {
    REPUBLISH_SRC="$1"
    logmsg "Republishing packages from $REPUBLISH_SRC"
    [ -d $TMPDIR/$BUILDDIR ] || $MKDIR $TMPDIR/$BUILDDIR
    mog=$TMPDIR/$BUILDDIR/pkgpublisher.mog
    $CAT << EOM > $mog
<transform set name=pkg.fmri -> edit value pkg://[^/]+/ pkg://$PKGPUBLISHER/>
EOM

    incoming=$TMPDIR/$BUILDDIR/incoming
    [ -d $incoming ] && $RM -rf $incoming
    $MKDIR $incoming
    for pkg in `$PKGRECV -s $REPUBLISH_SRC -d $incoming --newest`; do
        logmsg "    Receiving $pkg"
        logcmd $PKGRECV -s $REPUBLISH_SRC -d $incoming --raw $pkg
    done

    for pdir in $incoming/*/*; do
        logmsg "    Processing $pdir"
        $PKGMOGRIFY $pdir/manifest $mog > $pdir/manifest.newpub
        logcmd $PKGSEND publish -s $PKGSRVR -d $pdir $pdir/manifest.newpub
    done
}

mog_fragment() {
    $CAT >> $TMPDIR/frag.mog
}

#############################################################################
# Add some release notes
#############################################################################

# Add some release notes that are displayed during installation/upgrade.
# Pass the name of the notes file (relative to files/) as the first argument
# and set the second argument to:
#   0       - display the notes on initial package installation only
#   <ver>   - display the notes when upgrading from before version <ver>
# If the second argument is omitted, it defaults to 0

add_notes() {
    local file="${1:?file}"
    local ver="${2:-0}"

    pushd $DESTDIR > /dev/null
    logmsg "-- Adding notes from $file"
    local tgt=${NOTES_LOCATION#/}
    logcmd $MKDIR -p $tgt
    logcmd $CP $SRCDIR/files/$file $tgt/$PKGD || logerr "Cannot copy to $tgt"
    $CAT << EOM | mog_fragment
<transform file path=$tgt/$PKGD\$ -> set release-note feature/pkg/self@$ver>
<transform file path=$tgt/$PKGD\$ -> set must-display true>
EOM
    popd >/dev/null
}

#############################################################################
# Install an SMF service
#############################################################################

install_smf() {
    typeset methodpath=lib/svc/method
    while [[ "$1" = -* ]]; do
        case "$1" in
            -oocemethod) methodpath+="/ooce" ;;
        esac
        shift
    done

    mtype="${1:?type}"
    manifest="${2:?manifest}"
    method="$3"

    pushd $DESTDIR > /dev/null
    logmsg "-- Installing SMF service ($mtype / $manifest / $method)"

    typeset manifestf; typeset methodf; typeset dir
    for dir in $SRCDIR/files $TMPDIR; do
        [ -f "$dir/$manifest" ] && manifestf="$dir/$manifest"
        [ -f "$dir/$method" ] && methodf="$dir/$method"
    done

    [ -z "$manifestf" ] && logerr "Could not locate $manifest"
    [ -n "$method" -a -z "$methodf" ] && logerr "Could not locate $method"

    logcmd svccfg validate $manifestf \
        || logerr "Manifest does not pass validation"

    # Manifest
    logcmd $MKDIR -p lib/svc/manifest/$mtype \
        || logerr "mkdir of $DESTDIR/lib/svc/manifest/$mtype failed"
    logcmd $CP $manifestf lib/svc/manifest/$mtype/ \
        || logerr "Cannot copy SMF manifest"
    logcmd $CHMOD 0444 lib/svc/manifest/$mtype/$manifest

    # Method
    if [ -n "$method" ]; then
        logcmd $MKDIR -p $methodpath \
            || logerr "mkdir of $DESTDIR/$methodpath failed"
        logcmd $CP $methodf $methodpath/ \
            || logerr "Cannot install SMF method"
        logcmd $CHMOD 0555 $methodpath/$method
    fi

    popd > /dev/null
}

#############################################################################
# Install fragment files
#############################################################################

install_fragment() {
    typeset src="${1?src}"
    typeset dst="${2?dst}"
    typeset tgt="${PKG//\//:}"

    [ -f "$SRCDIR/files/$src" ] || logerr "fragment files/$src not found"

    typeset fragfile=`$MKTEMP -p $TMPDIR`

    xform "$SRCDIR/files/$src" > "$fragfile"

    $CAT << EOM | mog_fragment
file ../${fragfile##*/} path=$dst/$tgt owner=root group=sys mode=0444
EOM
}

install_inetservices() {
    install_fragment "${1:-services}" /etc/inet/services.d
}

install_authattr() {
    install_fragment "${1:-auth_attr}" /etc/security/auth_attr.d
}

install_execattr() {
    install_fragment "${1:-exec_attr}" /etc/security/exec_attr.d
}

install_profattr() {
    install_fragment "${1:-prof_attr}" /etc/security/prof_attr.d
}

install_userattr() {
    install_fragment "${1:-user_attr}" /etc/user_attr.d
}

install_system() {
    install_fragment "${1:-system}" /etc/system.d
}

#############################################################################
# Install a go binary
#############################################################################

install_go() {
    typeset src="${1:-$PROG}"
    typeset dst="${2:-$PROG}"
    typeset dstdir="${3:-$DESTDIR/$PREFIX/bin}"

    logcmd $MKDIR -p $dstdir \
        || logerr "Failed to create install dir"

    logcmd $CP $TMPDIR/$BUILDDIR/$src $dstdir/$dst \
        || logerr "Failed to install binary"
}

#############################################################################
# Install a rust binary
#############################################################################

install_rust() {
    typeset prog=${1:-$PROG}

    logmsg "Installing $prog"

    for b in $BUILDARCH; do
        [ $b = i386 ] && continue

        hook pre_install $b || return

        destdir=$DESTDIR
        cross_arch $b && destdir+=.$b

        logcmd $MKDIR -p "$destdir$PREFIX/bin" \
            || logerr "Failed to create install dir"
        logcmd $CP $TMPDIR/$BUILDDIR/target/${RUSTTRIPLETS[$b]}/release/$prog \
            $destdir$PREFIX/bin/$prog || logerr "Failed to install binary"

        for f in `$FD "^$prog\.1\$" $TMPDIR/$BUILDDIR`; do
            logmsg "Found man page at $f"

            logcmd $MKDIR -p "$destdir$PREFIX/share/man/man1" \
                || logerr "Failed to create man install dir"
            logcmd $CP $f $destdir$PREFIX/share/man/man1/$prog.1 \
                || logerr "Failed to install man page"
            break
        done

        hook post_install $b
    done
}

#############################################################################
# Make isaexec stub binaries
#############################################################################

make_isa_stub() {
    [ -n "$FORGO_ISAEXEC" ] && return
    logmsg "Making isaexec stub binaries"
    [ -z "$ISAEXEC_DIRS" ] && ISAEXEC_DIRS="bin sbin"
    for DIR in $ISAEXEC_DIRS; do
        if [ -d $DESTDIR$PREFIX/$DIR ]; then
            logmsg "--- $DIR"
            pushd $DESTDIR$PREFIX/$DIR > /dev/null
            make_isaexec_stub_arch i386 $PREFIX/$DIR
            make_isaexec_stub_arch amd64 $PREFIX/$DIR
            popd > /dev/null
        fi
    done
}

make_isaexec_stub_arch() {
    typeset isa="$1"
    typeset dir="$2"

    for file in $isa/*; do
        [ -f "$file" ] || continue
        if [ -z "$STUBLINKS" -a -h "$file" ]; then
            # Symbolic link. If it's relative to within the same ARCH
            # directory, then replicate it at the ISAEXEC level.
            link=`$READLINK "$file"`
            [[ $link = */* ]] && continue
            base=`$BASENAME "$file"`
            [ -h "$base" ] && continue
            logmsg "------ Symbolic link: $file - replicating"
            logcmd $LN -s $link $base || logerr "--- Link failed"
            continue
        fi
        # Check to make sure we don't have a script
        read -n 4 < $file
        file=`$BASENAME $file`
        # Only copy non-binaries if we set NOSCRIPTSTUB
        if [[ $REPLY != $'\177'ELF && -n "$NOSCRIPTSTUB" ]]; then
            logmsg "------ Non-binary file: $file - copying instead"
            logcmd $CP $1/$file . && $RM $1/$file || logerr "--- Copy failed"
            $CHMOD +x $file
            continue
        fi
        # Skip if we already made a stub for this file
        [ -f "$file" ] && continue
        logmsg "---- Creating ISA stub for $file"
        logcmd $CC ${CFLAGS[0]} ${CFLAGS[i386]} -o $file \
            -DFALLBACK_PATH="$dir/$file" $BLIBDIR/isastub.c \
            || logerr "--- Failed to make isaexec stub for $dir/$file"
        strip_files "$file"
    done
}

configure_autoreconf() {
    [ -f configure -a -f configure.ac ] \
        && [ ! configure.ac -nt configure ] && return
    run_autoreconf -fi
}

#############################################################################
# Build commands
#############################################################################

make_clean() {
    typeset arch="$1"
    hook pre_clean $arch
    if [ -n "$CLEAN_SOURCE" ]; then
        CLEAN_SOURCE=
        return
    fi

    eval set -- $MAKE_CLEAN_ARGS_WS
    logmsg "--- make (dist)clean"
    (
        $MAKE $MAKE_CLEAN_ARGS "$@" distclean \
            || $MAKE $MAKE_CLEAN_ARGS "$@" clean
    ) 2>&1 | $SED 's/error: /errorclean: /' | pipelog >/dev/null
    hook post_clean $arch
}

configure_arch() {
    typeset arch=${1:?arch}
    hook pre_configure $arch || return
    logmsg "--- configure ($arch)"
    eval set -- ${CONFIGURE_OPTS["${arch}_WS"]} ${CONFIGURE_OPTS[WS]}
    [ -n "$RUN_AUTORECONF" ] && configure_autoreconf
    typeset PCPATH=
    addpath PCPATH ${PKG_CONFIG_PATH[0]}
    addpath PCPATH ${PKG_CONFIG_PATH[$arch]}
    CFLAGS="${CFLAGS[0]} ${CFLAGS[$arch]}" \
        CXXFLAGS="${CXXFLAGS[0]} ${CXXFLAGS[$arch]}" \
        CPPFLAGS="${CPPFLAGS[0]} ${CPPFLAGS[$arch]}" \
        LDFLAGS="${LDFLAGS[0]} ${LDFLAGS[$arch]}" \
        PKG_CONFIG_PATH="$PCPATH" \
        CC="$CC" CXX="$CXX" \
        logcmd $CONFIGURE_CMD \
        ${CONFIGURE_OPTS[$arch]} ${CONFIGURE_OPTS[0]} \
        "$@" || \
        logerr "--- Configure failed"
    hook post_configure $arch
    # Check for configuration tests that have failed as a result of a
    # main function being present without a declared return type.
    $RIPGREP --no-messages --no-ignore \
        "error: (return type defaults|implicit declaration.*'(exit|strcmp)')" \
        -g config.log && logerr 'Found broken tests in configure'
}

make_arch() {
    typeset arch=${1:?arch}
    hook pre_make $arch
    eval set -- $MAKE_ARGS_WS
    [ -n "$NO_PARALLEL_MAKE" ] && MAKE_JOBS=""
    if [ -n "$LIBTOOL_NOSTDLIB" ]; then
        libtool_nostdlib "$LIBTOOL_NOSTDLIB" "$LIBTOOL_NOSTDLIB_EXTRAS"
    fi
    logmsg "--- make"
    logcmd $MAKE $MAKE_JOBS $MAKE_ARGS "$@" $MAKE_TARGET \
        || logerr "--- Make failed"
    hook post_make $arch
}

for arch in $ARCH_LIST; do
    eval "configure_$arch() { configure_arch $arch; }"
    eval "make_clean_$arch() { make_clean $arch; }"
    eval "make_prog_$arch() { make_arch $arch; }"
done

make_install() {
    typeset arch=$1; shift
    hook pre_install $arch || return
    local args="$@"
    eval set -- $MAKE_INSTALL_ARGS_WS
    logmsg "--- make install"
    if [ "${MAKE##*/}" = "ninja" ]; then
        DESTDIR=${DESTDIR} logcmd $MAKE $args $MAKE_INSTALL_ARGS "$@" \
            $MAKE_INSTALL_TARGET || logerr "--- Make install failed"
    else
        logcmd $MAKE DESTDIR=${DESTDIR} $args $MAKE_INSTALL_ARGS "$@" \
            $MAKE_INSTALL_TARGET || logerr "--- Make install failed"
    fi
    hook post_install $arch

    typeset tf=$TMPDIR/pkgconfig.fix
    : > $tf
    logmsg "--- fixing runtime path linker option in pkg-config files"
    while read f; do
        logcmd $RM -f $f.orig
        $SED -Ei.orig -e '
            # If the line already contains -Wl,-R, next!
            /-Wl,-R/n
            /^Libs:/ {
                # Replace any -R with the more widely accepted -Wl,-R
                s/[:space:]-R/ -Wl,-R/
                # If the above replacement succeeded, next!
                t
                # Augment any remaining -L with a matching -Wl,-R
                s/-L[:space:]*([^[:space:]]+)/& -Wl,-R\1/
            }
        ' $f || echo "Failed to fix $f" >> $tf
        logcmd $DIFF -u $f{.orig,}
        logcmd $RM $f.orig
    done < <($FD -t f -e pc -p "${LIBDIRS[$arch]}/pkgconfig/[^/]+\\.pc\$" $DESTDIR)
    if [ -s "$tf" ]; then
        $CAT $tf | pipelog
        logerr "Problem fixing pkg-config files"
    fi
}

make_install_i386() {
    make_install i386 $MAKE_INSTALL_ARGS_32
}

make_install_amd64() {
    make_install amd64 $MAKE_INSTALL_ARGS_64
}

make_install_aarch64() {
    DESTDIR+=.aarch64 make_install aarch64 $MAKE_INSTALL_ARGS_64
}

make_pure_install() {
    # Make pure_install for perl modules so they don't touch perllocal.pod
    logmsg "--- make install (pure)"
    logcmd $MAKE DESTDIR=${DESTDIR} pure_install || \
        logerr "--- Make pure_install failed"
}

make_param() {
    logmsg "--- make $@"
    logcmd $MAKE "$@" || \
        logerr "--- $MAKE $1 failed"
}

# Helper function that can be called by build scripts to make in a specific dir
make_in() {
    [ -z "$1" ] && logerr "------ Make in dir failed - no dir specified"
    [ -n "$NO_PARALLEL_MAKE" ] && MAKE_JOBS=""
    logmsg "------ make in $1"
    logcmd $MAKE $MAKE_JOBS -C $1 $MAKE_TARGET || \
        logerr "------ Make in $1 failed"
}

# Helper function that can be called by build scripts to install in a specific
# dir
make_install_in() {
    [ -z "$1" ] && logerr "--- Make install in dir failed - no dir specified"
    logmsg "------ make install in $1"
    logcmd $MAKE -C $1 DESTDIR=${DESTDIR} $MAKE_INSTALL_TARGET || \
        logerr "------ Make install in $1 failed"
}

build() {
    typeset arch

    [ -n "$SKIP_BUILD" ] && return
    ((EXTRACT_MODE >= 1)) && return

    local ctf=${CTF_DEFAULT:-0}

    for arch in $ARCH_LIST; do
        if [[ ${CONFIGURE_OPTS[0]} =~ /$arch ]]; then
            logerr "CONFIGURE_OPTS must not contain ISA options."
        fi
    done

    while [[ "$1" = -* ]]; do
        case "$1" in
            -ctf)   ctf=1 ;;
            -noctf) ctf=0 ;;
            -multi) MULTI_BUILD=1 ;;
        esac
        shift
    done

    [ $ctf -eq 1 ] && CFLAGS[0]+=" $CTF_CFLAGS"

    hook build_init

    [ -n "$MULTI_BUILD" ] && logmsg "--- Using multiple build directories"
    typeset _BUILDDIR=$BUILDDIR
    for b in $BUILDARCH; do
        if [ -n "$MULTI_BUILD" ]; then
            BUILDDIR+="/build.$b"
            $MKDIR -p $TMPDIR/$BUILDDIR
            MULTI_BUILD_LAST=$BUILDDIR
        fi
        hook pre_build $b || continue
        build_$b || logerr "$b build failed"
        hook post_build $b
        BUILDDIR=$_BUILDDIR
    done

    if [ $ctf -eq 1 ]; then
        for dir in $DESTDIRS; do
            convert_ctf "$dir"
        done
    fi

    hook build_fini
}

check_buildlog() {
    typeset -i expected="${1:-0}"

    logmsg "--- Checking logfile for errors (expect $expected)"

    errs="`$GREP 'error: ' $LOGFILE | \
        $EGREP -v -- '-Werror' | \
        $EGREP -cv 'pathspec.*did not match any file'`"

    [ "$errs" -ne "$expected" ] \
        && logerr "Found $errs errors in logfile (expected $expected)"

    [[ $CONFIGURE_CMD == *cmake* ]] \
        && $EGREP -s 'compiler identification is unknown' $LOGFILE \
        && logerr "cmake could not correctly identify the compiler"
}

build_i386() {
    typeset arch=i386
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building $arch"
    export ISALIST="i386"
    make_clean_$arch
    configure_$arch
    make_prog_$arch
    [ -z "$SKIP_BUILD_ERRCHK" ] && check_buildlog ${EXPECTED_BUILD_ERRS:-0}
    make_install_$arch
    popd > /dev/null
    unset ISALIST
    export ISALIST
}

build_amd64() {
    typeset arch=amd64
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building $arch"
    make_clean_$arch
    configure_$arch
    make_prog_$arch
    [ -z "$SKIP_BUILD_ERRCHK" ] && check_buildlog ${EXPECTED_BUILD_ERRS:-0}
    make_install_$arch
    popd > /dev/null
}

build_aarch64() {
    typeset arch=aarch64

    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building $arch"
    set_crossgcc $arch
    make_clean_$arch
    configure_$arch
    make_prog_$arch
    [ -z "$SKIP_BUILD_ERRCHK" ] && check_buildlog ${EXPECTED_BUILD_ERRS:-0}
    make_install_$arch
    popd > /dev/null
}

run_testsuite() {
    local target="${1:-test}"
    local dir="$2"
    local output="${3:-testsuite.log}"
    if [ -z "$SKIP_TESTSUITE" ] && ( [ -n "$BATCH" ] || ask_to_testsuite ); then
        if [ -z "$MULTI_BUILD" ]; then
            pushd $TMPDIR/$BUILDDIR/$dir > /dev/null
        else
            pushd $TMPDIR/$MULTI_BUILD_LAST/$dir > /dev/null
        fi
        logmsg "Running testsuite"
        hook pre_test
        op=`$MKTEMP`
        eval set -- $MAKE_TESTSUITE_ARGS_WS
        $TESTSUITE_MAKE $target $MAKE_TESTSUITE_ARGS "$@" 2>&1 | $TEE $op
        if [ -n "$TESTSUITE_SED" ]; then
            $SED "$TESTSUITE_SED" $op > $SRCDIR/$output
        elif [ -n "$TESTSUITE_FILTER" ]; then
            $EGREP "$TESTSUITE_FILTER" $op > $SRCDIR/$output
        else
            $CP $op $SRCDIR/$output
        fi
        logcmd $MV $op $TMPDIR/testsuite.raw
        hook post_test
        popd > /dev/null
    fi
}

#############################################################################
# Build function for dependencies which are not packaged
#############################################################################

build_dependency() {
    [ -n "$SKIP_BUILD" ] && return

    typeset merge=0
    typeset oot=0
    typeset meson=0
    typeset cmake=0
    typeset buildargs=
    while [[ "$1" = -* ]]; do
        case $1 in
            -merge)     merge=1 ;;
            -ctf)       buildargs+=" -ctf" ;;
            -noctf)     buildargs+=" -noctf" ;;
            -oot)       oot=1 ;;
            -meson)     meson=1; oot=1 ;;
            -cmake)     cmake=1; oot=1 ;;
            -multi)     buildargs+=" -multi" ;;
        esac
        shift
    done
    typeset dep="$1"
    typeset dir="$2"
    typeset dldir="$3"
    typeset prog="$4"
    typeset ver="$5"

    save_variable BUILDDIR __builddep__
    save_variable EXTRACTED_SRC __builddep__
    save_variable DESTDIR __builddep__
    save_variable CONFIGURE_CMD __builddep__
    save_variable MAKE __builddep__

    set_builddir "$dir"
    local patchdir="patches-$dep"
    [ ! -d "$patchdir" -a -d "patches-$ver" ] && patchdir="patches-$ver"
    if [ $merge -eq 0 ]; then
        DEPROOT=$TMPDIR/_deproot
        DESTDIR=$DEPROOT
        $MKDIR -p $DEPROOT
    else
        DEPROOT=$DESTDIR
    fi

    note -n "-- Building dependency $dep"
    download_source -dependency "$dldir" "$prog" "$ver" "$TMPDIR"
    patch_source $patchdir
    if ((oot)); then
        logmsg "-- Setting up for out-of-tree build"
        if ((meson)); then
            MAKE=$NINJA
            CONFIGURE_CMD="/usr/lib/python$PYTHONVER/bin/meson setup"
            CONFIGURE_CMD+=" $TMPDIR/$BUILDDIR"
        elif ((cmake)); then
            MAKE=$NINJA
            CONFIGURE_CMD="$CMAKE -GNinja"
            CONFIGURE_CMD+=" $TMPDIR/$BUILDDIR"
        else
            CONFIGURE_CMD=$TMPDIR/$BUILDDIR/$CONFIGURE_CMD
        fi
        BUILDDIR+=-build
        [ -d $TMPDIR/$BUILDDIR ] && logcmd $RM -rf $TMPDIR/$BUILDDIR
        logcmd $MKDIR -p $TMPDIR/$BUILDDIR
    fi
    ((EXTRACT_MODE == 0)) && build $buildargs

    cross_arch $BUILDARCH && DEPROOT+=.$BUILDARCH

    restore_variable BUILDDIR __builddep__
    restore_variable EXTRACTED_SRC __builddep__
    restore_variable DESTDIR __builddep__
    restore_variable CONFIGURE_CMD __builddep__
    restore_variable MAKE __builddep__
}

#############################################################################
# Build function for python programs
#############################################################################

set_python_version() {
    PYTHONVER=$1
    PYTHONMAJVER=${PYTHONVER%%.*}
    PYTHONPKGVER=${PYTHONVER//./}
    PYTHONPATH=$PREFIX
    PYTHON=/usr/bin/python$PYTHONVER
    PYTHONLIB=$PYTHONPATH/lib
    PYTHONVENDOR=$PYTHONLIB/python$PYTHONVER/vendor-packages
    PYTHONSITE=$PYTHONLIB/python$PYTHONVER/site-packages
}

python_path_fixup() {
    pushd $DESTDIR/$PREFIX/bin >/dev/null || return
    for f in *; do
        [ -f "$f" ] || continue
        $FILE "$f" | $EGREP -s 'executable.*python.*script' || continue
        logmsg "Fixing python library path in $f"
        sed -i "1a\\
import sys; sys.path.insert(1, '$PREFIX/lib/python$PYTHONVER/vendor-packages')
        " "$f"
    done
    popd >/dev/null
}

python_vendor_relocate() {
    [ -d $DESTDIR/$PYTHONSITE ] || return
    logmsg "Relocating python $PYTHONVER site-packages to vendor-packages"
    if [ -d $DESTDIR$PYTHONVENDOR ]; then
        logcmd $RSYNC -a $DESTDIR$PYTHONSITE/ $DESTDIR$PYTHONVENDOR/ \
            || logerr "python: cannot copy from site to vendor-packages"
        logcmd $RM -rf $DESTDIR$PYTHONSITE
    else
        logcmd $MV $DESTDIR$PYTHONSITE/ $DESTDIR$PYTHONVENDOR/ \
            || logerr "python: cannot move from site to vendor-packages"
    fi

    for d in $DESTDIR$PYTHONVENDOR/*.{egg,dist}-info; do
        [ -d "$d" ] || continue
        logmsg "-- Setting INSTALLER for `$BASENAME $d`"
        echo pkg > $d/INSTALLER
    done
}

python_compile() {
    logmsg "Compiling python modules"
    case $PYTHONVER in
        2.*) logcmd $PYTHON \
                -m compileall \
                -f \
                "$@" \
                $DESTDIR ;;
        *) logcmd $PYTHON \
                -m compileall \
                -j0 \
                -f \
                --invalidation-mode timestamp \
                "$@" \
                $DESTDIR ;;
    esac
}

python_pep518() {
    logmsg "-- PEP518 build"
    logcmd $PYTHON -mpip install -vvv \
        --no-deps --isolated --no-input --exists-action=a \
        --disable-pip-version-check --root=$DESTDIR $PEP518OPTS \
        --prefix=$PREFIX . \
        || logerr "--- build failed"
}

python_setuppy() {
    logmsg "-- setup.py build"
    logcmd $PYTHON ./setup.py $PYGLOBALOPTS build $PYBUILDOPTS \
        || logerr "--- build failed"
    logcmd $PYTHON ./setup.py install --root=$DESTDIR \
        --prefix=$PREFIX $PYINSTOPTS \
        || logerr "--- install failed"
}

python_backend() {
    typeset backend=

    if [ -n "$PYTHON_BUILD_BACKEND" ]; then
        backend=$PYTHON_BUILD_BACKEND
    elif [ -f pyproject.toml ]; then
        backend=pep518
        # Warn if the project has both in case we wish to force one or the
        # other.
        [ -f setup.py ] && \
            logmsg -n "Project has both pyproject.toml and setup.py," \
            "using PEP518"
    elif [ -f setup.py ]; then
        backend=setuppy
    else
        logerr "-- Could not determine python build backend to use"
    fi

    python_$backend "$@"
}

python_build_arch() {
    typeset arch=$1
    hook pre_build $arch
    CFLAGS="${CFLAGS[0]} ${CFLAGS[$arch]}" \
        LDFLAGS="${LDFLAGS[0]} ${LDFLAGS[$arch]}" \
        PYBUILDOPTS="${PYBUILDOPTS[0]} ${PYBUILDOPTS[$arch]}" \
        PYINSTOPTS="${PYINSTOPTS[0]} ${PYINSTOPTS[$arch]}" \
        PEP518OPTS="${PEP518OPTS[0]} ${PEP518OPTS[$arch]}" \
        python_backend

    # XXX - can do better
    if [ -d $DESTDIR/$TMPDIR/venv/cross ]; then
        logcmd $MV $DESTDIR/$TMPDIR/venv/cross $DESTDIR/usr
        logcmd $RM -rf $DESTDIR/data
    fi

    python_vendor_relocate
    python_path_fixup
    python_compile
}

python_build_i386() {
    ISALIST=i386 \
        python_build_arch i386
}

python_build_amd64() {
    ISALIST="amd64 i386" \
        python_build_arch amd64
}

python_build_aarch64() {
    typeset arch=aarch64

    # Prepare a cross compilation environment
    logmsg "--- Preparing cross compilation environment"
    set_crossgcc $arch
    logcmd $PYTHON -mcrossenv ${SYSROOT[$arch]}$PYTHON $TMPDIR/venv \
        || logerr "Failed to set up crossenv"
    source $TMPDIR/venv/bin/activate
}

python_build_aarch64() {
    typeset arch=aarch64

    python_cross_setup $arch

    PYTHON=$TMPDIR/venv/cross/bin/python \
        DESTDIR+=.$arch \
        python_build_arch $arch
}

python_build() {
    [ -z "$PYTHON" ] && logerr "PYTHON not set"
    [ -z "$PYTHONPATH" ] && logerr "PYTHONPATH not set"
    [ -z "$PYTHONLIB" ] && logerr "PYTHONLIB not set"

    logmsg "Building using python setup.py"

    pushd $TMPDIR/$BUILDDIR > /dev/null

    # we only ship 64 bit python3
    [[ $PYTHONVER == 3.* && $BUILDARCH == *i386* ]] && BUILDARCH=amd64

    [ -f setup.py -o -f pyproject.toml ] \
        || logerr "Don't know how to build this project"

    for b in $BUILDARCH; do
        python_build_$b || logerr "$b build failed"
    done

    popd > /dev/null
}

pyvenv_install() {
    typeset pkg=${1:?pkg}; shift
    typeset ver=${1:?ver}; shift
    typeset venv=${1:?venv}; shift

    if [ ! -d "$venv" ]; then
        logmsg "Preparing virtual python environment"
        logcmd $PYTHON -mvenv --system-site-packages --without-pip $venv \
            || logerr "python venv set up failed"

        logcmd rm -f $venv/bin/[aA]ctivate*
    fi

    ((EXTRACT_MODE >= 1)) && exit

    logmsg "-- installing $pkg"
    VIRTUAL_ENV=$venv logcmd $venv/bin/python$PYTHONVER -mpip \
        --disable-pip-version-check \
        --require-virtualenv \
        --no-input \
        install "$@" $pkg==$ver \
        || logerr "pip install $pkg ($ver) failed"
}

pyvenv_build() {
    typeset venv=$DESTDIR/$PREFIX
    typeset pkg=${1:?pkg}
    typeset ver=${2:?ver}

    typeset constrain=
    [ -f $SRCDIR/files/constraints -a -z "$REBASE_PATCHES" ] \
        && constrain="-c $SRCDIR/files/constraints"

    pyvenv_install $pkg $ver $venv $constrain

    if [ -n "$REBASE_PATCHES" ]; then
        VIRTUAL_ENV=$venv logcmd -p $venv/bin/python$PYTHONVER -mpip freeze \
            --local \
            | egrep -v "^$pkg=" > $SRCDIR/files/constraints
        sed -i '1i\
## This file was auto-generated and can be updated with ./build.sh -P
        ' $SRCDIR/files/constraints
    fi

    pushd $venv >/dev/null || logerr "pushd $venv"
    for b in bin/*; do
        [ -f "$b" ] || continue
        [ -h "$b" ] && continue
        $FILE "$b" | $EGREP -s 'executable.*python.*script' || continue
        logmsg "Fixing shebang in $b"
        sed -i "1s^$DESTDIR^^" "$b"
    done
    popd >/dev/null

    # The bundled python modules each have their own licence
    SKIP_LICENCES='bundled/*'
    pushd $DESTDIR >/dev/null || logerr "pushd $DESTDIR"
    for d in ${PREFIX#/}/lib/python$PYTHONVER/site-packages/*-info; do
        [ -d "$d" ] || continue
        pushd "$d" >/dev/null || logerr "pushd $d"
        pkg=`basename $d | cut -d- -f1`
        logmsg "-- collecting licences for $pkg"
        for l in LICEN[CS]E* COPYING; do
            [ -f "$l" ] || continue
            echo "license $d/$l license=bundled/$pkg/$l" | mog_fragment
        done
        popd >/dev/null
    done
    popd >/dev/null
}

#############################################################################
# Build function for rust utils
#############################################################################

build_rust() {
    save_variables CFLAGS CXXFLAGS

    for b in $BUILDARCH; do
        [ $b = i386 ] && continue

        logmsg "Building rust ($b)"

        hook pre_build $b || continue

        pushd $TMPDIR/$BUILDDIR >/dev/null

        if cross_arch $b; then
            restore_variables CFLAGS CXXFLAGS

            subsume_arch $b CFLAGS
            subsume_arch $b CXXFLAGS
            CFLAGS+=" --sysroot=${SYSROOT[$b]}"
            CXXFLAGS+=" --sysroot=${SYSROOT[$b]}"
            export CFLAGS CXXFLAGS

            RUSTFLAGS+=" -C linker=$CROSSTOOLS/$b/bin/gcc"
            RUSTFLAGS+=" -C link-arg=--sysroot=${SYSROOT[$b]}"
            export RUSTFLAGS

            PKG_CONFIG_SYSROOT_DIR=${SYSROOT[$b]}
            PKG_CONFIG_LIBDIR="${SYSROOT[$b]}/usr/${LIBDIRS[$b]}/pkgconfig"
            PKG_CONFIG_LIBDIR+=":${SYSROOT[$b]}$OOCEOPT/${LIBDIRS[$b]}/pkgconfig"
            export PKG_CONFIG_SYSROOT_DIR PKG_CONFIG_LIBDIR

            TARGET_CC="$CROSSTOOLS/$b/bin/gcc"
            TARGET_CXX="$CROSSTOOLS/$b/bin/g++"
            export TARGET_CC TARGET_CXX
        else
            PKG_CONFIG_LIBDIR="/usr/${LIBDIRS[$b]}/pkgconfig"
            PKG_CONFIG_LIBDIR+=":$OOCEOPT/${LIBDIRS[$b]}/pkgconfig"
            export PKG_CONFIG_LIBDIR
        fi

        logcmd $CARGO build --release --target=${RUSTTRIPLETS[$b]} $@ \
            || logerr "build failed"

        popd >/dev/null

        hook post_build $b
    done
}

#############################################################################
# Build/test function for perl modules
#############################################################################
# Detects whether to use Build.PL or Makefile.PL
# Note: Build.PL probably needs Module::Build installed
#############################################################################

siteperl_to_vendor() {
    logcmd $MV $DESTDIR/$PREFIX/perl5/site_perl \
        $DESTDIR/$PREFIX/perl5/vendor_perl \
        || logerr "can't move to vendor_perl"
}

buildperl() {
    if [ -f "$SRCDIR/${PROG}-${VER}.env" ]; then
        logmsg "Sourcing environment file: $SRCDIR/${PROG}-${VER}.env"
        source $SRCDIR/${PROG}-${VER}.env
    fi
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logmsg "Building perl"
    if [ -f Makefile.PL ]; then
        make_clean
        makefilepl $PERL_MAKEFILE_OPTS
        make_arch $BUILDARCH
        [ -n "$PERL_MAKE_TEST" ] && make_param test
        make_pure_install
    elif [ -f Build.PL ]; then
        build_clean
        buildpl $PERL_MAKEFILE_OPTS
        build_prog
        [ -n "$PERL_MAKE_TEST" ] && build_test
        build_install
    fi
    popd > /dev/null
}

makefilepl() {
    logmsg "--- Makefile.PL"
    logcmd $PERL Makefile.PL $@ || logerr "Failed to run Makefile.PL"
}

buildpl() {
    logmsg "--- Build.PL"
    logcmd $PERL Build.PL prefix=$PREFIX $@ ||
        logerr "Failed to run Build.PL"
}

build_clean() {
    if [ -n "$CLEAN_SOURCE" ]; then
        CLEAN_SOURCE=
        return
    fi
    logmsg "--- Build (dist)clean"
    logcmd ./Build distclean || \
    logcmd ./Build clean || \
        logmsg "--- *** WARNING *** make (dist)clean Failed"
}

build_prog() {
    logmsg "--- Build"
    logcmd ./Build ||
        logerr "Build failed"
}

build_test() {
    logmsg "--- Build test"
    logcmd ./Build test ||
        logerr "Build test failed"
}

build_install() {
    logmsg "--- Build install"
    logcmd ./Build pure_install --destdir=$DESTDIR || \
        logmsg "Build install failed"
}

test_if_core() {
    logmsg "Testing whether $MODNAME is in core"
    logmsg "--- Ensuring ${PKG} is not installed"
    if logcmd $PKGCLIENT info -q ${PKG}; then
        logerr "------ Package ${PKG} appears to be installed.  Please uninstall it."
    else
        logmsg "------ Not installed, good."
    fi
    if logcmd $PERL -M$MODNAME -e '1'; then
        # Module is in core, don't create a package
        logmsg "--- Module is in core for Perl $DEPVER.  Not creating a package."
        exit 0
    else
        logmsg "--- Module is not in core for Perl $DEPVER.  Continuing with build."
    fi
}

#############################################################################
# Check for dangling symlinks
#############################################################################

check_symlinks() {
    logmsg "-- Checking for dangling symlinks"
    for link in `$FIND "$1" -type l`; do
        $READLINK -e $link >/dev/null || logerr "Dangling symlink $link"
    done
}

#############################################################################
# Add a component to a path
#############################################################################

addpath() {
    declare -n var=$1
    typeset val="$2"

    [ -n "$val" ] || return

    var+="${var:+:}$val"
}

#############################################################################
# Check that hardlinks are anchored for reproducible package builds
#############################################################################

check_hardlinks() {
    typeset manifest="$1"; shift
    typeset targets="$@"
    typeset -A tlookup

    logmsg "-- Checking hardlinks"

    for t in $targets; do
        t="`$REALPATH \"$DESTDIR/$t\"`"
        tlookup[$t]=1
    done

    hlf=`$MKTEMP`

    $NAWK '$1 == "hardlink" {
            path = ""
            for (i = 0; i <= NF; i++) {
                split($i, a, "=")
                key = a[1]; val = a[2]
                if (key == "path") {
                    dir = path = val
                    sub(/\/[^\/]*$/, "/", dir)
                }
                if (key == "target") {
                    if (val ~ /^\//)
                        print val, path
                    else
                        printf("%s%s %s\n", dir, val, path)
                }
            }
        }' < "$manifest" | while read link path; do
            flink="`$REALPATH \"$DESTDIR/$link\"`"
            logmsg "--- checking hardlink $link"
            [ -n "${tlookup[$flink]}" ] || echo "$link <- $path" >> $hlf
    done

    if [ -s $hlf ]; then
        logmsg "---"
        logmsg -e "These hardlinks do not have locked targets,"\
            "resulting in inconsistent builds."
        $CAT $hlf | while read hl; do
            logmsg -e "--- Unlocked hardlink: $hl"
        done
        logerr "---"
    fi

    logcmd $RM -f $hlf
}

#############################################################################
# Check for library ABI change
#############################################################################

extract_libabis() {
    declare -Ag "$1"
    local -n array="$1"
    local src="$2"

    while read file; do
        lib=${file%.so.*}
        abi=${file#*.so.}
        array[$lib]+="$abi "
    done < <($SED < "$src" '
        # basename
        s/.*\///
        # Remove minor versions (e.g. .so.7.1.2 -> .so.7)
        s/\(\.so\.[0-9][0-9]*\)\..*/\1/
        ' | $SORT | $UNIQ)
}

check_libabi() {
    local pkg="$1"
    local mf="$2"

    logmsg "-- Checking for library ABI changes"

    # Build list of libraries and ABIs from this package on disk
    $NAWK '
        $1 == "file" && $2 ~ /\.so\.[0-9]/ { print $2 }
    ' < $mf > $TMPDIR/libs.$$
    extract_libabis cla__new $TMPDIR/libs.$$
    logcmd $RM -f $TMPDIR/libs.$$

    [ ${#cla__new[@]} -gt 0 ] || return

    # The package has at least one library

    logmsg "--- Found libraries, fetching previous package contents"
    pkgitems -g $IPS_REPO $pkg | $NAWK '
            /^file path=.*\.so\./ {
                sub(/path=/, "", $2)
                print $2
            }
        ' > $TMPDIR/libs.$$
    [ -s $TMPDIR/libs.$$ ] || logerr "Could not retrieve contents"
    # In case the user chooses to continue after the previous error
    [ -s $TMPDIR/libs.$$ ] || return
    extract_libabis cla__prev $TMPDIR/libs.$$
    logcmd $RM -f $TMPDIR/libs.$$

    # Compare
    typeset change=0
    for k in "${!cla__new[@]}"; do
        [ "${cla__new[$k]}" = "${cla__prev[$k]}" ] && continue
        # The list of ABIs has changed. Make sure that all of the old versions
        # are present in the new.
        logmsg -n "--- $k ABI change, ${cla__prev[$k]} -> ${cla__new[$k]}"
        local prev new flag
        for prev in ${cla__prev[$k]}; do
            flag=0
            for new in ${cla__new[$k]}; do
                [ "$prev" = "$new" ] && flag=1
            done
            [ "$flag" -eq 1 ] && continue
            change=1
            logmsg -e "--- $k.so.$prev missing from new package"
        done
    done
    [ $change -eq 1 ] && logerr "--- old ABI libraries missing"
}

#############################################################################
# ELF operations
#############################################################################

strip_files() {
    [ -n "$SKIP_STRIP" ] && return
    local mode
    for f in "$@"; do
        mode=
        if [ ! -w "$f" ]; then
            mode=$($STAT -c %a "$f")
            logcmd $CHMOD u+w "$f" || logerr -b "chmod failed: $f (u+w)"
        fi
        logcmd $STRIP -x "$f" || logerr "strip $f failed"
        if [ -n "$mode" ]; then
            logcmd $CHMOD $mode "$f" || logerr -b "chmod failed: $f ($mode)"
        fi
    done
}

rtime_files() {
    local dir="${1:-$DESTDIR}"

    # `find_elf` invokes `elfedit` and expects it to be the illumos one.
    PATH=$USRBIN logcmd -p $FIND_ELF -fr $dir/ > $TMPDIR/rtime.files
}

rtime_objects() {
    typeset -i full=0
    [ "$1" = -f ] && full=1 && shift
    rtime_files "$@"
    if ((full)); then
        # OBJECT 32 DYN  NOVERDEF <path>
        # -> <path> <type> <bits>
        $NAWK '/^OBJECT/ { print $NF, $3, $2 }' $TMPDIR/rtime.files
    else
        $NAWK '/^OBJECT/ { print $NF }' $TMPDIR/rtime.files
    fi
}

strip_install() {
    logmsg "Stripping installation"

    pushd $DESTDIR > /dev/null || logerr "Cannot change to $DESTDIR"
    while read file; do
        logmsg "------ stripping $file"
        strip_files "$file"
    done < <(rtime_objects)
    popd > /dev/null
}

do_convert_ctf() {
    typeset file="$1"
    typeset mode=

    if [ ! -w "$file" -o -u "$file" -o -g "$file" -o -k "$file" ]; then
        mode=`$STAT -c %a "$file"`
        logcmd $CHMOD u+w "$file" || logerr -b "chmod u+w failed: $file"
    fi
    typeset tf="$file.$$"

    typeset flags="$CTF_FLAGS"
    [ -f $SRCDIR/files/ctf.ignore ] && flags+=" -M$SRCDIR/files/ctf.ignore"
    if logcmd $CTFCONVERT $flags -l "$PROG-$VER" -o "$tf" "$file"; then
        if [ -s "$tf" ]; then
            logcmd $CP "$tf" "$file"
            if [ -z "$BATCH" -o -n "$CTF_AUDIT" ]; then
                logmsg -n "$ctftag $file" \
                    "`$CTFDUMP -S $file | \
                    $NAWK '/number of functions/{print $6}'` function(s)"
            else
                logmsg "$ctftag converted $file"
            fi
        else
            logmsg "$ctftag no DWARF data $file"
        fi
    else
        logmsg -e "$ctftag failed $file"
        if [ -n "$CTF_AUDIT" ]; then
            logcmd $MKDIR -p $BASE_TMPDIR/ctfobj
            typeset f=${file:2}
            logcmd $CP $file $BASE_TMPDIR/ctfobj/${f//\//_}
        fi
    fi

    logcmd $RM -f "$tf"
    strip_files "$file"
    if [ -n "$mode" ]; then
        logcmd $CHMOD $mode "$file" || logerr -b "chmod failed: $file"
    fi
}

convert_ctf() {
    local dir="${1:-$DESTDIR}"

    logmsg "Converting DWARF to CTF (${dir##*/})"

    pushd $dir > /dev/null || logerr "Cannot change to $dir"

    local ctftag='---- CTF:'

    while read file; do
        if [ -f $SRCDIR/files/ctf.skip ] \
          && echo $file | $EGREP -qf $SRCDIR/files/ctf.skip; then
            logmsg "$ctftag skipped $file"
            strip_files "$file"
            continue
        fi

        if $CTFDUMP -h "$file" 1>/dev/null 2>&1; then
            continue
        fi

        do_convert_ctf "$file" &
        parallelise $LCPUS
    done < <(rtime_objects "$dir")
    wait

    popd >/dev/null
}

check_rtime() {
    logmsg "-- Checking ELF runtime attributes"
    rtime_files

    $CP $ROOTDIR/doc/rtime $TMPDIR/rtime.cfg
    [ -f $SRCDIR/rtime ] && $CAT $SRCDIR/rtime >> $TMPDIR/rtime.cfg

    logcmd $CHECK_RTIME \
        -e $TMPDIR/rtime.cfg \
        -E $TMPDIR/rtime.err \
        -f $TMPDIR/rtime.files

    if [ -s "$TMPDIR/rtime.err" ]; then
        $CAT $TMPDIR/rtime.err | pipelog
        logerr "ELF runtime problems detected"
    fi
}

check_ssp() {
    logmsg "-- Checking stack smashing protection"

    : > $TMPDIR/rtime.ssp
    while read obj; do
        [ -f "$DESTDIR/$obj" ] || continue
        nm $DESTDIR/$obj | $EGREP -s '__stack_chk_guard' \
            || echo "$obj does not include stack smashing protection" \
            >> $TMPDIR/rtime.ssp &
        parallelise $LCPUS
    done < <(rtime_objects)
    wait
    if [ -s "$TMPDIR/rtime.ssp" ]; then
        $CAT $TMPDIR/rtime.ssp | pipelog
        logerr "Found object(s) without SSP"
    fi
}

check_soname() {
    # Use with caution, shipped libraries should almost always be properly
    # versioned
    [ -n "$NO_SONAME_EXPECTED" ] && return
    [ "$GOOS/$GOARCH" = "illumos/amd64" ] && return

    logmsg "-- Checking for SONAME"
    typeset if=$SRCDIR/files/soname.ignore
    [ -f "$if" ] || if=
    : > $TMPDIR/rtime.soname
    while read obj type _; do
        [ -f "$DESTDIR/$obj" ] || continue
        case $type in
            EXEC)
                if $ELFEDIT -re 'dyn:tag needed' "$DESTDIR/$obj" \
                    | $EGREP 'NEEDED.*\.so$'; then
                    if [ -z "$if" ] || ! $EGREP -s "^${obj#/}\$" $if; then
                        echo "$obj has an unqualified dependency" \
                            >> $TMPDIR/rtime.soname
                    fi
                fi ;;
            DYN)
                if ! $ELFEDIT -re 'dyn:tag soname' "$DESTDIR/$obj" \
                    >/dev/null 2>&1; then
                    if [ -z "$if" ] || ! $EGREP -s "^${obj#/}\$" $if; then
                        echo "$obj is missing an SONAME" \
                            >> $TMPDIR/rtime.soname
                    fi
                fi ;;
        esac &
        parallelise $LCPUS
    done < <(rtime_objects -f)
    wait
    if [ -s "$TMPDIR/rtime.soname" ]; then
        $CAT $TMPDIR/rtime.soname | pipelog
        logerr "Found SONAME problems"
    fi
}

check_bmi() {
    [ -n "$BMI_EXPECTED" ] && return

    # In the past, some programs have ended up containing BMI instructions
    # that will cause an illegal instruction error on pre-Haswell processors.
    # We explicitly check for this in the elf objects.

    logmsg "-- Checking for BMI instructions"

    : > $TMPDIR/rtime.bmi
    while read obj; do
        [ -f "$DESTDIR/$obj" ] || continue
        $DIS $DESTDIR/$obj 2>/dev/null \
            | $RIPGREP -wq --no-messages 'mulx|lzcnt|shlx' \
            && echo "$obj has been built with BMI instructions" \
            >> $TMPDIR/rtime.bmi &
        parallelise $LCPUS
    done < <(rtime_objects)
    wait
    if [ -s "$TMPDIR/rtime.bmi" ]; then
        $CAT $TMPDIR/rtime.bmi | pipelog
        logerr "BMI instruction set found"
    fi
}

#############################################################################
# Check package licences
#############################################################################

check_licences() {
    typeset -i lics=0
    typeset -a errs
    typeset -i flag
    while read file types; do
        ((lics++))
        logmsg "-- licence '$file' ($types)"

        # Check if the "license" lines point to valid files
        flag=0
        for dir in $DESTDIR $TMPDIR/$EXTRACTED_SRC $SRCDIR; do
            if [ -f "$dir/$file" ]; then
                #logmsg "   found in $dir/$file"
                flag=1
                break
            fi
        done
        if [ $flag -eq 0 ]; then
            errs+=("Licence '$file' not found.")
            continue
        fi

        # Consolidate found licences into a temporary directory
        $MKDIR -p $BASE_TMPDIR/licences
        typeset lf="$BASE_TMPDIR/licences/$PKGD.`$BASENAME $file`"
        dos2unix "$dir/$file" "$lf"
        $CHMOD u+rw "$lf"

        [ -z "$FORCE_LICENCE_CHECK" -a -n "$BATCH" ] && continue

        _IFS="$IFS"; IFS=,
        for type in $types; do
            case "$type" in $SKIP_LICENCES) continue ;; esac

            # Check that the licence type is correct
            pattern="`$NAWK -F"\t+" -v type="${type%%/*}" '
                /^#/ { next }
                $1 == type { print $2 }
            ' $ROOTDIR/doc/licences`"
            if [ -z "$pattern" ]; then
                    errs+=("Unknown licence type '$type'")
                    continue
            fi
            if ! $RIPGREP -qU "$pattern" "$lf"; then
                errs+=("Wrong licence in mog for $file ($type)")
            fi
        done
        IFS="$_IFS"
    done < <($NAWK '
            $1 == "license" {
                if (split($0, a, /"/) != 3) split($0, a, "=")
                print $2, a[2]
            }
        ' $P5M_MOG)

    if [ "${#errs[@]}" -gt 0 ]; then
        for e in "${errs[@]}"; do
            logmsg -e $e
        done
        logerr ""
    fi

    if [ $lics -eq 0 ]; then
        logerr "-- No 'license' line in final mog"
        return
    fi
}

#############################################################################
# Clean up and print Done message
#############################################################################

clean_up() {
    logmsg "-- Cleaning up"
    if [ -z "$DONT_REMOVE_INSTALL_DIR" ]; then
        for dir in $DESTDIRS; do
            logmsg "--- Removing temporary install directory $dir"
            logcmd $CHMOD -R u+w $dir > /dev/null 2>&1
            logcmd $RM -rf $dir || \
                logerr "Failed to remove temporary install directory $dir"
        done
        logmsg "--- Cleaning up temporary manifest and transform files"
        logcmd $RM -f $P5M_GEN $P5M_GEN.raw $P5M_MOG \
            $P5M_DEPGEN $P5M_DEPGEN.res $P5M_FINAL \
            $MY_MOG_FILE $MANUAL_DEPS || \
            logerr "Failed to remove temporary manifest and transform files"
        logmsg "Done."
    fi
    return 0
}

#############################################################################
# Helper functions to save and restore variables and functions
#############################################################################

function_exists() {
    [ "`type -t $1`" = function ]
}

hook() {
    func=${1:?func}; shift
    function_exists $func || return 0
    logmsg "--- Callback $func($@)"
    $func "$@"
}

save_function() {
    local ORIG_FUNC=$(declare -f $1)
    local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
    eval "$NEWNAME_FUNC"
}

save_variable() {
    local var=$1
    local prefix=${2:-__save__}
    declare -g $prefix$var="$(declare -p $var)"
}

save_variables() {
    local var
    for var in $*; do
        save_variable $var
    done
}

restore_variable() {
    local var=$1
    local prefix=${2:-__save__}
    declare -n _var=$prefix$var
    #
    # At this point, _var may look something like one of the following,
    # depending on whether it is a scalar or array, for example:
    #     declare -- var=val
    #     declare -A var=([0]="val")
    # The first one is actually not valid syntax to use when replaying the
    # variable, and in all cases we want the new variable to end up with
    # global scope. Therefore the following two substitutions achieve this
    # so that '-g' is added and we do not have '--'.
    _var=${_var/#declare --/declare -}
    _var=${_var/#declare -/declare -g}
    eval "$_var"
}

restore_variables() {
    local var
    for var in $*; do
        restore_variable $var
    done
}

save_buildenv() {
    local opt
    for opt in $BUILDENV_OPTS; do
        save_variable $opt
    done
}

restore_buildenv() {
    local opt
    for opt in $BUILDENV_OPTS; do
        restore_variable $opt
    done
}

trim_variable() {
    local name=$1
    declare -n _var=$name
    while [[ "$_var" == ' '* ]]; do
        _var="${_var# }"
    done
    while [[ "$_var" == *' ' ]]; do
        _var="${_var% }"
    done
}

flatten_variable() {
    declare var=$1
    declare -n _var=$var
    typeset X="$_var"
    unset $var
    _var="${X## }"
}

flatten_variables() {
    local var
    for var in $*; do
        flatten_variable $var
    done
}

#
# This function takes an associative array which contains arch-specific keys
# and converts into a scalar variable that contains the base elements
# concatenated with those from the arch-specific portion.
# For example:
#
# With a CFLAGS variable like this:
#
#   CFLAGS=([0]="-O2 -g" [i386]="-m32" [amd64]="-m64")
#
# Calling `subsume_arch amd64 CFLAGS` would result in CFLAGS now being
#
#   CFLAGS="-O2 -g -m64"
#
# The resulting variable is also marked for export.
#
subsume_arch() {
    typeset arch=${1:?arch}; shift
    typeset var

    for var in $*; do
        declare -n _var=$var

        _var+=" ${_var[$arch]}"

        typeset X="$_var"
        unset $var
        export _var="${X## }"
    done
}

pkg_ver() {
    local src="$1"
    local script="${2:-build.sh}"

    src=$ROOTDIR/build/$src/$script
    [ -f $src ] || logerr "pkg_ver: cannot locate source"
    local ver=`$SED -n '/^VER=/ {
                s/.*=//
                p
                q
        }' $src`
    [ -n "$ver" ] || logerr "No version found."
    echo $ver
}

inherit_ver() {
    VER=`pkg_ver "$@"`
    logmsg "-- inherited version '$VER'"
}

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
