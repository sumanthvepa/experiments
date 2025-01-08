#!/bin/bash

# Sometimes you have a local branch whose commits you do not want,
# but want to simply reset the local branch to be in sync with the
# remote branch.

# This might happen for example if an earlier commit has been 
# ammeded on the remote branch and pushed from another machine
# using --force. 
# Now your local branch has commits that are different from those
# on the remote branch.

# To sync with the remote branch you can eithe reset the local
# branch to the last common commit and then git pull --no-rebase
# to get all further updates from the remote branch.
# i.e

# First make sure you have clean working tree, stash any work in
# progress. Note we use echo to effectively comment out the git
# commands as they won't work without an actual commit id

# git fetch  # download the remote changes
echo "git fetch  # download the remote changes"

# Reset hard to the last common ancestor commit id
# git reset --hard last_common_ancestor_commit_id
echo "git reset --hard last_common_ancestor_commit_id"

# Now do a git pull
# git pull --no-rebase
echo "git pull --no-rebase"

# or use the following commands which are equivalent:
# git fetch  # This step is common, it downloads the remote branch
echo "git fetch"

# This resets the local branch to point to the head of the current remote
# branch. Thre @{u} is a git shortcut to refer to the head of the current
# upstream branch.
# For a full description of git's mini-language for specifing commit
# ids like @{u} and HEAD, see:
# https://git-scm.com/docs/gitrevisions

# git reset --hard @{u}


