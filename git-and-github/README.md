# Git and GitHub Homework

Student: **Prabhav Semwal**  
Enrollment number: **24BCS10358**

This exercise uses this repository's real commit history to compare commit
commands and demonstrate cherry-picking.

## `git commit -m` and `git commit -a -m`

`git commit -m "message"` commits only changes already placed in the staging
area with `git add`. The `-a` option automatically stages modifications and
deletions of tracked files before committing, but it does **not** include new,
untracked files.

## Observed `git commit -a` behavior

Before the commit, one tracked file was modified and one new file was
untracked:

```text
 M git-and-github/tracked-example.txt
?? git-and-github/untracked-example.txt
```

After `git commit -a -m "Demonstrate tracked-file auto staging"`, Git
committed only the tracked file and still displayed:

```text
?? git-and-github/untracked-example.txt
```

This confirms that `-a` does not add new files.

## Cherry-pick exercise

The repository has three setup commits on `main`. I then created
`cherry-pick-practice` and made these three commits:

```text
ff3ec1f Add a branch-only change
4b7e9a3 Add the change selected for cherry-pick
2cf7860 Stage and commit the previously untracked file
```

I returned to `main` and ran:

```bash
git cherry-pick 4b7e9a3
```

Git created commit `ff062cc` on `main` with the same selected change. The
file [`cherry-picked-change.txt`](cherry-picked-change.txt) is therefore on
`main`, while `branch-only-notes.txt` remains exclusive to the practice
branch.

```text
* ff3ec1f (cherry-pick-practice) Add a branch-only change
* 4b7e9a3 Add the change selected for cherry-pick
* 2cf7860 Stage and commit the previously untracked file
| * ff062cc (main) Add the change selected for cherry-pick
|/
* 7cff6b9 Demonstrate tracked-file auto staging
* 1e017b7 Add Git homework introduction
* 42bb593 Initialize DevOps coursework repository
```

The different commit hashes are expected: cherry-pick creates a new commit
with the selected patch on the current branch.
