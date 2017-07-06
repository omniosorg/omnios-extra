
# Keeping up-to-date with upstream Joyent gate for LX Zones.

## Initial repository configuration

This process is easier if you set up a git remote called *upstream_joyent*

```shell
$ git remote add -t master upstream_joyent https://github.com/joyent/illumos-joyent
$ git remote -v
origin  https://github.com/omniosorg/illumos-omnios.git (fetch)
origin  https://github.com/omniosorg/illumos-omnios.git (push)
upstream        https://github.com/illumos/illumos-gate (fetch)
upstream        https://github.com/illumos/illumos-gate (push)
upstream_joyent https://github.com/joyent/illumos-joyent (fetch)
upstream_joyent https://github.com/joyent/illumos-joyent (push)
```

## Check out and update the upstream_joyent branch

```shell
$ git checkout upstream_joyent
Branch upstream_joyent set up to track remote branch upstream_joyent from origin.
Switched to a new branch 'upstream_joyent'
$ git pull upstream_joyent master
remote: Counting objects: 42002, done.
remote: Total 42002 (delta 16751), reused 16751 (delta 16751), pack-reused 2525
Receiving objects: 100% (42002/42002), 16.28 MiB | 660.00 KiB/s, done.
Resolving deltas: 100% (32123/32123), completed with 3089 local objects.
From https://github.com/joyent/illumos-joyent
 * branch                  master     -> FETCH_HEAD
 * [new branch]            master     -> upstream_joyent/master
Updating f6eee9d5d9..75647a9226
Checking out files: 100% (2179/2179), done.
Fast-forward
... lots of output ...

$ git status .
On branch upstream_joyent
Your branch is ahead of 'origin/upstream_joyent' by 260 commits.
```

## Retrieve a list of commits since the last cherry-pick session

```
$ export PORT_DATA=/path/to/lx-port-data
$ git show master:README.OmniOS | grep 'Last illumos-joyent'
Last illumos-joyent commit:  b29bd3a941d640162496a2ab849fd84ca5dd6cf5
$ git log --reverse --no-merges --format=%H b29bd3a941d640162496a2ab849fd84ca5dd6cf5.. > $PORT_DATA/ij-ALL-commits
$ wc -l $PORT_DATA/ij-ALL-commits
     240 .../omniosorg/lx-port-data/ij-ALL-commits
```

In this example, there have been 240 commits to illumos-joyent since the last
session.

## Remove commits which are also in `illumos-gate`

```
$ git log master --format=%H > $PORT_DATA/ij-GATE-commits
$ fgrep -v -f $PORT_DATA/ij-GATE-commits $PORT_DATA/ij-ALL-commits > $PORT_DATA/ij-TODO-commits
$ wc -l  $PORT_DATA/ij-TODO-commits
      42 .../omniosorg/lx-port-data/ij-TODO-commits
```

In this example, that leaves 42 commits which need to be reviewed.

## Create new branch for picked changes

Create a new branch into which the upstream changes will be merged in order
to create a pull request. The branch name should be
_joyent-merge/YYYYMMMMDDnn_ where _nn_ starts at 01 and is incremented in
the case that there is more than one merge in the same day.

```shell
$ git checkout master
$ git checkout -b joyent-merge/2017070501
Switched to a new branch 'joyent-merge/2017070501'
```

## Evaluate each change in turn and choose whether to pick it or not

Run $PORT_DATA/cherry-pick-or-not.sh until there are no more commits
left.

An example where the commit is not picked:

```
$ $PORT_DATA/cherry-pick-or-not.sh
commit d7b3c0f0f9f6c7bd9fbafc475db0d96a54372712
Author: Jerry Jelinek <jerry.jelinek@joyent.com>
Date:   Mon May 15 20:33:11 2017 +0000

    OS-6080 xsave area should size dynamically, based on CPU features
    Reviewed by: Patrick Mooney <patrick.mooney@joyent.com>
    Reviewed by: Robert Mustacchi <rm@joyent.com>
    Approved by: Patrick Mooney <patrick.mooney@joyent.com>

 usr/src/uts/common/os/lwp.c           |   2 +
 usr/src/uts/common/sys/proc.h         |   3 +-
 usr/src/uts/i86pc/os/cpuid.c          |  18 ++++--
 usr/src/uts/i86pc/os/fpu_subr.c       |  13 +++++
 usr/src/uts/i86pc/os/machdep.c        |  15 ++++-
 usr/src/uts/intel/ia32/ml/exception.s |  13 ++++-
 usr/src/uts/intel/ia32/ml/float.s     |  13 ++++-
 usr/src/uts/intel/ia32/os/archdep.c   |   8 +--
 usr/src/uts/intel/ia32/os/fpu.c       | 103 +++++++++++++++++++++++++++-------
 usr/src/uts/intel/ia32/os/sundep.c    |   3 +
 usr/src/uts/intel/sys/archsystm.h     |   3 +-
 usr/src/uts/intel/sys/fp.h            |  17 ++++--
 usr/src/uts/intel/sys/x86_archext.h   |   1 +
 usr/src/uts/sun4/os/machdep.c         |   7 ++-
 14 files changed, 174 insertions(+), 45 deletions(-)
Cherry pick it (Y/N)? n
GOING TO SKIP!
Skipping this one.
```

