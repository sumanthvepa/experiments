# Instructions on Creating Commit Message Files

Create a git commit message and save it to the file msg.
The location of file msg should be inferred from the path
in prefix.txt

For example if the path in prefix.txt is
python/starlette/02-middleware

Then the location of the file msg relative to where your current
directory (where codex or claude is running) is
../../../msg

If prefix.txt is empty then the file msg should be created in
the current directory.

Use commit.template as the format of the commit message. If in doubt,
look at the format of the previous commit (or even the previous 2-3
commits,) to get an idea of how to format the commit message.

Look in the file TODO.txt for features marked with an asterisk. These
are the features being worked on for this commit. They should be placed
under the FEATURE(s) section of the commit message.

Use 'git status' to see which files have been staged for commit. DO NOT
USE 'git status --short'.

These files should be listed in the FILE(s) section of the commit
message, using the entry format shown in commit.template. Each entry
has the change type in square brackets (e.g. [modified], [new],
[renamed]), followed by the file name and a colon. A short summary of
the change to that file goes on the indented line(s) below it.

For every file you add to this section, you must prepend a prefix (if
it exists) to the filename that reflects the location of the file in
the repository. The prefix path can be found in the file prefix.txt.

The only exception to this rule is TODO.txt. No prefix should be
added to that file.

For example if the prefix path in prefix.txt is:
python/starlette/02-middleware/ and git status shows two files staged
for commit:

TODO.txt
src/mws/__init__.py

Then the FILE(s) section will contain the following entries:

[modified]TODO.txt:
  Summary of changes to the file
[modified]python/starlette/02-middleware/src/mws/__init__.py:
  Summary of changes to the file

As another example, if the prefix file is empty, then the file names in
the FILE(s) section are exactly those shown by `git status`, i.e:

[modified]TODO.txt:
  Summary of changes to the file
[modified]src/mws/__init__.py:
  Summary of changes to the file

Finally, look at the file related.txt for commit ids of commits that are
related to this commit. Use language similar to the language in those
commits when you create the commit message. Use plain language. Avoid
jargon. DO NOT exceed 70 characters per line. The only exceptions are for
the first line, and, long path names to files.

Note: You must ONLY document changes to files staged for commit. Nothing
else. If there are NO FILES staged for commit, then stop and print out
a message saying that there are no files staged for commit.

Add a Co-Author line at the bottom of any commits that you make where you
were either partially or wholly responsible for the changes to the code.
See commit.template for structure of the co-author line. If for some reason,
you don't have access to the information about the model you are and the effort
level, please ask the user for that information.
