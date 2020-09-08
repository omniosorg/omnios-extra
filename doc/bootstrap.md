
# How to bootstrap extra

The packages in the extra repository have dependencies on each other,
sometimes circular, so bootstrapping the repository for a new OmniOS
release is a bit involved. This document describes the process that is
used, starting with an empty repository.

The packages are built and installed in several rounds.

### Preparation

Install the following packages from core:

* driver/tuntap
* library/unixodbc
* system/header/header-agp
* system/header/header-usb
* system/library/pcap

Add the following lines to the end of your `lib/site.sh`.

```
GZIP=gzip
BUNZIP2=bunzip2
```

### Round 1

Build some utilities:

* ooce/compress/pbzip2
* ooce/compress/pigz
* ooce/developer/cmake

Install:

```terminal
% pfexec pkg install 'ooce/*'
```

Remove the temporary lines from your `lib/site.sh`.

__Repeat the `pkg install` at the end of each round.__

### Round 2

* ooce/application/tidy
* ooce/database/bdb
* ooce/database/lmdb
* ooce/database/mariadb-104
* ooce/database/postgresql-12
* ooce/database/postgresql-common
* ooce/developer/ccache
* ooce/developer/cunit
* ooce/developer/gperf
* ooce/developer/ninja
* ooce/fonts/liberation
* ooce/library/apr
* ooce/library/fcgi2
* ooce/library/freetype2
* ooce/library/libev
* ooce/library/libexif
* ooce/library/libid3tag
* ooce/library/libidl
* ooce/library/libjpeg-turbo
* ooce/library/libmcrypt
* ooce/library/libogg
* ooce/library/libpng
* ooce/library/onig
* ooce/library/protobuf
* ooce/library/tiff
* ooce/multimedia/ffmpeg
* ooce/network/openldap
* ooce/runtime/node-12
* ooce/runtime/ruby-26
* ooce/text/asciidoc
* ooce/text/docbook-xsl
* ooce/x11/header/x11-protocols
* ooce/x11/header/xcb-protocols
* ooce/x11/library/xtrans
* ooce/x11/library/libxau

### Round 3

* ooce/library/fontconfig
* ooce/library/libvorbis
* ooce/library/slang
* ooce/audio/flac
* ooce/library/libvncserver
* ooce/library/apr-util
* ooce/library/security/libsasl2
* ooce/x11/library/libxcb
* ooce/developer/llvm-90
* ooce/developer/llvm-100

### Round 4

* ooce/library/libgd
* ooce/library/serf
* ooce/library/cairo
* ooce/x11/library/libx11
* ooce/server/apache-24
* ooce/developer/clang-90

### Round 5

* ooce/library/pango
* ooce/x11/library/libxfixes

### Round 6

* ooce/application/graphviz

### Rust

Bootstrap rust:

... TBC ...

* ooce/developer/rust
* ooce/util/fd
* ooce/util/jq
* ooce/text/ripgrep

### Go

Bootstrap go:

... TBC ...

* ooce/developer/go-114
* ooce/developer/go-115

### Freepascal

Bootstrap freepascal:

... TBC ...

* ooce/developer/freepascal

### Build stage 1

With the above pre-requisite packages installed, clear the repository and
do a full build.

### Build stage 2

Update all packages - `pkg update 'ooce/*'`
Clear the repository and do a full build.

