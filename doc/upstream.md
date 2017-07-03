
# Keeping up-to-date with upstream illumos gate.

## Initial repository configuration

This process is easier if you set up a git remote called _upstream_

```Shell Session
$ git remote add -t master upstream https://github.com/illumos/illumos-gate
$ git remote -v
origin  https://github.com/omniosorg/illumos-omnios.git (fetch)
origin  https://github.com/omniosorg/illumos-omnios.git (push)
upstream        https://github.com/illumos/illumos-gate (fetch)
upstream        https://github.com/illumos/illumos-gate (push)
```

## Check out and update the upstream branch

```Shell Session
$ git checkout upstream
Branch upstream set up to track remote branch upstream from origin.
Switched to a new branch 'upstream'
illumos-omnios:upstream% git pull upstream master
remote: Counting objects: 1115, done.
remote: Total 1115 (delta 804), reused 804 (delta 804), pack-reused 311
Receiving objects: 100% (1115/1115), 543.67 KiB | 448.00 KiB/s, done.
Resolving deltas: 100% (909/909), completed with 676 local objects.
From https://github.com/illumos/illumos-gate
 * branch                  master     -> FETCH_HEAD
 * [new branch]            master     -> upstream/master
Updating a40ea1a7d8..8902f61a33
Fast-forward
... lots of output ...

$ git status .
On branch upstream
Your branch is ahead of 'origin/upstream' by 34 commits.
  (use "git push" to publish your local commits)
nothing to commit, working tree clean
```

Since the upstream branch tracks illumos-gate/master, this should always
result in a clean working tree.

## Merge upstream changes into new branch

Create a new branch into which the upstream changes will be merged in order
to create a pull request. The branch name should be
_upstream-merge/YYYYMMMMDDnn_ where _nn_ starts at 01 and is incremented in
the case that there is more than one merge in the same day.

```Shell Session
$ git checkout -b upstream-merge/2017070301
Switched to a new branch 'upstream-merge/2017070301'
```

Merge the upstream changes. This will either complete successfully or produce
conflicts that require manual intervention. Conflicts will be due to
OmniOS-specific changes or because of the incorporation of LX Zones and
accompanying infrastructure.

### Process for a successful merge

TBC...

### Process for a failed merge

```Shell Session
$ git merge upstream
Auto-merging usr/src/uts/intel/sys/ucontext.h
... additional output deleted ...
Automatic merge failed; fix conflicts and then commit the result.

$ git status
Unmerged paths:
  (use "git add <file>..." to mark resolution)

        both modified:   usr/src/head/lastlog.h
        both modified:   usr/src/man/man1m/zonecfg.1m
```

Once you have manually resolved the conflicts, add the files and commit
the change.

```Shell Session
$ git add usr/src/head/lastlog.h
$ git add usr/src/man/man1m/zonecfg.1m
$ git commit -m 'Merge upstream'
[upstream-merge/2017070301 8a5908ecf9] Merge upstream
```

## Push the merged branch

```Shell Session
$ git push --set-upstream origin upstream-merge/2017070301
Counting objects: 1224, done.
Delta compression using up to 40 threads.
Compressing objects: 100% (352/352), done.
Writing objects: 100% (1224/1224), 401.27 KiB | 0 bytes/s, done.
Total 1224 (delta 1017), reused 1022 (delta 826)
remote: Resolving deltas: 100% (1017/1017), completed with 742 local objects.
To https://github.com/omniosorg/illumos-omnios.git
 * [new branch]            upstream-merge/2017070301 -> upstream-merge/2017070301
Branch upstream-merge/2017070301 set up to track remote branch upstream-merge/2017070301 from origin.
```

## Create a pull request

Use the Github web-interface to create a pull request from the new
upstream-merge branch to the master. Take care to change the _base fork_
value to _omniosorg/master_ as it will default to the upstream OmniTI
repository.

Review the list of commits included in this merge and include any which
are backport candidates in the description of the PR. If there are none
state that too.

Assign reviewers and the _upstream-merge_ tag.

