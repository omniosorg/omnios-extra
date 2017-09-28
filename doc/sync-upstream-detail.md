[omniutil]: https://github.com/omniosorg/omni/

# Upstream Sync Process

This document details the steps required to keep `illumos-omnios`
up-to-date with the upstream `illumos-gate` and `illumos-joyent`
repositories. For each step, the full commands are included for
reference but many can be performed more easily using the
[omni utility][omniutil].

`omni` commands are shown prefixed with a 
![#f03c15](https://placehold.it/15/1589f0/000000?text=+) symbol.

## Initial repository configuration

If you haven't already, fork the
[omnisorg/illumos-omnios](https://github.com/omniosorg/illumos-omnios)
and
[omnisorg/omnios-build](https://github.com/omniosorg/omnios-build)
repositories to your personal GitHub profile.

The easiest way to then check out and configure the initial repository clones
is via the [omni utility][omniutil] setup process.

For reference, this performs the following steps for `illumos-omnios`:

```
$ git clone git@github.com:<github_name>/illumos-omnios.git
$ git remote add upstream git@github.com:omniosorg/illumos-omnios.git
$ git remote add -t master upstream_gate https://github.com/illumos/illumos-gate.git
$ git remote add -t master upstream_joyent https://github.com/joyent/illumos-joyent.git
$ git remote -v
origin  git@github.com:<github_name>/illumos-omnios.git (fetch)
origin  git@github.com:<github_name>/illumos-omnios.git (push)
upstream    git@github.com:omniosorg/illumos-omnios.git (fetch)
upstream    git@github.com:omniosorg/illumos-omnios.git (push)
upstream_gate   https://github.com/illumos/illumos-gate.git (fetch)
upstream_gate   https://github.com/illumos/illumos-gate.git (push)
upstream_joyent https://github.com/joyent/illumos-joyent.git (fetch)
upstream_joyent https://github.com/joyent/illumos-joyent.git (push)
```

## Update your local repository

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni update_illumos`

Which does:

```
$ git checkout master
$ git pull upstream master

$ git checkout upstream_gate
$ git pull upstream_gate master

$ git checkout upstream_joyent
$ git pull upstream_joyent master

$ git push -u origin upstream_gate
$ git push -u origin upstream_joyent
```

Since the upstream branches track the remotes, this should always
result in a clean working tree.

## Push the upstream branches to the remote repositories.

**This is an optional step**. If you have commit access to the `omniosorg`
repositories, you can push the updated upstream branches to GitHub.
If you don't, then continue to the next step.

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni push_upstreams`

Which does:

```
$ git push -u upstream upstream_gate
$ git push -u upstream upstream_joyent
```

## Review upstream changes

The upstream changes which are not yet in `illumos-omnios` can be reviewed
via the following command:

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni upstream_diff`

Example output:

```
GATE:

 8598 loader: Fix BSD label partition end sector calculation.         27b4c18ac
 8608 debug.h: CTASSERT will trigger variable unused errors           f9a980108
 8473 scrub does not detect errors on active spares                   554675eee

JOYENT:

 OS-6275 lx pipe buffer is too small                                  58cb94300
          M usr/src/uts/common/brand/lx/syscall/lx_pipe.c
          M usr/src/uts/common/fs/fifofs/fifosubr.c
          M usr/src/uts/common/fs/fifofs/fifovnops.c
          M usr/src/uts/common/sys/fs/fifonode.h

 OS-6320 systemd aborts itself on suse image                          7e83ccc4c
          M usr/src/uts/common/brand/lx/io/lx_netlink.c
```

## Merge upstream illumos-gate changes into new branch

Upstream changes from `illumos-gate` will be merged into a new branch
which will be used as the basis for a pull request. The branch name is
the current date in _YYYYMMDDnn_ format where _nn_ starts at 01 and is
incremented in the case that there is more than one merge in the same day.

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni merge_gate`

Which does:

```
$ git checkout -b upstream-merge/2017070301 master
$ git merge upstream_gate
```

### Process for a successful merge

If the merge is successful, you will be prompted to confirm the commit
message and, after saving, will have a clean working tree.

```
$ git status
On branch upstream-merge/2017070301
nothing to commit, working tree clean
```

### Process for a failed merge

Sometimes the merge will fail and produce conflicts which require manual
intervention.Conflicts will be due to OmniOS-specific changes or because
of the incorporation of LX Zones and accompanying infrastructure.

```
Automatic merge failed; fix conflicts and then commit the result.

$ git status
Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   usr/src/head/lastlog.h
        both modified:   usr/src/man/man1m/zonecfg.1m
```

Once you have manually resolved the conflicts, add the files and commit
the change.

```
$ git add usr/src/head/lastlog.h
$ git add usr/src/man/man1m/zonecfg.1m
$ git commit
```

## Perform a test build

Following merge, perform a full test nightly build including both debug
and non-debug components

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni build_illumos`

Which runs nightly:

```
$ nightly /path/to/omnios.env
```

**If the build is unsuccessful, resolve this before moving on to the next
step.**

## ONU to the new build

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni onu`

Which runs onu:

```
# onu -t 20170703 -d */path/to/illumos-omnios/packages/i386/nightly-nd*
...
# init 6
```

Confirm that the system boots.

## Push the merged branch

```
$ git push -u origin upstream-merge/2017070301
Counting objects: 1224, done.
Delta compression using up to 40 threads.
Compressing objects: 100% (352/352), done.
Writing objects: 100% (1224/1224), 401.27 KiB | 0 bytes/s, done.
Total 1224 (delta 1017), reused 1022 (delta 826)
remote: Resolving deltas: 100% (1017/1017), completed with 742 local objects.
To https://github.com/<github_name>/illumos-omnios.git
 * [new branch]            upstream-merge/2017070301 -> upstream-merge/2017070301
Branch upstream-merge/2017070301 set up to track remote branch upstream-merge/2017070301 from origin.
```

## Create a pull request

Use the Github web-interface to create a pull request from the new
upstream-merge branch to the master.

* Include the `mail_msg` file from the test build;
* Review the list of commits included in this merge and include any which
are backport candidates in the description of the PR. If there are none
state that too;
* Assign reviewers and the _upstream-merge_ tag.

## Update master branch

As soon as your PR has been merged, update your master branch:

```
$ git checkout master
$ git pull upstream master
$ git push
```

## Generate list of interesting Joyent commits

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni lx_begin`

Which does the following:

```shell
$ git checkout upstream_joyent
$ export PORT_DATA=/path/to/lx-port-data
$ git show master:README.OmniOS | grep 'Last illumos-joyent'
Last illumos-joyent commit:  b29bd3a941d640162496a2ab849fd84ca5dd6cf5
$ git log --reverse --no-merges --format=%H b29bd3a941d640162496a2ab849fd84ca5dd6cf5.. > $PORT_DATA/ij-ALL-commits
$ wc -l $PORT_DATA/ij-ALL-commits
     240 .../omniosorg/lx-port-data/ij-ALL-commits

# Remove commits which are also in `illumos-gate`

$ git log master --format=%H > $PORT_DATA/ij-GATE-commits
$ fgrep -v -f $PORT_DATA/ij-GATE-commits $PORT_DATA/ij-ALL-commits > $PORT_DATA/ij-TODO-commits
$ wc -l  $PORT_DATA/ij-TODO-commits
      42 .../omniosorg/lx-port-data/ij-TODO-commits

# Create new branch for picked changes

$ git checkout -b joyent-merge/2017070501 master
Switched to a new branch 'joyent-merge/2017070501'
```

## Evaluate each change in turn and choose whether to pick it or not

Run `omni lx_pick` until there are no more commits remaining.

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni lx_pick`

Which does the following:

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
 14 files changed, 174 insertions(+), 45 deletions(-)
Cherry pick it (Y/N)? n
GOING TO SKIP!
Skipping this one.

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
No commits remaining.
Run 'lx_end' to finish.
```

## Clean up, update README and lx-port-data

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni lx_end`

Which does:

```
$ cd $PORT_DATA
$ mkdir 2017/Jul05
$ rm ij-GATE-commits
$ mv ij-* 2017/Jul05
$ git add 2017/Jul05
$ git commit -m 'Updated LX port data for Jul05'
#
# Update the README.OmniOS file with the latest commit
#
$ git log master..joyent-merge/2017070501
```

## Perform a test build

Following merge, perform a full test nightly build including both debug
and non-debug components

![#f03c15](https://placehold.it/15/1589f0/000000?text=+) `omni build_illumos`

Which runs nightly:

```shell
$ nightly /path/to/omnios.env
```

If the build is unsuccessful, resolve this before moving on to the next
step.

## ONU to the new build

```
# onu -t joyent-20170703 -d */path/to/illumos-omnios/packages/i386/nightly-nd*
...
# init 6
```

Confirm that the system boots.

## Push the merged branch

```shell
$ git push -u origin joyent-merge/2017070501
```

## Create a pull request

Use the Github web-interface to create a pull request from the new
joyent-merge branch to the master.

* Include the `mail_msg` file from the test build;
* Review the list of commits included in this merge and include any which
are backport candidates in the description of the PR. If there are none
state that too;
* Assign reviewers and the _upstream-merge_ tag.

