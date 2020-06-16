# Building OmniOS Packages
## Introduction
The purpose of this document is to introduce building packages for the "OmniOS Extra IPS Repository". 

The "OmniOS Extra IPS Repository" offers a simple way for administrators to install applications. Like everything else about the OmniOS Community Edition project, it is a volunteer effort. It is important to keep this in mind when reading this
document.

The "OmniOS Extra IPS Repository" is open to all, anyone may submit a new package, or volunteer to maintain an existing or un-maintained package. No special commit privileges are needed and [assistance](#omnios-community-support-channels) is available if needed.


### Prepare to build packages for OmniOS

1. [Requirements](#requirements)
2. [Create the build environment](#create-the-build-environment)
3. [Create a build directory and it's build files](#create-a-build-directory-and-its-build-files)
4. [Build the `helloworld` package](#build-the-helloworld-package)

### The "OmniOS Extra Build System"

1. [Package naming conventions](#package-naming-conventions)
2. [Structure of an OmniOS package](#structure-of-an-omnios-package)
3. [The `local.mog` and `lib/global-transforms.mog` files](#the-local-mog-and-lib-global-transforms-mog-files)
4. [Build and run dependencies](#build-and-run-dependencies)
5. [Configure directives](#configure-directives)
6. [Make directives](#make-directives)
7. [Linker directives](#linker-directives)
8. [Using your own functions in `build.sh`](#using-your-own-functions-in-build-sh)
9. [Creating patches](#creating-patches)
10. [SMF manifests](#smf-manifests)
11. [Providing messages at installation](#providing-messages-at-installation)
12. [Making the source available to the build environment](#making-the-source-available-to-the-build-environment)
13. [Managing licences](#managing-licences)
14. [Adding package information to the build system](#adding-package-information-to-the-build-system)
15. [The build system's default "IPS Repository"](#the-build-system-s-default-ips-repository)

### Tips for building specific types of packages

1. [Building packages that share common elements](#building-packages-that-share-common-elements)
2. [Tips for building libraries](#tips-for-building-libraries)
3. [Tips for Go packages](#tips-for-go-packages)
4. [Tips for Perl packages](#tips-for-perl-packages)
5. [Tips for Python packages](#tips-for-python-packages)
6. [Tips for Rust packages](#tips-for-rust-packages)

### Submit your package to the "OmniOS Extra IPS Repository"

1. [Create a "Pull Request" for the "OmniOS Extra IPS Repository"](#create-a-pull-request-for-the-omnios-extra-ips-repository)

### Getting Help

1. [OmniOS community support channels](#omnios-community-support-channels)
2. [Recommended reading](#recommended-reading)

# Prepare to build packages for OmniOS
The objective of this section is to prepare a build environment and introduce the `build.sh` and `local.mog` files. After this, an experimental build can be run with an example package.

1. [Requirements](#requirements)
2. [Create the build environment](#create-the-build-environment)
3. [Create a build directory and it's build files](#create-a-build-directory-and-its-build-files)
4. [Build the `helloworld` package](#build-the-helloworld-package)

## Requirements

To create packages for the "OmniOS Extra IPS Repository", the following is necessary:

* Virtual or  physical system running the latest OmniOS release, preferably the  latest ["Bloody Release"](https://omniosce.org/about/stablevsbloody).
* The system should have a minimum of 2GB of RAM.

* "OmniOS [Extra Build Tools](https://github.com/omniosorg/omnios-extra/blob/master/build/meta/extra-build-tools.p5m)" This can be installed with the following command:

```none
# pkg install ooce/extra-build-tools
```

* A [GitHub](https://github.com/) account.

## Create the build environment

### Fork the "OmniOS Extra IPS Repository"

If help is needed with this, please see: <https://help.github.com/en/github/getting-started-with-github/fork-a-repo>

### Create a local repository on the build system

In a suitable directory, clone the fork of the "OmniOS Extra IPS Repository", that was created in the previous step.

```none
$ git clone github.com/github_account/omnios-extra
$ cd omnios-extra
```

The "OmniOS Extra IPS Repository" consists of the following 4 directories:

| Directory | Purpose |
| :-------- | :------ |
| build | This is where all the build and associated files reside.
| doc | This is where auxiliary files reside, for the management of the "OmniOS Extra IPS Repository".
| lib | This is where the build system framework tools reside.
| tools | This is where auxiliary programs reside, for use in checking package builds. 

## Create a build directory and it's build files

In this section, the ubiquitous `helloworld` will be packaged for OmniOS.

### Create a `git branch` and a build directory

Before creating any new package, it is necessary to create a new `git branch` for it's build files. The reason being, is that when the package is later submitted for inclusion into the "OmniOS Extra IPS Repository", only a "Pull Request" from a `git branch` will be accepted.

Name the `git branch` after the package name.

```none
$ git branch helloworld
$ git checkout helloworld
```

To create the build directory for the `helloworld` package, create a new directory under the `build` directory in the cloned "OmniOS Extra IPS Repository".

```none
$ mkdir build/helloworld
$ cd build/helloworld
```

### Create the build files

Every package relies on 2 files to complete a build, `build.sh` & `local.mog`. These are created as follows:

```none
$ touch build.sh local.mog
$ chmod +x build.sh
```

As `build.sh` is a `bash` shell script, it is set as an executable.

Once these empty files are created, the following templates can be used to create the `helloworld` build files:

##### `build.sh`

```bash
# {{{
#
#!/usr/bin/bash
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright YYYY your name/organisation

. ../../lib/functions.sh

PROG=helloworld
VER=0.1
PKG=ooce/application/helloworld
SUMMARY="Hello, World! - A global salutation"
DESC="Hello, World! is a computer program that outputs the \
message 'Hello, World!'"

set_arch 64

set_mirror "https://pbdigital.org/ips-src/"
set_checksum sha256 "c6bdfebe1b9f27fc90a24348aa3492558d2bf5b0e2c366a9b6f9ec9f50b74917"

# create package functions
init
download_source $PROG $PROG $VER
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
```

##### `local.mog`

```bash
# {{{
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright YYYY your name/organisation

license LICENCE license=CDDL

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
```

The contents of these files will be discussed thoroughly in the ["OmniOS Extra Build System"](#the-omnios-extra-build-system) section.

## Build the `helloworld` package

For the `helloworld` package, the above `build.sh` & `local.mog` templates are enough to build the OmniOS package.

In fact, for a robust program like [tcpdump](https://github.com/omniosorg/omnios-extra/tree/master/build/tcpdump/build.sh), the `build.sh` was not much more complicated than the above templates. A lot of knowledge of the build system can be gained browsing the various `build.sh` files in the `build` directory.

From the current `helloworld` directory, the `helloworld` package can be built from the `build.sh` as follows:

```none
$ ./build.sh
```

**Note:** No special priveleges are need to create a package from the build system. Nor is it advised to create packages as the `root` user.

This will build the `hellowworld` package, through all it's various stages, terminating with the publishing of the `helloworld` package.

The default "IPS Repository", for the build system, that all packages will be published to, resides at the root directory of the cloned "OmniOS Extra IPS Repository". The root directory of this default "IPS Repository" is named `tmp.repo`.

### Installing the package

It is a good idea to install the package, to see the full process of the build system.

First, the build systems "IPS Repository" needs to be imported on the local system. This can be done by importing the `tmp.repo` as a secondary "OmniOS Extra IPS Repository". This can be achieved from the `helloworld` directory as follows:

```none
# pkg set-publisher -g ../../tmp.repo extra.omnios
```

Next, all that is needed, is to install the package:

```none
# pkg install helloworld
```

To verfify the complete build process, run the `helloworld` program.

```none
$ helloworld 
Hello, World!
```

### `./build.sh` options

To gain more control over the build procedure, many options have been added to the `build.sh` script. The following table displays these options:

| Option | Argument | Description |
| :----- |:-------- | :---------- |
|./build.sh -a | ARCH | build 32/64 bit only, or both (default: both)
|./build.sh -b | | batch mode (exit on errors without asking)
|./build.sh -c | | use 'ccache' to speed up (re-)compilation
|./build.sh -d | DEPVER | specify an extra dependency version (no default)
|./build.sh -D | | collect package diff output in batch mode
|./build.sh -f | FLAVOR | build a specific package flavor
|./build.sh -h | | print this help text
|./build.sh -i | | autoinstall mode (install build deps)
|./build.sh -l | | skip pkglint check
|./build.sh -L | | skip hardlink target check
|./build.sh -p | | output all commands to the screen as well as log file
|./build.sh -P | | re-base patches on latest source
|./build.sh -r | REPO | specify the IPS repo to use (default: file:///omnios-extra/tmp.repo/)
|./build.sh -t | | skip test suite
|./build.sh -s | | skip checksum comparison
|./build.sh -x | | download and extract source only
|./build.sh -xx | | as -x but also apply patches

Now is a good time to try out some of these options whilst building the `helloworld` package. 

### Uninstall and remove the `helloworld` package from the default "IPS Repository"

To uninstall the `helloworld` package and also remove the package from the "IPS Repository", issue the following commands from the `helloworld` build directory:

```none
# pkg uninstall helloworld
# pkgrepo -s ../../tmp.repo remove helloworld
```
## Conclusion

This concludes the introductory section. Next, much finer details of the "OmniOS Extra Build System" will be explored.

# The "OmniOS Extra Build System"
The "OmniOS Extra Build System" is a framework designed as a convenient and standardised manner to build IPS Packages for OmniOS. It is highly recommended to read [Packaging and Delivering Software with the Image Packaging System](https://github.com/OpenIndiana/oi-docs/blob/master/docs/dev/pdf/ips-dev-guide.pdf), to fully understand the finer details of the "OmniOS Extra Build System".

The main engine behind the "OmniOS Extra Build System" is the `lib/functions.sh` file. In this section, a best effort has been made to describe in detail the workings of the build system, however, if certains details have not been described sufficiently, it is advised to look at the code of `lib/functions.sh`, as well as [Packaging and Delivering Software with the Image Packaging System](https://github.com/OpenIndiana/oi-docs/blob/master/docs/dev/pdf/ips-dev-guide.pdf), to fill in the neccessary gaps.

1. [Package naming conventions](#package-naming-conventions)
2. [Structure of an OmniOS package](#structure-of-an-omnios-package)
3. [The `local.mog` and `lib/global-transforms.mog` files](#the-local-mog-and-lib-global-transforms-mog-files)
4. [Build and run dependencies](#build-and-run-dependencies)
5. [Configure directives](#configure-directives)
6. [Make directives](#make-directives)
7. [Linker directives](#linker-directives)
8. [Using your own functions in `build.sh`](#using-your-own-functions-in-build-sh)
9. [Creating patches](#creating-patches)
10. [SMF manifests](#smf-manifests)
11. [Providing messages at installation](#providing-messages-at-installation)
12. [Making the source available to the build environment](#making-the-source-available-to-the-build-environment)
13. [Managing licences](#managing-licences)
14. [Adding package information to the build system](#adding-package-information-to-the-build-system)
15. [The build system's default "IPS Repository"](#the-build-system-s-default-ips-repository)

## Package naming conventions

### Package catagories

Search [docs/baseline](https://github.com/omniosorg/omnios-extra/blob/master/doc/baseline) fot a list of package categories, to determine which best fits the package that is being built.

### Installation directories

#### Simple packages

Simple packages that do not include sub-directories such as `include`, `lib` & `share` can be installed directly into the root `/opt/ooce` directory. 

This can be done by omiting the `--prefix=` option in the `CONFIGURE_OPTS` directive of `build.sh`.

#### More complex packages

Other more complex packages should be installed under the `/opt/ooce/` directory. For example the PostgreSQL server is installed to `/opt/ooce/pgsql-12`

#### Multiple Versions

Further, the version number of the package should not be included unless more than one version of the software is being packaged.
The naming scheme with `application-x.y` symbolises that the application install directories contain a major version number. Meaning bugfix only releases would replace a previous version, but a new major version would NOT necessarily replace an existing one. Meaning you could install multiple versions of perl of python or even some obscure tool in parallel. The mediated symlinks allow you to coose the default version, but the other versions would still be accessible by using a direct path.

## Structure of an OmniOS package

The "OmniOS Extra Repository" contains prime quality packages to enhance your OmniOS system. The packages make full use of **SMF** and adhere to the `/opt` package structure. There is a separate "OmniOS Extra Repository" for each release of OmniOS.

### Directory structure

| Purpose | Location |
| :------ |:-------- |
| immutable package files | /opt/ooce/package(-x.y)
| configuraton files | /etc/opt/ooce/package(-x.y) 
| log files | /var/log/ooce/package(-x.y)
| other var files | /var/opt/ooce/package(-x.y)
| mediated symlinks provide access to binaries |  /opt/ooce/bin
| mediated symlinks provide access to manual pages |  /opt/ooce/share/man*


## The `local.mog` and `lib/global-transforms.mog` files

### `local.mog`

The `local.mog` file is a way to transform package manifests programatically. This allows you to transform the contents of the package in reliable and reapeatble ways. IPS uses `pkgmogrify` to achieve these changes.

In the `local.mog` file it is possible to change ownership and permissions on files, drop certain files from a package, make sure certain files do not get overwritten with newer versions. It also allows the creation of users and groups and even to adjust system services when a package has this requirement.

From the `build.sh` you can pass variables to `local.mog` with the following directive:

```none
XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVER=$VER
"
```

This allows `local.mog` to read in these variables, and later in the build proccess, for `pkgmogrify` to make transformations upon them.

An example of transformations possible are as follows:

```none
group groupname=$(PROG) gid=86
user ftpuser=false username=gitea uid=86 group=$(PROG) \
    gcos-field="Gitea - git with a cup of tea" \
    home-dir=/var/$(PREFIX) password=NP

<transform path=etc/$(PREFIX) -> set owner $(PROG)>
<transform path=etc/$(PREFIX) -> set group $(PROG)>
<transform file path=etc/$(PREFIX) -> set mode 0600>
<transform file path=etc/$(PREFIX) -> set preserve true>

<transform dir path=var/$(PREFIX) -> set owner $(PROG)>
<transform dir path=var/$(PREFIX) -> set group $(PROG)>

<transform dir path=var/$(PREFIX)/data -> set mode 0700>

<transform dir path=var/log/$(PREFIX) -> set owner $(PROG)>
<transform dir path=var/log/$(PREFIX) -> set group $(PROG)>

```

All these directives will be processed via the `pkgmogrify` utility.

The first is of particular interest as it creates a new user and group for the system. 

Following this, is mainly setting ownership and permissions on files. 

However of note, the line with `set preserve true` tells the build system not to overwrite files in the corresponding directory. In this case, old files will be left untouched and new files will be added with the prefix `.new`

It is beyond the scope of this document to describe in full detail the workings of how `pkgmogify` deals with the `local.mog` file, therefore it is recommended to read in detail Chapter 8 of [Packaging and Delivering Software with the Image Packaging System](https://github.com/OpenIndiana/oi-docs/blob/master/docs/dev/pdf/ips-dev-guide.pdf), to best take advantage of the `local.mog` file.

### `lib/global-transforms.mog`

The "Omnios Build System" will automatically apply a number of transformations to a package being created via the `lib/global-transforms.mog` file. It is reccommended to study this file to appreciate, which changes are being made. 


## Build and run dependencies
### Build Dependencies

Insert the following into `build.sh` to define the necessary programs to complete the build process.

```none
BUILD_DEPENDS_IPS+="
    ooce/package/name1
    ooce/package/name2
    ooce/package/name3...
"
```
Anything from the base install or the meta packages [extra-build-tools](https://github.com/omniosorg/omnios-extra/blob/master/build/meta/extra-build-tools.p5m) & [omnios-build](https://github.com/omniosorg/omnios-extra/blob/master/build/meta/omnios-build-tools.p5m) should not need to be included.

### Optional Build Dependencies

If a package dependency is required to build the package but is not necessary to install the package, this can be dropped when the software is packaged, via a `final.mog`. 

Include the package as normal in `BUILD_DEPENDS_IPS` directive and then use the following in the `build.sh`:

```none
make_package local.mog final.mog
```

Also, include a `final.mog` file in the base of the package directory, with contents similar to below:

```none
# Remove the automatically detected 'require' dependencies.
# Optional dependencies have already been explicitly added.
<transform depend type=require fmri=.*(?:mariadb|postgresql) -> drop>
```

For an example see [here](https://github.com/omniosorg/omnios-extra/tree/master/build/nagios-plugins).

### Run dependencies

Almost all run dependencies should be auto-detected. It's better to let this happen than to hard code it. If it is absolutely necessary to define run dependencies, the directive that is placed in `build.sh` is as follow:

```none
RUN_DEPENDS_IPS+="
    ooce/package/name1
    ooce/package/name2
    ooce/package/name3...
"
```
## Configure directives

Default configure flags are set in the `lib/config.sh` file. These may be overridden or appended to, with the `CONFIGURE_OPTS` directive. An example follows:

```none
CONFIGURE_OPTS+="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
    --with-lockfile=/var$PREFIX/run/$PROG.lock
    --with-logfile=/var/log$PREFIX/$PROG.log
    --enable-openssl
"
```
These will be applied to the `CONFIGURE_CMD` for **both** 32 and 64 bit builds.

Architecture independent configure flags may also be set with the `CONFIGURE_OPTS_32` and `CONFIGURE_OPTS_64` directives.

`libs/fuctions.sh` can provide a working example of how these directives are applied.

## Make directives

Make directives may also be set and overridden in `build.sh`. Follows are possible use cases:

#### Supplying arguments to make:

```none
MAKE_INSTALL_ARGS="
    COMMAND_OPTS=
    INSTALL_OPTS=
"
```

#### Determining make targets:

```none
MAKE_INSTALL_TARGET="
    install
    install-commandmode
    install-config
"
```

Like the `CONFIGURE_OPTS` directive, these apply to **both** 32 and 64 bit builds.

Architecture independent configure flags may also be set with the `MAKE_INSTALL_XXXXXX_32` and `MAKE_INSTALL_XXXXXX_64` directives.

`libs/fuctions.sh` can provide a working example of how these directives are applied.

## Linker directives

CFLAGS/LDFLAGS directives may also be set in `build.sh`. Follows are possible use cases:

```none
CFLAGS+=" -O3 -I$OPREFIX/include -I/usr/include/gssapi"
CXXFLAGS32+=" $CFLAGS $CFLAGS32 -R$OPREFIX/lib"
CXXFLAGS64+=" $CFLAGS $CFLAGS64 -R$OPREFIX/lib/$ISAPART64"
LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
```

Like the `CONFIGURE_OPTS` directive, the directives without the architecture prefix, apply to **both** 32 and 64 bit builds.

Architecture independent configure flags have also been set in the above example with the `XXFLAGS32` and `XXFLAGS64` directives.

`libs/fuctions.sh` can provide a working example of how these directives are applied.

## Using your own functions in `build.sh`

Sometimes it is not possible for the build system to cater for all events, when building a package. However, within `build.sh`, it is possible to create functions to deal with situations as they arise.

For example, when building a package that has no `./configure` or `make` processes, it is possible to override the main build function as follows:

```none
build() {
    logcmd mkdir -p $DESTDIR/$PREFIX/nagios/nrdp || logerr "mkdir"
    logcmd cp -r $TMPDIR/$BUILDDIR/server/* $DESTDIR/$PREFIX/nagios/nrdp \
        || logerr "cp -r server failed"
}
```

In the above example, the package being built is from *PHP* source code. There is no `./configure` or `make` processes and the contents can simply be copied into the `$DESTDIR` and then packaged by the build system.

This is a case of overriding a function, however it is also possible to create any functions that are necessary and place them in the right order amongst the "build fuctions" of the `build.sh` file.

The best source for discovering more about using your own functions, is to browse the `build.sh` of other packages.

## Creating patches

### Patches directory and contents

If it is neccessary to supply patches for the build to complete, these go in the sub-directory `patches` of the `build/package-name` directory.

Generally, one patch should be created for each functional change.. The following command should be sufficient to create a patch. 

```none
$ gdiff -wpruN '--exclude=*.orig' a~/ a/ > description-of-patch.patch
```
The patching may take place in the `build/package-name/tmp` directory, however the final patches must be transferred to the `patches` directory. 

The filename of the patch should then be `echo`'d into a file named `series`, that resides in the `patches` directory. The file `series`, is used by the build system to apply the patches that are listed in this file. This is done in the order of the patches listed, so care must be taken, to list patches in order, as necessary for the build to complete,

```none
$ echo description-of-patch.patch >> series
```

### Re-basing patches to ensure the correct format

To ensure the patches are in the standard format for the build system, it is advised to run an automatic re-base. This can be achieved with the following command:

```none
./build.sh -Pxx
...
...
...
Checking for patches in patches/ (in order to re-base them)
Re-basing patches
--- Applied patch Makefile.patch
Checking for patches in patches/ (in order to apply them)
Applying patches
--- Applied patch Makefile.patch
Time: ooce/application/package-name - 0h0m4s
```

The output from the command demonstrates that the patches have been re-based correctly.

## SMF manifests

The "Service Management Facility" (SMF) replaces `init.d` scripts in OmniOS (and other illumos based distributions). SMF creates a unified model for services and service management.

If it is neccessary to include an SMF manifest with the package, the associated *Manifest* & *Method* files should be placed in the `files` sub-directory of the `build/package-name` directory. 

It is preferably, however not always possible, that only a *Manifiest* file should be included.

Once the associated SMF files have been placed in the `files` sub-directory, the `build.sh` can be instructed to process these files with the following directive:

```none
install_smf application $PROG.xml application-$PROG
```

This should be placed after the "build function" declarations and before the `make package` declaration.


It is beyond the scope of this document to describe in full detail the workings of SMF, therefore it is highly recommended that you download and read "[Management of Systems and Services with Solaris Service Management Facility](https://www.oracle.com/technetwork/server-storage/solaris10/solaris-smf-wp-167901.pdf)".

## Providing messages at installation

When providing a package which requires manual integration steps, it may be necessary to inform the end user of this situation. IPS has a facility to display a message during package installation to inform the end user of any important considerations that should be taken. 

This is done by creating a text file and placing it in the `files` sub-directory of the `build/package-name` directory. An example text file that informs an end user, that they must read the installed `IMPORTANT.txt` file, would be similar to the following:

#### README

```none
------------------
Installation Notes
------------------

For instructions on how to configure and integrate 
this program with the system, please read 
/opt/ooce/package-name/share/IMPORTANT.txt

------------------
```

Once this `README` file has been placed in the `files` sub-directory, the `build.sh` can be instructed to process this file with the following directive:

```none
add_notes README
```

This should be placed after the "build function" declarations and before the `make package` declaration.

## Making the source available to the build environment

### Source tarballs via a mirror

#### Mirrors:

The omnios-extra build system has a mirror at https://mirrors.omniosce.org/ that maintains current source tarballs and checksums. It uses these to build it's packages. In the early stages of a build, this source tarball will not be available on the OmniOS mirror, and will be need to be made available for the build process.

This can be done by using the `set_mirror` directive in `build.sh`. For example the source tarball for "Apache httpd 2.4.43" is available at the mirror: <https://downloads.apache.org/>. Therefore the `set_mirror` directive should be as follows:

```none
set_mirror "https://downloads.apache.org/"
```
Further in the `build.sh` file, the `download_source` directive should be as follows:

```none
download_source $PROG $PROG $VER
```

#### Checksums:

The above will be sufficient if the accompanying sha256 checksum file is available in the same directory as the tarball. 

If the checksum is not available, this can be included in the `build.sh` with the `set_checksum` directive. For example, had the "Apache httpd 2.4.43" checksum file not been available, the following `set_checksum` should be set:

```none
set_checksum sha256 "a497652ab3fc81318cdc2a203090a999150d86461acff97c1065dc910fe10f43"
```

### Source tarballs via GitHub

#### GitHub releases:

If the source tarball is on github, the following directive should be used:

```none
set_mirror "$GITHUB/apache/$PROG/archive"
```

Further in the `build.sh` file, the `download_source` directive should be as follows:

```none
download_source $VER
```

> **NOTE:** Downloading from GitHub always seems to be a moving target. See the [Exceptional cases regarding source tarballs](#exceptional-cases-regarding-source-tarballs) section to help troubleshoot `download_source` problems.

#### Checksums:

GitHub does not supply checksums for downloaded archives, so this can be workd around with the following directive:

```none
set_checksum "none"
```

### Exceptional cases regarding source tarballs


#### Source tarball

Sometimes the source tarball is not in a standard format and the argument to the directive, `download_source`, will need to be edited accordingly.

#### Build Directory

Sometimes the tarball will extract to an un-expected directory. For example, sometimes a tarball named `$PROG-$VER.tar.gz` may extract to a directory named `$PROG-$PROG-$VER`.

In this case, use the `BUILDDIR` directive, as follows:

```none
set_builddir "$PROG-$PROG-$VER" 
```

#### Source Directory

Sometimes the source directory, where the `configure` script lies will not be where it is expected. For example, the `configure` script may not be in the root of the `$PROG-VER/` directory, but instead in `$PROG-VER/$PROG/`.

In this case. the above `set_builddir` should also take care of this.

## Managing licences

### Bundling a licence with the package

All packages must be bundled with their respective licence. To add a licence to the package being built, the licence must be included in the `local.mog` file. This is generally always the last line of text in the `local.mog` file and appears as follows:

```none
license COPYING license=GPLv3
```

### How the build system determines the licence type

The utility, `tools/licence`, is used to determine the specific type of licence. To manually determine the licence that is bundled with the package run the following:

```none
$ tools/licence build/package/tmp/path/to/LICENCE
```

This will return the licence type.

### Licence definitions

Licence definitions can be viewed in `doc/licences`.

These definitions cover most open source licences. 

If the licence is not detected, it is possible to use the `SKIP_LICENCES` directive, followed by the licence type, in `build.sh`. For example:

```none
SKIP_LICENCES="Sleepycat"
```

### When a package is released under various licences

In this case, it is possible to use the `SKIP_LICENCES` directive as follows:

```none
SKIP_LICENCES=Various
```
The corresponding entry in the `local.mog` would appear similar as follows:

```none
license LICENSE.adoc license=Various
license GPL-3.0.txt license=GPLv3
```

### When no licence is supplied in the source tarball

It is possible to write a function in `build.sh`, to extract licence information in the source, if it is available.

An [example function](https://github.com/omniosorg/omnios-extra/blob/master/build/fcgiwrap/build.sh) to extract the licence is as follows:

```none
extract_licence() {
    logmsg "-- extracting licence"
    pushd $TMPDIR/$BUILDDIR > /dev/null
    sed '/^$/q' < $PROG.c > LICENCE
    popd > /dev/null
}
```

The licence may then be determined by the `tools/licence` utility.

### When all else fails

As a last resort, you may consider modifying the licence definition pattern in `doc/licences`. **You will need to let the maintainers explicitly aware of any changes to this file.**

## Adding package information to the build system

To keep the "OmniOS Build System" up-to-date, new packages need to be added to files in the `doc/` directory. This is intuitive and can be achieved by simply browsing the files that need to be changed and then edit according, with details from the package that is being added.

The files that need editing are:

* `docs/baseline`
* `docs/packages.md`

## The build system's default "IPS Repository"

The default “IPS Repository”, for the build system, that all packages will be published to, resides at the root directory of the cloned “OmniOS Extra IPS Repository”. The root directory of this default “IPS Repository” is named `tmp.repo`.

The build systems “IPS Repository” may be imported on the local system. This is done by importing the `tmp.repo` as a secondary “OmniOS Extra IPS Repository”. This can be achieved as follows:

```none
# pkg set-publisher -g /path/to/github/repos/omnios-extra/tmp.repo extra.omnios
```

With this set, the list of publishers should look similar to the following:

```none
$ pkg publisher
PUBLISHER                   TYPE     STATUS P LOCATION
omnios                      origin   online F https://pkg.omniosce.org/bloody/core/
extra.omnios                origin   online F file:///path/to/github/repos/omnios-extra/tmp.repo/
extra.omnios                origin   online F https://pkg.omniosce.org/bloody/extra/
```

# Tips for building specific types of packages
1. [Building packages that share common elements](#building-packages-that-share-common-elements)
2. [Tips for building libraries](#tips-for-building-libraries)
3. [Tips for Go packages](#tips-for-go-packages)
4. [Tips for Perl packages](#tips-for-perl-packages)
5. [Tips for Python packages](#tips-for-python-packages)
6. [Tips for Rust packages](#tips-for-rust-packages)

## Building packages that share common elements

When building a package for software that has many components, it may arise that the software should be split into seperate packages. This presents a problem, when these packages share common elements, for example; the same user or directory strucure.

The way to deal with this is to create a "*Common Package*" that the other packages can share. 

A common package is simply a `.mog` file placed in the build directory of the main package that you are building. For example, the *Nagios* package, a `.mog` file named `nagios-common.p5m` is placed in the main build directory `build/nagios`. This file details the common elements shared with all the other *Nagios* packages.

For the build system to recognise this file, this *Common Package* should be added **only** to the `doc/baseline` file. This should not be added to `doc/packages.md`.

Examining the contents of `nagios-common.p5m` and other `xxxxxx-common.p5m` files should give you a better understanding to contributing these types of packages.

## Tips for building libraries

Building libraries follows the same outline as building packages, however there are a few extra considerations that need to be applied.

### Build for both 32 & 64 bit

Libraries are built for both 32 & 64 bit architectures. This just requires omiting the `set_arch 64` directive from the standard `build.sh` file, that has been demonstrated in the "[Create a build directory and it's build files](https://gitea.bcn.pbdigital.org/philip/knowledge-base/wiki/Omnios%3A-Extra-Build-Packages#user-content-create-a-build-directory-and-its-build-files)" section.

### Drop 32 bit binaries

If a library installs 32 bit binaries, it is necessary to drop these before building the package. This can be set in the `local.mog` file, of the library being built. 

This should be possible to achieve, with a statment in the `local.mog` file, similar to the following:

```
# Drop 32bit binaries
<transform path=$(PREFIX)/s?bin/i386 -> drop>
```

### Adding library information to the build system

Similar to how information is added to `doc/...` files, when building a standard package, library packages need also to add information to the meta package `extra-build-tools`. Therefore the `build/meta/extra-build-tools.p5m` file will need editing.

The complete list of files that need editing are:

* `build/meta/extra-build-tools.p5m`
* `docs/baseline`
* `docs/packages.md`

## Tips for Go packages

Coming Soon! In the meantime, [browse the build scripts of GO packages in the repository](https://github.com/omniosorg/omnios-extra/search?q=GO&unscoped_q=GO).

## Tips for Perl packages

Coming Soon! In the meantime, [browse the build scripts of Perl packages in the repository](https://github.com/omniosorg/omnios-extra/search?q=perl&unscoped_q=perl).

## Tips for Python packages

Coming Soon! In the meantime, [browse the build scripts of Python packages in the repository](https://github.com/omniosorg/omnios-extra/search?q=python&unscoped_q=python).

## Tips for Rust packages

Coming Soon! In the meantime, [browse the build scripts of Rust packages in the repository](https://github.com/omniosorg/omnios-extra/search?q=rust&unscoped_q=rust).


# Submit your package to the "OmniOS Extra IPS Repository"

## Final tasks before submitting a package

* Make sure that the package has been added to `docs/baseline`

* Make sure that the package has been added to `docs/packages.md`

* If the package is a library, make sure that it has been added to `build/meta/extra-build-tools.p5m`

## Create a "Pull Request" for the "OmniOS Extra IPS Repository"

Once work has been completed for a new package, the `git branch` will be needed to be pushed to the fork of the "OmniOS Extra IPS Repository" that was created in the [first section](#create-the-build-environment).

The procedure to update the fork is as follows:

```none
git add *
git status
git commit -m 'name of package and version number'
git push --set-upstream origin `git-branch`
```

After the initial commit of the `git-branch` has been uploaded, it is possible to omit the `--set-upstream` option from subsequent updates. This is demonstrated below:

```none
git push origin `git-branch`
```

Viewing the new branch online at <https://github.com>, it is now possible to create a new pull request. To the right of the "Branch" menu, click "New pull request" to submit the new package to OmniOS. 

## Keeping updated with upstream omnios-extra

If there have been commits upstream on the original master, after cloning the fork, it is necessary to ensure that the local repository is up-to-date with the remote master. This is done by first updating the local repository that has been cloned from the fork, and then, updating the fork with the newly updated local repository.

### Updating local repository with upstream remote

First determine if the upstream `omniosorg/omnios-extra` repository is set as a remote.

```none
git remote -v
```

If the upstream `ominosorg/omnios-extra` repository is not set, add this with the following command:

```none
git remote add upstream https://github.com/omniosorg/omnios-extra.git
```

Now confirm that the remote upstream `ominosorg/omnios-extra` repository  is set.

```none
git remote -v
```

To pull all the data from the remote into the local repository. Use the `fetch` and `merge` subcommands. Before doing this, check that the current branch is set to `master`.

```none
git checkout master
git pull upstream master
```

**git fetch** only downloads new data from a remote repository - but it doesn't integrate any of this new data into the working files. 

**git merge** is where the fetched data is pulled into the working files.

After executing the above commands only the local repository will be up-to-date with the remote upstream `omniosorg/omnios-extra` repository. 

### Updating GitHub fork with local repository

Once the local repository is up-to-date, it is recommended to push this local repository to GitHub so that the fork of `omniosorg/omnios-extra` is also up-to-date.

```none
git checkout master
git push
```

## Getting help

1. [OmniOS community support channels](#omnios-community-support-channels)
2. [Reccomended reading](#recommended-reading)

### OmniOS community support channels

* **Gitter:** Connect to the web-based [chat room on Gitter](https://gitter.im/omniosorg/Lobby).
* **IRC:**  Join the [#omnios channel on Freenode](http://webchat.freenode.net/?randomnick=1&channels=%23omnios&uio=d4).
* **Mailing list:** general discussion and queries, please subscribe to the [omnios-discuss mailing list](https://illumos.topicbox.com/groups/omnios-discuss).

### Recommended reading

* [Packaging and Delivering Software with the
Image Packaging System](https://github.com/OpenIndiana/oi-docs/blob/master/docs/dev/pdf/ips-dev-guide.pdf)
* [Management of Systems and Services with Solaris Service Management Facility](https://www.oracle.com/technetwork/server-storage/solaris10/solaris-smf-wp-167901.pdf)

