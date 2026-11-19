When asked to create an issue in TODO.txt, always create the issue
at the top of the file. Some of the issues are multiline in TODO.txt
but for the issues you create the issue must fit entirely in one line.
There is no limit to the length of the line, but try to keep it to less
than 256 characters

Otherwise follow the format for the other issues in the file. An issue
has the form:

issueNNN-area-short-name: Description of the issue

For example:

issue247-docker-basics: Fix error in 20-docker-build-website.sh

Obviously increment the issue number when creating an issue. Make
sure another issue with the same number does not exist in the file.

When told to mark an issue as active, add an asterisk(*) at the
begining of the line. Unless explcitly told not to do so, remove
any existing asterisk from other lines.

When told to mark an issue as done, please add the phrase [DONE]
to the begining of the issue line, after any asterisk (if it exists)
