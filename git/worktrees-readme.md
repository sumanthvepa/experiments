# Using Worktree with bare clones

## Step 1: Create a worktree directory
```bash
mkdir netfinet
```

## Step 2: Clone the bare repo into a subdirectory

This is how I use git worktrees with bare clones

```bash
cd netfinet
git clone --bare svepa@crystal:Documents/Repositories/netfinet.git
```

This creates a directory netfinet.git in it.

## Step 3: Configure git fetch for all branches
Run this inside netfinet.git:

```bash
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
```

## Step 4: Fetch from the origin
```bash
git fetch origin
```

# Step 5: Add a worktree
Now add a worktree outside the bare repository. The command
is typically run from within the bare repo directory, but 
can be run from anywhere using `git -C`. 
The first argument to worktree add is the path to worktree
directory. The second argument is the branch.
```bash
git worktree add ../develop develop
```

This should be the directory structure now:

```
netfinet/
  netfinet.git/ <- the bare repo
  develop/ <- The worktree for the develop branch
```

Remember that the parent netfinet directory is just a container
directory not a git workspace or repo. You cannot run git commands
in it; only in its sub-directories

Each worktree is an independent directory linked to the same 
underlying repository.

## Step 6: Useful worktree commands
To see a list of all your active worktrees run this either
in the bare repo directory or one of the worktree directories:
```bash
git worktree list
```

Sometimes one may delete the worktree directory unintentionally
without using `git worktree remove`. To let Git clean up stale
worktree metadata, run: 
```bash
git worktree prune
```

## Step 7: Work in the worktree
All git commands should work as usual within the worktree


## Step 8: Remove the worktree when done
When done with the worktree you can remove it using 
`git worktree remove`. This command is also typically
run from within the bare repo directory, can be run from
anywhere using `git -C`

```bash
git worktree remove ../develop  # This is the path. NOT the branch name
```