An example where the commit is picked:

```
$ $PORT_DATA/cherry-pick-or-not.sh
commit 53a0277a783c79b2844aa7076272176a0dacc7a7
Author: Jerry Jelinek <jerry.jelinek@joyent.com>
Date:   Thu May 25 18:23:57 2017 +0000

    OS-6144 WARNING: Sorry, no swap space to grow stack for pid XXX (zsched)
    Reviewed by: Patrick Mooney <patrick.mooney@joyent.com>
    Approved by: Patrick Mooney <patrick.mooney@joyent.com>

 usr/src/uts/common/brand/lx/os/lx_misc.c | 47 ++++++++++++++++++++------------
 1 file changed, 29 insertions(+), 18 deletions(-)
Cherry pick it (Y/N)? y
GOING TO CHERRYPICK!
[joyent-merge/2017070501 251767c008] OS-6144 WARNING: Sorry, no swap space to grow stack for pid XXX (zsched) Reviewed by: Patrick Mooney <patrick.mooney@joyent.com> Approved by: Patrick Mooney <patrick.mooney@joyent.com>
 Author: Jerry Jelinek <jerry.jelinek@joyent.com>
 Date: Thu May 25 18:23:57 2017 +0000
 1 file changed, 29 insertions(+), 18 deletions(-)
You're on your own now.
```

If the merge fails, you will have to manually resolve it before proceeding
to the next commit.

You will eventually reach the end of the commit list and see:

```
$ $PORT_DATA/cherry-pick-or-not.sh
.../omniosorg/lx-port-data/ij-TODO-commits appears to be empty.
You're done.
```

## Review the picked commits

```
$ git log master..joyent-merge/2017070501
commit b65a9aa485d05afac59e5eb341bc3485eeae1159 (HEAD -> joyent-merge/2017070501)
Author: Jerry Jelinek <jerry.jelinek@joyent.com>
Date:   Thu Jun 29 15:59:17 2017 +0000

    OS-6213 improve LX autofs error handling
    Reviewed by: Patrick Mooney <patrick.mooney@joyent.com>
    Reviewed by: Hans Rosenfeld <hans.rosenfeld@joyent.com>
    Approved by: Patrick Mooney <patrick.mooney@joyent.com>

commit 569f5814467e2b4339fc3f7c399843842f7e9964
Author: Jerry Jelinek <jerry.jelinek@joyent.com>
Date:   Fri Jun 23 13:56:58 2017 +0000

    OS-6202 fdisk -l core dumps in CentOS 7
    Reviewed by: Patrick Mooney <patrick.mooney@joyent.com>
    Approved by: Patrick Mooney <patrick.mooney@joyent.com>

... elided ...
```

## Perform a test build

```shell
$ nightly /path/to/omnios.env
```

If the build is unsuccessful, resolve this before moving on to the next
step.

## Update the last commit version in README.OmniOS

Modify the README.OmniOS file in the upstream branch to reflect the latest
Joyent commit which has been evaluated. This will be part of the pull
request.

## Push the merged branch

```shell
$ git push --set-upstream origin joyent-merge/2017070501
```

## Create a pull request

Use the Github web-interface to create a pull request from the new
joyent-merge branch to the master. Take care to change the _base fork_
value to _omniosorg/master_ as it will default to the upstream OmniTI
repository.

* Include the `mail_msg` file from the test build;
* Review the list of commits included in this merge and include any which
are backport candidates in the description of the PR. If there are none
state that too;
* Assign reviewers and the _upstream-merge_ tag.

## Archive the working files for future reference

```
$ cd $PORT_DATA
$ mkdir 2017/Jul05
$ mv ij-* 2017/Jul05
$ git add 2017/Jul05
$ git commit -m 'Updated LX port data for Jul05'
```



