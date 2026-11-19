# Instructions to Update the Docker Tutorials
The purpose of this session is to update and improve all the
exploratory shell scripts from 09-*.sh to 25-*.sh in docker/basics/

The idea is to bring them all up to the standard seen in the scripts
00-*.sh through 08-*.sh

Unless stated otherwise, the file names and patterns in these
instructions, such as 09-*.sh, bash-utilities.sh and postgres-test,
are relative to docker/basics/.

You will follow the instructions in @prompts/agent-session.md with the
following exceptions:
  - You may stage and commit files in this repository using git
  - You may delete and rename files in docker/basics/, including
    files you did not create in this session

Limit your changes to docker/basics/. Do not create, modify, delete
or rename files anywhere else in the repository. The only exceptions
are TODO.txt and the commit message file msg at the top of the
repository, which you update as described in prompts/todo.md and
prompts/commit.md. Temporary files are exempt, as described in
prompts/agent-session.md.

## Audience

The tutorials are written for the owner of this repository, who is
also their student. Judge teaching order and prerequisite knowledge
by what they already know, not by a generic beginner. A concept may
appear before the script that formally teaches it, if it is clear in
its context; do not flag it as premature just because a later script
covers it. Still fix factual errors, robustness problems and missing
files.

## Test host

The tutorials are tested on one host:

- Fedora Linux 44 Server, in a QEMU virtual machine on Apple
  silicon. The CPU architecture is aarch64 (arm64).
- Docker Engine 29.9.3, rootful, with the classic overlay2 image
  store and cgroup v2. Buildx 0.38.1 and Compose 5.7.0 are installed.
- firewalld is running. SELinux is enforcing on the host, but the
  Docker daemon does not use it: `docker info` shows no
  `name=selinux` security option.
- qemu-user-static is installed, so linux/amd64 containers run under
  emulation.
- sudo works without a password for the user who runs the tests, but
  it may stop doing so. Check it as described in "Automated tests".

Describe behavior on other distributions, CPU architectures and
daemon modes, such as rootless Docker, a daemon that uses SELinux or
the containerd image store, where it matters, but say that it was not
tested. Record in each explanation file what was tested on this host.

Before testing, check that any local almalinux:10-minimal image has
the host's architecture, with
`docker image inspect --format '{{.Architecture}}' almalinux:10-minimal`.
If it is not arm64, stop and report it: an image for another
platform would make every build run under emulation.

At startup, the manager checks the actual host, architecture, daemon
mode, image store, Docker/Buildx/Compose versions and required tools
rather than assuming this description is current. Check passwordless sudo with
`sudo --non-interactive true` before tests that need it. Record the
observed configuration in the coordination record. If the base image
is absent, allow the normal native-platform pull and check its
architecture afterward; absence is not an architecture mismatch.
Do not install missing prerequisites or reconfigure the host.

## Authority and limits

Work through all five steps without stopping for approval, except in
the cases listed in "When to stop and ask". The manager decides
ordinary questions of implementation and curriculum, including
accepting the coverage map in Step 5, and records each decision and
its reason in the coordination record. Do not ask the user to choose
between ordinary ways of meeting these requirements.

- You may fix an unsafe or misleading example so that it teaches the
  same thing safely, and replace a duplicated explanation with a
  short reference to the lesson that owns it. Neither counts as
  removing an example.
- You may change shared helpers and build contexts, including ones
  used by 00-*.sh through 08-*.sh, to make them more general or
  easier to call. Find every caller with `git grep`. If the change
  alters how a helper is called, such as its arguments, its exit
  status or its output, update every call site in the same commit,
  including those in 00-*.sh through 08-*.sh and in scripts later in
  the order. Updating such a call site is the only change allowed in
  a script outside the task. Check the callers as described in
  "Regression checks across scripts".
- You may open and close tutorial ports temporarily with
  firewall-utilities.sh, using root privileges or passwordless sudo,
  and restore their original state as described in Step 3. This does
  not cover installing packages, making persistent changes to the
  host, changing daemon settings, switching Docker contexts, or
  changing SELinux or emulation settings.
- If a tool, access or infrastructure that a check needs is missing,
  record the exact blocker, what you tried and the work left. A
  skipped or missing essential check is never a pass.

### When to stop and ask

Stop and ask the user, rather than decide yourself, before you:

- remove an example or a feature from a tutorial or helper, or drop
  support for an operating system, distribution or CPU architecture.
  Package names and paths differ between distributions, so a failure
  on one is a reason to fix it, not to drop it.
- change what a tutorial in 00-*.sh through 08-*.sh does or teaches.
  Changing a helper it uses, and updating its calls to that helper,
  as described above, does not count, as long as the tutorial still
  does and teaches the same thing.
- do anything that needs root privileges or credentials you do not
  have, that would change host or daemon settings other than the
  temporary firewall changes above, or that prompts/agent-session.md
  or the scope rules at the top of this file do not allow. Prepare
  the change you would make, and name the rule that stops you.

Also stop and report when a coding agent and its reviewer reach the
review limit without approval, as described in "The review loop".

These cases should be rare. Prefer a fix that keeps the example, the
support and the behavior of the shared file. Sub-agents never ask the
user directly: they stop before the change that needs the decision
and put the question in their report. The manager asks the user and
waits for the answer before it starts the next sub-agent.

## Order of work

Process the 19 scripts in the order that `ls` lists them in
docker/basics:

09-docker-build-cmd-entrypoint.sh, 10-docker-build-node.sh,
10-docker-logs.sh, 11-docker-build-node-optimized.sh,
12-docker-build-python.sh, 13-docker-build-flask.sh,
14-docker-build-postgres-manual.sh, 15-docker-build-postgres-test.sh,
16-docker-run-postgres-test.sh, 17-docker-inspect.sh,
18-docker-save-load.sh, 18-docker-stats.sh,
19-docker-login-logout.sh, 20-docker-build-website.sh,
21-docker-networking.sh, 22-docker-rootless.sh, 23-docker-buildx.sh,
24-docker-compose-basics.sh and 25-docker-compose-networking.sh.

Work in three phases:

1. Steps 1 and 2. Finish Step 1 for every script, then Step 2 for
   every script.
2. Steps 3 and 4, one script at a time. For each script, finish Step 3,
   then Step 4 if it applies, before you start the next script. Step 4
   applies only to the scripts it lists.
3. Step 5, after every script has finished Step 4 or recorded that it
   does not apply. Make the coverage map for the whole series first,
   then make each script's Step 5 changes in the same order. Finish
   with "Final acceptance".

Each step of each script is one task, done by a coding agent and
checked by a reviewer, as described in "Sub-agents". When the
reviewer approves, the coding agent commits the script's changes for
that step and completes its explanation file. NEVER commit an
explanation file.

ALWAYS write the explanation file, even when a step makes no change to
a script, for example Step 2 for a script that uses no AlmaLinux image,
or Step 4 for a script that Step 4 does not list. Say in the file that
nothing changed and why, and put `N/A` and that reason where the commit
hash would go. Do not make an empty commit.

Put the step number after the issue name in the first line of each
commit message, for example:

`issue249-docker-basics: Step 3: Make 17-docker-inspect.sh stop on errors ...`

### The coordination record

The manager keeps its notes in
docker/basics/docker-basics-update-run-improvements.md. The ignore
rule `*-improvements.md` in docker/basics/.gitignore covers that name,
as it covers the explanation files. Never stage or commit it, and do
not rename it. It records:

- at the first start: the branch, HEAD, the output of `git status`,
  and the paths of any changes that existed before this work started,
  with a checksum of their `git diff`, so that they can be told apart
  from this work. Do not record credentials.
- the test host as observed at startup, described in "Test host"
- the Co-Authored lines, described in "Committing"
- for each task: its starting HEAD, the number of review rounds and
  any extra rounds the user allowed, the verdict, the commit and the
  approved tree or digest, and any deferred checks
- the decisions the manager made, with their reasons, and the user's
  answers to questions
- the accepted coverage map, described in Step 5
- the next task

Do not unstage, stash, reset or commit changes that existed before this
work started. If the index is not empty at the first start, or if such
a change is in a file that a task must change, stop and ask the user.

### Starting and resuming

When you start or resume work:

1. Read the coordination record. If it does not exist, this is the
   first start: create it as described above. If it is lost on a
   resume, rebuild it from `git log --oneline`, the explanation files
   and `git status`.
2. Compare the branch, `git log --oneline`, the index and the working
   tree with the record. Do not assume that every uncommitted change
   belongs to an interrupted task: a change belongs to a task only if
   the record or the task's explanation file says so. Stop and ask
   about any other change in a file that a task must change. Never
   switch branches or discard changes to recreate an old state.
3. If a task's commit exists but its explanation file does not, give
   the task back to a coding agent to write the explanation from the
   commit's diff, and to rerun the checks whose results are lost. Do
   not invent test results.
4. If a task's last verdict is APPROVED but the task is not finished,
   check that HEAD is still the task's starting HEAD, that the task's
   files have no unstaged changes, and that `git write-tree` matches
   the approved tree. For a task with no commit, use the checks in
   "Approvals without a commit" instead. If the checks pass, finish
   without another review, even if approval came in round 7. If not,
   return the task for review: never commit on an old verdict.
5. If the last verdict is CHANGES REQUIRED, continue the review loop.
   A restart does not reset the round count.
6. Continue with the next unfinished task in the order above, and
   carry every outstanding deferred check with it.

### Explanation files

Each step of each script has an explanation file in docker/basics/.
Its name is `<script-basename>-<stepno>-improvements.md`: the script
filename without .sh, and a two-digit step number. For example, Step 1
of 17-docker-inspect.sh uses 17-docker-inspect-01-improvements.md, and
Step 3 of 18-docker-save-load.sh uses
18-docker-save-load-03-improvements.md. This keeps the names unique
even when two scripts have the same number.

The coding agent writes the explanation before the first review and
keeps it current. It records:

- the script and step, what changed and why, and the supporting files
  that changed, with the other scripts that use them
- the commands and checks run, their results, and the paths of their
  logs. For a tutorial test, record the output of `git write-tree`
  when it ran, and record that, just before it ran,
  `git diff --quiet -- <inputs>` succeeded and
  `git ls-files --others -- <inputs>` printed nothing, with the
  inputs described in "Final acceptance". Staged changes are expected
  then; unstaged changes and untracked or ignored files are not.
  After the commit, the tree is the commit's tree, and "Final
  acceptance" can reuse the result.
- anything the tutorial leaves behind, its limitations, the checks
  that could not be run and why, and the deferred checks
- after the commit, the commit hash, or `N/A` and the reason

Every explanation file ends with the line `## Review history`, and so
do the coverage map and the acceptance file. The reviewer adds its
rounds below that line, as described in "The review loop". When a
later correction changes the step, add to the file rather than
erasing the earlier evidence.

### Committing

Before it starts the first sub-agent, the manager asks the user once
for the exact Co-Authored line or lines to use, in the format of
commit.template. The question names the models and effort levels the
manager plans to use for coding agents; reviewers make no commits and
need no line. Record the answer in the coordination record and give
each coding agent the line for its model and effort. Do not ask again.
On a resume, use the recorded lines.

The coding agent stages its changes for review, and commits only after
the reviewer approves them:

1. Before this task's first staging, check that the index is empty,
   then stage only the files of this task, by explicit path:
   `git add -- <file> ...`. Never use `git add -A`, `git add .` or
   `git add --force`. Check the whole of `git diff --cached` and stop
   if a staged change does not belong to this task. Run
   `git diff --cached --check`.
2. Stage the files again after each correction. Leave no unstaged
   changes in the task's files, so that the tests ran on exactly what
   is staged.
3. After approval, write a new commit message file following
   prompts/commit.md, even though no one has asked you for one.
   prefix.txt is empty, so the file is msg at the top of the
   repository, not in docker/basics. Describe the actual approved
   diff and its main changes. Do not reuse an earlier message when
   the task or its scope has changed.
4. Use the Co-Authored line given in your prompt, in the format of
   commit.template. Do not add any other attribution lines.
5. Commit with `git commit --file=<top of the repository>/msg`.
6. Run `git log -1` and check that the first line has the step label
   and that the message ends with the Co-Authored line. Check that
   `git rev-parse 'HEAD^{tree}'` prints the tree the reviewer approved,
   and that the index is empty.

A step that changes nothing, the coverage map and the acceptance file
make no commit. They follow "Approvals without a commit" instead.

## Sub-agents

The coordinating agent is the manager. An agent that is given a
coding, review or validation task follows the rules for that role
instead.

The manager starts sub-agents, keeps the coordination record, makes
the decisions described in "Authority and limits", and reports to the
user. It does not do the work of any task, and it does not review the
work itself: the reviewers do that, so that the manager's context
stays small enough to last the whole series. The manager reads the
reports, the coordination record and the verdicts in the explanation
files, and runs the short checks in "Checking a finished task".

You must be able to start sub-agents. If your tool has no way to start
one, stop and tell the user. If starting one fails, try once more. If
that also fails, stop and tell the user what you tried and the error.
Do not do the work yourself in its place.

### Roles

- A coding agent does one task: one step for one script, the coverage
  map, a correction, or the change to TODO.txt. It changes files,
  stages them, runs the checks on what is staged and writes the
  explanation. After approval it commits.
- A reviewer checks one coding agent's work. It reads the staged diff,
  the files it affects and their callers, the explanation and the test
  logs, and reruns checks when it needs to. It does not change, stage
  or commit any file, except to add its review below the
  `## Review history` line. A reviewer that runs a tutorial or a test
  must leave nothing behind.
- A validation agent runs the checks in "Final acceptance" and writes
  the acceptance file. It does not change tutorials, helpers or
  drivers.

Give each task its own coding agent and its own reviewer. For a script
that Step 4 does not list, the Step 3 coding agent also writes the
Step 4 explanation, and the Step 3 reviewer checks it in the same
rounds. Its verdict, in the Step 3 review history, covers both files.

Run one sub-agent at a time, and wait for it to finish before you start
the next. A coding agent and its reviewer take turns; never run them
at the same time. All the sub-agents share one Docker daemon, one git
index, the host firewall, fixed ports and the shared helpers. Run every
sub-agent in this working tree and on this branch; do not give it a
separate worktree or branch.

### The review loop

For each task:

1. The coding agent does the work, stages the changes, runs the
   step's checks on what is staged, writes the explanation and
   reports. A task with no commit stages nothing.
2. The reviewer reviews the work and adds a section headed
   `### Review round <n>` below the `## Review history` line, with its
   verdict:
   - APPROVED. For staged changes, add the output of
     `git write-tree`, which names the exact content approved. For
     the coverage map or the acceptance file, add the digest and HEAD
     described in "Approvals without a commit".
   - CHANGES REQUIRED, with numbered findings. Each finding names the
     file and line, the requirement in these instructions or the
     defect, and what would satisfy it.
3. After CHANGES REQUIRED, the coding agent fixes each finding, stages
   the files again, reruns the affected checks, and adds
   `#### Response` under that round, saying what it did about each
   finding. If it disagrees with a finding, it says why there, and
   the reviewer decides in the next round.
4. Repeat from 2 until the reviewer approves. Then the coding agent
   commits, as described in "Committing", or finishes a task with no
   commit as described in "Approvals without a commit".

A round is one review. Stop after the 7th round that does not approve:
leave the work as it is, do not commit, and report to the user the
task, the explanation file and the findings that are still open. If
the user allows more rounds, record how many in the coordination
record. Number the rounds of a task continuously: restarting an agent
or the session does not reset the count.

Continue the same coding agent and the same reviewer from round to
round if your tool can send a message to an agent that has finished.
Otherwise start new ones, and tell them to read the explanation file,
which holds the earlier rounds.

So that the loop ends, the reviewer:

- raises only defects and failures to meet these instructions, not
  matters of taste
- in each later round, checks that the earlier findings were fixed and
  reviews what changed. It raises a new finding in unchanged code only
  for a real defect that it missed before.
- marks a finding that needs a decision about scope or curriculum as
  "manager decision". The manager decides, records the decision and
  passes it to both agents, or asks the user if the decision falls
  under "When to stop and ask".

### Approvals without a commit

A step that changes nothing, the coverage map and the acceptance file
make no commit, so `git write-tree` cannot name what was approved.
Throughout such a task, keep the index empty and HEAD unchanged.

- For a step that changes nothing, the reviewer approves the reason
  given for `N/A`. Nothing uses the file afterwards, so its approval
  needs no digest.
- The coverage map and the acceptance file are used after approval,
  so the approval names their exact content: the SHA-256 digest of
  the part above the `## Review history` line, and the HEAD at which
  it was approved. With DOCUMENT set to the file's path:

  ```bash
  sed '/^## Review history$/,$d' "$DOCUMENT" | sha256sum
  ```

  Adding a review below the line does not change the digest. Any
  change above it needs another review.
- After each round of the coverage map, the manager copies the map,
  with its review history, into the coordination record, so that
  losing the temporary file loses nothing.
- The acceptance file's approval holds only for the HEAD it names. A
  correction after it needs a new approval. Record the TODO.txt
  commit below the `## Review history` line.

For these tasks, the manager checks that HEAD did not change, that the
index is empty and, for the coverage map or the acceptance file, that
the digest matches the approval.

### What the reviewer checks

- The diff stays within the task and the allowed paths, and every
  staged change belongs to the task. No unstaged or untracked change
  is left in the task's files. For a task with no commit, check
  instead that the index is empty and HEAD has not changed.
- The changes meet the requirements of the step. Steps 1 and 2 have
  narrow requirements: check that nothing else changed. For Steps 3
  to 5, check the teaching, the facts against the official
  documentation, the license header, error paths, resource ownership,
  cleanup, and the specific issues listed for the script.
- Every caller of a changed shared file still works, or has a deferred
  check recorded.
- The test evidence comes from the staged content, the assertions
  prove what the lesson claims, and no failure or skip is hidden.
  Rerun a check when its evidence is missing or does not match. For
  final validation, check the tested revisions and inputs recorded in
  the acceptance file instead.
- The explanation is accurate and complete.

### The coverage map

The coverage map is one task, with its own coding agent and reviewer.
The coding agent writes the map to a temporary file whose path the
manager gives it, and makes no commit. The reviewer checks the map
against the actual lessons, not just their headings, and adds its
rounds below its `## Review history` line. After approval, the
manager reads the proposed changes, one line per script, checks the
digest, and copies the accepted map into the coordination record.
A proposal to remove an example or a feature is a question for
the user, as described in "When to stop and ask". Each script's Step 5
task gets the changes accepted for it.

### What to put in a sub-agent's prompt

A sub-agent cannot see your conversation. Give it everything it needs:

```
You are working in docker/basics of this repository.
Your role: <coding agent | reviewer | validation agent>
Your task: <Step <n> for <script> |
 the Step 5 coverage map, written to <path> |
 Step 5 for <script>, with these changes accepted from the coverage
 map in <path>: <changes> |
 corrections to Step <n> for <script>: <findings and allowed paths> |
 the final acceptance checks |
 marking issue249 done in TODO.txt>
Review round: <n, for a reviewer, or for a coding agent answering a
 review; otherwise none>

Before you change anything, read prompts/agent-session.md,
prompts/projects/docker-basics-update.md and prompts/commit.md and
follow them. Read "Order of work", "Sub-agents", and the step
sections for your task.

Co-Authored line: <line from the user, for a coding agent>
Coordination record: docker/basics/docker-basics-update-run-improvements.md
Explanation file: <path>
Changes that existed before this work, to leave alone: <paths, or none>
Deferred checks due in this task: <checks, or none>
Manager decisions for this task: <decisions, or none>

Earlier work that affects your task:
<commits and shared-file changes, for example a change to
docker-build-flask-test-utilities.sh made for 13-docker-build-flask.sh,
or "none">

When you finish, or if you must stop, reply with the report described
in "Sub-agents: Reports".
```

### Rules for sub-agents

- Do only the task named in your prompt. Do not start work on another
  script or step. You may run the tests of other scripts that use a
  file you changed. Change those scripts only to update their calls
  to a helper you changed, as described in "Authority and limits".
- Do not start sub-agents of your own.
- If you need a decision listed in "When to stop and ask", do not guess
  and do not ask the user. Stop before the change that needs it, and
  put the question in your report.
- Keep long output out of your report. Put the details in the
  explanation file.

### Reports

Keep a report to at most about 15 lines; the coverage-map report may
add one line per script for the proposed changes. A coding agent or a
validation agent replies:

```
Task: <task from the prompt>
Status: <ready for review | committed | passed | failed | stopped>
Commit: <hash and first line, or N/A and the reason>
Explanation file: <path>
Shared files changed: <file, and the other scripts that use it, or none>
Deferred checks: <caller, check, and when it can run, or none>
Checks skipped: <check, reason, and whether it is essential, or none>
Questions for the user: <questions, or none>
```

A reviewer replies:

```
Task: <task from the prompt>
Round: <n>
Verdict: <APPROVED, tree <hash> | APPROVED, SHA-256 <digest> at HEAD
  <hash> | APPROVED, no change | CHANGES REQUIRED, <number> findings>
Manager decisions needed: <decisions, or none>
Questions for the user: <questions, or none>
```

### Checking a finished task

After the coding agent commits, check that:

1. `git log -1` has the step label in its first line and ends with the
   Co-Authored line.
2. `git rev-parse 'HEAD^{tree}'` prints the tree in the reviewer's
   last round, and `git diff --cached --quiet` succeeds.
3. `git status` shows no changes other than the coordination record,
   the explanation files and the changes that existed at the start.
4. The explanation file has the commit hash.

For a task with no commit, make the checks in "Approvals without a
commit" instead. Make the same checks when you finish an approved
task after a restart.

Record the result, any shared-file changes with their callers, and the
deferred checks in the coordination record. Include them in the
prompts of the later tasks that need them. If a check fails, give the
task back to its coding agent. If a report has questions for the user,
ask the user and wait.

If a sub-agent stops without finishing and without a question, for
example because of an error, start one new sub-agent for the same role
and task, and tell it to resume. If that one also fails, stop and tell
the user.

## Automated tests

Each tutorial gets an automated test that runs the unchanged tutorial
and supplies the input a person would type. There is no test mode
inside the tutorials. Running a tutorial directly still waits for the
reader, and the test runs exactly the same code.

### Files

The test runner and the shared procedures already exist in
docker/basics/tests/:

- `run-tutorial-test.sh`: the runner. Run
  `run-tutorial-test.sh --help` for its usage.
- `tutorial-test.tcl`: the Expect procedures that drivers use. The
  comments at its top describe each procedure.

Do not create another runner, and do not change these two files. If
one of them cannot exercise or verify something, first use the
supplemental driver assertions described below. Report the harness
limitation and the additional evidence. If no permitted check can
establish an essential result, record an unresolved validation
blocker; do not weaken the assertion, edit the harness or claim a
pass. A manager decision within scope does not require user approval.

What you write is the driver: `<script-basename>.exp` in
docker/basics/tests/, the Expect script that runs one tutorial, for
example `18-docker-stats.exp`. Use the full script name without .sh,
so the two scripts numbered 10 and the two numbered 18 get separate
drivers. The runner finds a driver by this name.

A driver is a first-party source file. Give it the license header
required by prompts/license-headers.md, using # comments, after its
first line. The tests are tools, not lessons: comment what each
scenario checks and why, but do not explain Docker in them.

### Required tools

expect is installed, and the runner checks for it. tmux and
qemu-user-static are installed for drivers that need a second
terminal or another CPU architecture. A driver that needs one of them
checks for it first, for example with `host_command_succeeds`, and
calls `skip` with the reason if it is missing. Do not install
anything.

Perform skip checks before creating resources or changing files.
The runner does not compare before/after snapshots when a driver
exits with 77. Do not use `skip` to escape a failed assertion or a
failure after setup; clean up and fail instead.

### Writing a driver

A driver begins with `#!/usr/bin/expect -f`, then the license header,
then comment lines that the runner reads:

```
# scenarios: normal interrupt continue conflict
# firewall-port: 9000
# time-limit: 1800
```

- `scenarios` lists the scenarios the driver supports. normal is
  required.
- `keeps-image` names an image the tutorial may leave behind: an image
  it deliberately keeps for a later tutorial, or a base image that it
  pulls. A name without a tag means name:latest. One line per image.
  The drivers for 09-*.sh through 25-*.sh do not use it, because those
  tutorials remove the images they build or pull, as described in
  "Leaving Docker as it was".
- `firewall-port` names a TCP port the tutorial may open. One line per
  port. Checking a port needs sudo without a password; without it,
  the runner skips the test.
- `time-limit` is the most seconds one scenario may take. The default
  is 1800.

Then the driver sources the shared procedures:

```tcl
source [file join [file dirname [info script]] tutorial-test.tcl]
```

and uses them to act as the reader:

- Start the tutorial with `start_tutorial`, which gives it a real
  terminal.
- At each `read -r -p` pause, call `answer_pause` with the exact
  prompt text.
- In a shell or REPL, wait for its prompt, `type_line` each command
  that the tutorial prints for the reader to try, check the output
  with `wait_for` or `wait_for_regexp`, and leave the shell the way
  the tutorial says, normally with `exit 0`.
- Where the tutorial asks for a second terminal, start one with
  `start_terminal`, and pass `-in name` to the other procedures.
- Call `press_ctrl_c` only after `wait_for` has seen output that shows
  the command it interrupts has started.
- End with `finish_tutorial` and the exit status the scenario expects.
- Give `-time` to a wait that may take longer than 120 seconds, such
  as one that follows an image build.
- Register the removal of anything the driver itself creates on the
  host with `cleanup_on_host`, as soon as it exists.

Match short, distinctive text that the tutorial prints, such as the
exact pause prompt or the line printed before an interactive shell.
A tutorial must print a stable, distinctive message at every point
where it waits for the reader. When you change that text, change the
driver in the same commit.

### Scenarios

Support each scenario that applies to the tutorial:

- `normal`: run the whole lesson. Expect status 0.
- `interrupt`: press Ctrl-C after the tutorial has created resources,
  at a point stated in the driver. Expect status 130. The runner
  checks that the tutorial's cleanup removed everything.
- `continue`: press Ctrl-C to end a stream that the lesson continues
  after, such as `docker container stats` or `logs --follow`, and
  check that the lesson goes on and finishes. Leave it out if the
  normal scenario already does this.
- `conflict`: before starting the tutorial, create a resource with a
  name the tutorial uses, with `host_command`, and register its
  removal with `cleanup_on_host`. Check that the tutorial stops with
  its message and that the resource is still there, then remove it.

### An example driver

This driver for 04-docker-kill-top-stats.sh was used to test the
runner. All its scenarios pass. The license header is left out here.

```tcl
#!/usr/bin/expect -f
# scenarios: normal interrupt conflict
# keeps-image: nginx
source [file join [file dirname [info script]] tutorial-test.tcl]

switch -- [scenario] {
  conflict {
    # Hold the name docker-basics-nginx, so that create must fail.
    set blocker [host_command docker container create \
      --name docker-basics-nginx nginx]
    cleanup_on_host docker container rm --force $blocker
    start_tutorial
    wait_for "Could not create the demonstration container."
    finish_tutorial 1
    # The tutorial must have left the container alone.
    host_command docker container inspect $blocker
    host_command docker container rm $blocker
    cancel_cleanup_on_host
  }
  interrupt {
    # Ctrl-C after the container exists, while waiting for nginx,
    # must run the tutorial's cleanup.
    start_tutorial
    wait_for "Waiting for nginx to answer"
    press_ctrl_c
    finish_tutorial 130
  }
  normal {
    start_tutorial
    answer_pause "Press ENTER to start it..."
    # docker container stats prints a header, then updates it every
    # second until Ctrl-C.
    wait_for "MEM USAGE / LIMIT"
    press_ctrl_c
    wait_for "Killing the container..."
    wait_for "...cleanup completed."
    finish_tutorial 0
  }
}
```

### What the runner checks

For each scenario, the runner runs the driver from a new, empty
working directory. It records container ids and names, image ids and
tags, volume names, network ids and names, buildx builder names, and
the state of each `firewall-port`. Except for skipped scenarios, it
compares these records before and after the run. The scenario fails if:

- the driver fails, or exits with a status other than 0 or 77
- the run left a resource behind, other than a `keeps-image` image
- a recorded identity, name or tag that existed before the run
  disappeared or changed
- the tutorial left files in its working directory
- the scenario ran longer than its time limit

`run-tutorial-test.sh <script> all` runs every scenario the driver
lists, then the normal scenario again, to check that a successful run
can be repeated. The runner prints a result line for each scenario
and the directory that holds the logs. On a failure it also prints
the differences and the end of the log. It exits with 0 when every
scenario that ran passed, 1 when any failed, 2 for a usage error and
77 when none could run. A skipped scenario is not a pass: record it
and its reason in the explanation file.

The runner runs one test at a time, and stops if another test is
running.

### What the tests do not cover

The snapshots do not prove that existing resources are unchanged.
They do not record container running state, volume contents, network
membership or builder configuration and selection. Volume and
builder records do not even include a unique resource id. The file
check covers only the initial empty working directory, not the
tutorial's own directory, other host paths or temporary directories.
The runner also does not compare resource snapshots after a skip.

Add focused supplemental assertions to the existing drivers:

- For a conflict scenario, save the relevant resource id,
  configuration and state before the tutorial, and compare them
  afterward. Check running state or network membership when the
  tutorial could affect it. For a volume, use a sentinel with known
  contents in a driver-owned fixture where relevant. Verify it is
  unchanged. Do not write sentinels into the reader's existing data.
- Check repository fixtures the tutorial can touch, including their
  contents and relevant permissions, and detect new files in the
  relevant directories. Check the tutorial directory even though
  the runner starts elsewhere. Do not include coordination records
  or explanation files that the development workflow intentionally
  writes outside the tutorial run.
- Check builder selection and configuration when demonstrating
  Buildx, and explicitly verify cleanup of tutorial-owned temporary
  paths or other resources the runner does not observe. Capture
  paths from stable runtime messages where necessary.
- Compare only state that the lesson promises to preserve. Put
  assertions in the driver before it reports success, not solely in
  exit cleanup, whose diagnostic output does not establish a pass.
  Keep these checks in the existing driver; do not create a second
  runner or add test-only paths to the tutorial.

The tests cannot make failures happen inside a tutorial, such as a
readiness timeout. Where practical, test such a failure with a
temporary change to the tutorial. Check with `git diff` that you have
undone it before you commit. Record in the explanation file how you
tested it, or that you could not. Also record that no person ran the
interactive path.

### Regression checks across scripts

There are initially no tutorial drivers in tests/. Each script's
driver is written in its Step 3, or in its Step 4 for a placeholder or
for a tutorial that cannot run as a whole until Step 4.

When you change a shared helper or build context:

1. Find every caller with `git grep`, including 00-*.sh through
   08-*.sh and the files in tests/. Check that each caller still works
   with the change, and test the changed behavior, including its
   failure paths, with focused temporary checks where needed.
2. Run the driver of every caller that has one.
3. A caller later in the order may not have a driver yet. Record a
   deferred check in the explanation and in your report: the caller,
   the change, and the check to run. The manager adds it to that
   caller's Step 3 or Step 4 task, which runs it with the new driver.
   A deferred check is not a pass.
4. 00-*.sh through 08-*.sh have no drivers. Check their use of the
   changed file, and any call sites you updated in them, with focused
   temporary checks and `bash -n`, not by running the installation
   tutorial. Do not write drivers for them. In the explanation, list
   each of their callers that you checked, and how.

## Step 1: Copyright Update

Update the copyright notice of each script and of the supporting files
it uses, then create an explanation file. Change only the notice; make
no other change in this step.

- Keep the start year of the notice and make the range end in 26. For
  example, 2024-25 becomes 2024-26, 2023-25 becomes 2023-26 and 2024
  becomes 2024-26. A notice that already ends in 26, or that says
  2026, stays as it is.
- Supporting files are the Dockerfiles, the scripts copied into images
  and the helpers that a script builds, runs or sources. Update each
  one in the commit of the first script, in the order of work, that
  uses it, and list it in that script's explanation file. Do not
  update files that only 00-*.sh through 08-*.sh use.
- Apply this only to first-party source. Preserve vendored or copied
  code and its original notices, including the NodeSource setup
  script. For a first-party supporting source file without a license
  header, add the template with the 2026 notice, as required by
  prompts/license-headers.md. Adding such missing headers is an
  exception to changing only the notice; do not reformat existing
  headers or change implementation behavior in this step.
- 10-docker-logs.sh, 23-docker-buildx.sh, 24-docker-compose-basics.sh
  and 25-docker-compose-networking.sh have no notice, so they have no
  start year. Add the header from prompts/copyleft-template.txt with
  the notice "Copyright (C) 2026 Sumanth Vepa.", laid out as in
  08-docker-build-basics.sh: the #!/bin/bash line, the coding line,
  then the header between dashed comment lines. 24 and 25 are empty;
  add only these lines to them and leave the rest to Step 4.

## Step 2: Update the base image

Change the base image from almalinux:9-minimal to almalinux:10-minimal,
then create an explanation file. The scripts do not name the base
image; the Dockerfiles they build do. When this was written, these
Dockerfiles used almalinux:9-minimal:

| Dockerfile        | First script that uses it    | Other scripts that use it |
| ----------------- | ---------------------------- | ------------------------- |
| dig-cmd, dig-entrypoint | 09-docker-build-cmd-entrypoint.sh | none |
| node-test         | 10-docker-build-node.sh      | 11-docker-build-node-optimized.sh |
| node-test2        | 11-docker-build-node-optimized.sh | none |
| python-test       | 12-docker-build-python.sh    | none |
| flask-test        | 13-docker-build-flask.sh     | 18-docker-stats.sh |
| postgres-manual   | 14-docker-build-postgres-manual.sh | 15-docker-build-postgres-test.sh |
| postgres-test     | 15-docker-build-postgres-test.sh | 16-docker-run-postgres-test.sh, 18-docker-save-load.sh, 21-docker-networking.sh |
| website-test      | 20-docker-build-website.sh   | none |

Search the files again with grep rather than relying on this table.

- Change each FROM line, and each comment or LABEL that only names the
  base image, such as "running on almalinux:9-minimal".
- Do not reword a comment that makes a claim that depends on the
  AlmaLinux version, such as which Python versions its repositories
  provide. Leave it as it is, and list it in the explanation file for
  Step 3 to check.
- Leave other AlmaLinux 9 dependencies for Step 3, such as the EL-9
  PostgreSQL repository URLs in 14-docker-build-postgres-manual.sh and
  docker-build-postgres-test-utilities.sh. List them in the
  explanation file.
- Do not build images or fix builds in this step. A build may fail
  between this step and the script's Step 3.
- Change a shared Dockerfile in the commit of the first script that
  uses it, as in Step 1. For a script that uses no AlmaLinux image, or
  whose Dockerfiles an earlier script already changed, the explanation
  file says so.

## Step 3: Bring the script up to the standard of previous scripts
Apply the following requirements to each tutorial. Use 01-*.sh through
08-*.sh as references for teaching style and working examples, especially
03-*.sh through 08-*.sh for error handling, validation and cleanup. The
earlier scripts are not identical: adopt the stronger patterns below,
rather than copying every implementation detail of 02-*.sh.

### Scope and preparation

- Read this script's Step 1 and Step 2 explanation files first. They
  list the follow-up work left for this step, such as version claims
  and repository URLs that depend on the base image.
- Read the entire tutorial, the Dockerfiles and entrypoint scripts it
  uses, and any sourced utility files before changing it. Follow calls
  into helpers: a safe-looking tutorial is not safe if its helper deletes
  an existing image or container.
- Preserve the topic and the hands-on, executable nature of the tutorial.
  Improve the explanations and demonstrations, not just formatting. Keep
  examples small enough that a reader can see the Docker behavior being
  taught. Do not turn the tutorials into a general automation framework.
- Step 3 improves existing content. Do not implement placeholder tutorials
  or finish incomplete examples in this step; that work belongs to Step 4.
  For a placeholder, record that there is no existing demonstration to
  improve. For a partly written tutorial, validate the existing examples
  that can run independently and identify the incomplete sections clearly.
- Update supporting files when necessary to make the tutorial correct.
  Keep those changes in the same step as the tutorial that needs them.
  Check the other callers of a shared helper before changing its behavior.
  Do not rework unrelated tutorials or upgrade unrelated dependencies.
- Copyright changes and the base-image replacement belong to Steps 1 and
  2. Step 3 must also fix any remaining incompatibilities exposed by the
  new base image, such as package repositories or paths for installed
  binaries; a successful text replacement is not proof of a working build.

### Explanations and demonstrations

- Start by identifying the tutorial and explaining its purpose, required
  tools, how to run it, and any special assumptions. Distinguish commands
  run on the host from commands typed inside a container or in a second
  terminal. State when root privileges, a local Linux Docker daemon,
  network access, credentials or a particular CPU architecture are needed.
- Organize related examples into short sections, as in 07-*.sh and
  08-*.sh. Explain a concept before demonstrating it. For each new command
  or option, explain what it does, why the example uses it, and what the
  reader should observe. Explain relevant short aliases while preferring
  descriptive long options and explicit command groups such as
  `docker container ...` and `docker image ...` in executable examples.
- Explain shell syntax when it matters to understanding the example:
  quoting, host versus container variable expansion, redirection,
  pipelines, command substitution, exit statuses, and here-documents.
  Follow the detailed but plain-language comments in 01-*.sh and 07-*.sh.
- Print concise runtime messages that identify the example and expected
  result. Use `read -r -p` for intentional pauses. Before an interactive
  shell, print the exact commands to try and how to leave it, normally
  `exit 0`. Keep intentional non-zero exits as explicit, checked examples.
- Demonstrate the important differences, rather than merely asserting
  them: compare before and after states, or two contrasting invocations.
  Explain expected failures before running them. Keep optional advanced
  material in comments when executing it would distract from the topic
  or require changing the reader's system.
- Check factual claims against current official documentation and the
  behavior of the tested Docker installation. Correct stale statements,
  spelling mistakes and broken cross-references. Mark output that varies
  by Docker version, image, storage driver or host configuration as an
  example; do not promise fixed container ids, addresses or output columns.
  Refer readers to an existing tutorial for material already covered.

### Shell structure and failure handling

- Use Bash and `set -euo pipefail`, with a brief explanation. Audit the
  whole script and its helpers when enabling these options: commands
  followed by a later `$?` check may now exit before that check, and
  optional variables need defaults such as `${VARIABLE:-}`.
- Resolve sourced files relative to `${BASH_SOURCE[0]}`. If the tutorial
  uses relative build contexts or data files, change to its own directory
  before using them, as in 06-*.sh through 08-*.sh. It must work when
  invoked by path from another working directory.
- Reuse `bash-utilities.sh`: `die` for fatal diagnostics,
  `die_if_not_root` where the whole script needs root, and the cleanup
  functions described below. Explain the imported functions at the source
  statement. Use small, documented functions for genuinely repeated work;
  describe arguments and important side effects as in 05-*.sh and 08-*.sh.
- Quote variable expansions and paths. Use arrays or separate arguments
  rather than constructing shell commands as strings and running `eval`.
  Separate `local` declarations from command substitutions so failures
  are not masked. Save important command output in an assignment before
  testing it, rather than hiding a failing command inside a test.
- Check required host tools before creating resources. Report missing
  prerequisites clearly instead of automatically installing packages or
  reconfiguring the host. Reject unsupported architectures explicitly;
  do not leave architecture variables unset or select the wrong download.
- Handle an expected failure with an explicit conditional or a saved
  status, and check the expected result. Do not use blanket `|| true` or
  globally disable error handling. An unexpected success is also a failure
  of a negative demonstration. Distinguish application failures from
  Docker failures where statuses overlap, using container state if needed,
  as in 07-*.sh and 08-*.sh.
- Preserve interruption behavior. Ctrl-C normally stops the lesson and
  triggers cleanup. For a streaming command that deliberately uses Ctrl-C
  to continue the lesson, follow 04-*.sh: accept only the documented
  statuses and restore the cleanup helper's signal trap afterwards.
- Treat an optional external-network example separately from essential
  setup. A failed optional ping or HTTP request may produce a warning and
  allow independent examples to continue, as in 07-*.sh and 08-*.sh.
  Failed builds, daemon errors and interrupted commands must not be
  reported as harmless network failures or as successful demonstrations.

### Resource ownership, repeatability and cleanup

- Identify every resource the tutorial creates or changes: image tags,
  containers, volumes, networks, generated files, downloads, firewall rules
  and credentials. State where each one is removed. Build cache is
  exempt, as described in "Leaving Docker as it was".
- Before building or tagging, check for conflicting image names. Before
  creating named volumes or networks, check that they do not already
  exist. Container creation must fail safely on a name conflict. Stop with
  a clear message and suggested inspection/recovery commands; never
  silently remove, reuse as empty, or overwrite an existing resource.
- Use the resource ids returned by Docker for cleanup where available,
  especially container ids. Do not select the first row of a human-readable
  listing or rely on a substring name match to decide what to delete.
  Prefer `--quiet`, `--format`, and exact filters when inspecting resources.
- Register cleanup with `cleanup_add` as soon as this run owns a resource,
  and before the next command can fail. For long-running examples, prefer
  `docker container create`, save cleanup by id, then `start`, as in
  04-*.sh, 07-*.sh and 08-*.sh. Use `--rm` for simple disposable containers
  where retaining their state is unnecessary; explain its limits if the
  client is killed while the container survives.
- Register cleanup in dependency order so the helper's reverse execution
  removes containers before their images, volumes or networks. Perform
  visible normal-path cleanup to teach the removal commands, then call
  `cleanup_cancel` only after removal succeeds. Do not replace the helper's
  EXIT trap or register cleanup in a subshell. Cleanup functions must check
  their own failures and return, as documented in `bash-utilities.sh`.
- Use `mktemp --directory` for generated build contexts, archives and other
  scratch files; register their removal immediately. Do not begin by
  deleting a fixed pathname that might contain the reader's work. If an
  example must modify a repository fixture, verify its initial state and
  restore only changes owned by this run, following 06-*.sh.
- Leave existing images, including base images, and user data and other
  workloads alone. Avoid daemon-wide prune commands, deleting every
  container based on an image, or forcibly replacing names to make a
  rerun succeed.
- Explain recovery from partial runs, including name conflicts, containers
  surviving a killed Docker client, and SIGKILL, which cannot run cleanup.
  Provide commands to inspect leftovers before the reader removes them.

### Leaving Docker as it was

The reader learns by reading a tutorial and then running variations
of its commands. They may run the tutorials in any order, and days or
months apart. So each tutorial must stand on its own in what it does,
although it may assume the concepts that earlier lessons teach:

- Apart from build cache, it leaves Docker as it was before it ran.
  It removes every image, container, volume, network and builder that
  it created, on the normal path, after an error and after Ctrl-C.
  No tutorial keeps a resource for a later one.
- It is idempotent: a second run, straight away or months later,
  behaves like the first.
- It does not depend on any resource that another tutorial created.
  It builds or pulls what it needs. For example, scripts 15, 16, 18
  and 21 each build the postgres-test images they use, with the shared
  helper, and remove them.
- It leaves an image that existed before the run alone, including a
  base image. Before the first command that may pull an image, check
  whether the image exists. If it did not, this run pulls it, and its
  cleanup removes it, after the containers and images that use it.
  This covers base images in FROM lines, images that a tutorial runs
  directly, such as nginx or registry, and the BuildKit image that a
  docker-container builder pulls.
- Build cache may remain. Do not prune it or track cache record ids
  for cleanup. Removing a builder created by the lesson remains part
  of normal resource cleanup; no separate cache cleanup is required.
- A resource that already exists with a name the tutorial uses is a
  conflict, as described above: stop, and leave it as it is.

The runner checks most of this for images, containers, volumes,
networks and builders. Drivers for these tutorials do not list
`keeps-image`. Drivers do not compare build cache before and after
the run; cache growth is not a test failure.

### Services, ports and host configuration

- Replace unbounded polling and arbitrary startup sleeps with bounded
  readiness checks. State the attempt limit and delay, bound individual
  network requests, and stop with a useful error if readiness never occurs.
  Use an actual HTTP request for HTTP services and `pg_isready` for
  PostgreSQL, then verify the behavior being taught. `docker ... start`
  returning successfully does not prove the application is ready.
- Publish only ports the example needs and explain the host/container
  mapping and network exposure. Do not depend on a developer's private
  hostname or an unrelated service already running elsewhere. Explain
  port conflicts without stopping other programs to claim their ports.
- When following the externally reachable examples in 02-*.sh and
  08-*.sh, reuse `firewall-utilities.sh`. Query the original port state;
  open only a port reported as `no`, leave `partial` alone, and close only
  a port this run opened. Register restoration for early exits as well as
  normal completion. Explain that Docker's published ports and the host
  firewall's reported rules are separate concerns.
- Document relevant rootful/rootless, userns-remap and SELinux limitations,
  following 04-*.sh, 06-*.sh and 08-*.sh. Detect unsupported configurations
  before changing files or starting affected examples; skip an independent
  example with an explanation where practical. Do not silently relabel
  host files, disable SELinux, change daemon settings or switch contexts.
- Use read only mounts when examples only need to read files. Explain
  ownership when containers write host files and restore the fixtures.
  Use demonstration credentials only, identify them as such, and avoid
  printing secrets or putting real passwords in command arguments.

### Specific issues to address in the existing tutorials

These are starting points, not a substitute for reviewing each script
and its supporting files against the requirements above.

- The postgres-test and postgres-manual Dockerfiles default
  `ARCH_SUFFIX` to amd64, and node-test2 defaults it to arm64. A build
  without the build argument then copies a binary for the wrong CPU,
  which runs silently under emulation on a host with qemu-user-static.
  Remove the defaults or make the build fail without the argument.
- `09-docker-build-cmd-entrypoint.sh`: show the image's configured CMD
  and ENTRYPOINT, the actual command produced by arguments after the image
  name, and how to override ENTRYPOINT. Qualify explanations by exec or
  shell form. Check both intentional failure examples explicitly so strict
  error handling does not prevent the rest of the lesson and cleanup.
- `10-docker-build-node.sh` and `11-docker-build-node-optimized.sh`:
  explain the repository-install and binary-distribution approaches, check
  the resulting Node.js version against the configured version, and fix
  comments that name a different version. Handle an unset SUDO_USER and
  unsupported CPU architectures. Download to a temporary file before
  accepting an artifact as complete. Extract and trim distributions in a
  temporary context instead of deleting an existing extraction. Preserve
  required third-party license notices. Support any image-size comparison
  with measurements and a stated baseline rather than the word optimized.
- `12-docker-build-python.sh`: explain the Dockerfile's installation and
  default command, verify the noninteractive Python output, and give useful
  REPL commands and an exit instruction before the interactive example.
- `13-docker-build-flask.sh` and `18-docker-stats.sh`: fix the shared Flask
  helper's `docker imge` typo and malformed default container name, and
  replace deletion of pre-existing images/containers with conflict checks.
  Wait for and validate an HTTP response. Remove the unexplained second
  build in script 13 unless it becomes an explicit rebuild demonstration.
  Scope executable stats examples to the demonstration container; describe
  broader views without making unrelated workloads part of the lesson.
  Handle Ctrl-C during streaming stats as in 04-*.sh.
- `14-docker-build-postgres-manual.sh` through
  `16-docker-run-postgres-test.sh`: clearly distinguish manual setup from
  automatic entrypoint initialization. Each script builds the image it
  uses and removes it, as described in "Leaving Docker as it was";
  script 16 must no longer delete an existing postgres-test image to
  make room for its own. Fix the shared helper's
  destructive cleanup and its loop that waits for a stopped container to
  disappear from `ps --all` before removing it. Reject unsupported
  architectures and check package repositories against the new base image.
  Use bounded database readiness checks. In script 16, replace constructed
  commands and `eval` with direct psql arguments, stop on SQL errors, and
  verify selected rows. Correct the explanation of `docker exec` and the
  reference to the script that builds the image.
- `17-docker-inspect.sh`: check for jq before setup; explain the fields
  selected by each template and how image configuration differs from
  container state. Demonstrate resource-type disambiguation without
  relying on an accidental name match. Protect the shared nginx image name.
- `18-docker-save-load.sh`: resolve its sourced helper from the script
  directory, use a temporary archive path, and never delete an existing
  archive or image to prepare the example. Record the demo image id and
  tags, save it, remove only that demo image, load it, and verify that the
  expected id and tags are restored. Verify and correct the claims about
  architectures and multi-platform images, and the reference to the absent
  manifest tutorial.
- `19-docker-login-logout.sh`: replace the dependency on the reader's
  Docker Hub account with a local registry that the tutorial creates
  and removes, so that the lesson can run and be tested without real
  credentials:
  - Run Docker's registry image in a container published only on
    127.0.0.1, with basic authentication from an htpasswd file in a
    temporary directory. Use demonstration credentials only, say so,
    and pass the password with `--password-stdin`. Never put a
    password in a command argument or echo one. Check that the
    chosen port is free; 13-docker-build-flask.sh uses port 5000.
  - Set DOCKER_CONFIG to a temporary directory for the login and
    logout examples, so that the reader's own configuration,
    credentials and credential helpers are never read or changed.
  - Demonstrate login by its effect: a push to the registry fails
    before login, succeeds after login, and fails again after logout.
    Tag a small image for the push under a demonstration name, and
    remove that tag.
  - Show the entry that login writes to the temporary config.json,
    and decode it, to show that base64 is an encoding, not
    encryption. Explain credential helpers (credsStore and
    credHelpers) and how to see whether the reader's own
    configuration uses one, without printing any credentials.
  - Describe logging in to Docker Hub, with `docker login --username`
    and its prompt, and the device-code flow, in comments only.
  - If login to the local registry does not work over plain HTTP
    without changing daemon settings or trusting a certificate on
    the host, report an external validation blocker. Do not change
    those settings or request an ordinary design decision; continue
    independent work and leave this essential check unresolved.
- `20-docker-build-website.sh`: remove the dependency on
  `darkness2.milestone42.com:5000` and the unused FLASK_HOST setting.
  Make this lesson exclusively about packaging and serving a static
  website with nginx. Supply the local content and nginx configuration
  that its Dockerfile needs, explain how they are copied into the image,
  and verify the actual page and a referenced static asset. Correct the
  reverse-proxy claim and Flask success message, bound the readiness
  loop, and add container/image/firewall cleanup. Do not add a backend
  service or a reverse proxy. A future lesson will connect a proxy and
  a web service in separate containers with Compose; that work is
  outside this update, including Step 5.
- `21-docker-networking.sh` and `22-docker-rootless.sh`: correct misleading
  existing explanations; complete their unfinished examples in Step 4.
  In particular, distinguish a user-defined bridge from an
  explicitly internal network, and distinguish Docker group membership,
  a non-root process inside a container, and a rootless daemon. The
  rootless tutorial must agree with the distinctions in 06-*.sh.

### Validate the lesson's claims

- Add small checks at points where later explanations depend on a result.
  Check actual file contents, environment values, served pages, database
  query results or container state, rather than just a command's success.
  Stop with an explanation when the observed result contradicts the
  lesson. Follow the volume check in 05-*.sh, ownership and contents checks
  in 06-*.sh, and cache and served-page checks in 08-*.sh.
- Make each check prove only what the comment claims. For example, an
  unchanged file written by a RUN step does not prove that a later COPY
  step came from the cache. Use build output for that observation, as
  08-*.sh does. Account for cache state from earlier runs where relevant.
- Check shell syntax with `bash -n` for every changed shell file, and run
  ShellCheck if available. Fix applicable findings; explain any narrow
  suppression. Do not suppress warnings across a whole tutorial merely
  because its examples intentionally contain literal shell expressions.
- Test the tutorial with its driver, as described in "Automated
  tests", running `run-tutorial-test.sh <script> all`. Write or
  update the driver and commit it with the tutorial once the whole
  tutorial is runnable. For a placeholder, write the driver in
  Step 4. For a partly implemented tutorial whose incomplete section
  prevents a whole run, use focused temporary checks of the existing
  independent examples in Step 3 and explicitly defer its full driver
  and whole-tutorial run to Step 4. Do not implement the missing
  material early, make a driver silently bypass it, or report a
  partial run as a whole-tutorial pass. Recheck shared-file callers
  under "Regression checks across scripts". Do not claim untested
  distributions, architectures or daemon modes as verified.
- In the Step 3 explanation file, describe the teaching improvements,
  behavior fixes and supporting-file changes. Record the commands/checks
  run, their results, anything the run leaves behind, and any limitations
  or checks that could not be run.

## Step 4: Complete placeholder tutorials and unfinished examples

Keep this work separate from the improvements to existing content in
Step 3. Apply Step 3's standards for explanations, error handling,
resource ownership, cleanup and validation to all new demonstrations.
Preserve the current script filenames and numbers.

- Replace the placeholder in `10-docker-logs.sh` with a working tutorial
  on `docker container logs`, using the baseline below.
- Replace the placeholder in `23-docker-buildx.sh` with a working tutorial
  on `docker buildx`, using the baseline below.
- Complete the network-inspection example marked TODO in
  `17-docker-inspect.sh`, including creation and removal of its demo network.
- Finish the application-network example in `21-docker-networking.sh`.
  Make the advertised frontend, backend and database demonstration work,
  verify communication between the relevant containers, and clean up the
  containers and network created by the example.
- Add the USER and gosu demonstrations described by the TODO in
  `22-docker-rootless.sh`. Keep the distinction between a non-root process
  in a container and a rootless Docker daemon explicit.
- Implement `24-docker-compose-basics.sh` and
  `25-docker-compose-networking.sh` using the baselines below. Step 1
  gave both files only their opening lines and license header. Keep
  that header, and add the standard script structure used in 07-*.sh
  and 08-*.sh, not just executable commands.
- The optional investigation of a fully static Node.js binary in script
  11 is outside this completion step; leave it identified as future work.

### Baseline for 10-docker-logs.sh

- Explain that container logs expose output captured from the main
  process's stdout and stderr, subject to the configured logging
  driver. Use a small local demonstration that emits distinctive,
  predictable messages to both streams. Do not allocate a TTY that
  merges the streams while claiming to demonstrate their distinction.
  Verify claims and options against the official
  [logs reference](https://docs.docker.com/reference/cli/docker/container/logs/).
- Demonstrate complete retrieval, `--tail`, `--timestamps` and
  `--since`, with checks of the included and excluded markers.
  Derive time boundaries from observed timestamps or controlled
  events rather than assuming arbitrary sleeps establish ordering.
  Explain that application files inside a container are not
  automatically included, and output from a separate `docker exec`
  attachment is not the main process's log stream.
- Demonstrate `--follow` while new output is produced, then stop the
  stream with Ctrl-C and continue the lesson. Synchronize the driver
  with output proving the stream started. Verify that stopping the
  client did not stop the container, then show logs remain readable
  after the container itself has stopped and before its removal.
- Inspect or explain the logging-driver dependency and any relevant
  limitation without changing daemon settings. Keep logging-driver
  configuration, rotation administration and external log collection
  as comments or deferred material unless needed for these examples.
- Validate the complete normal run, interruption cleanup and applicable
  conflict behavior. Use the standard script structure, pause prompts,
  ownership and visible cleanup rather than a bare command catalogue.

### Baseline for 23-docker-buildx.sh

- Check Buildx and explain how a builder, its driver and its output
  differ from the Dockerfile build fundamentals in script 08. Inspect
  existing builders, then create a uniquely named disposable
  docker-container builder for this lesson. Pass its name explicitly
  with `--builder`; do not select it as the reader's default. Register
  cleanup before bootstrapping it, and verify that the original
  selection and existing builders are unchanged afterward. Follow
  the official [driver guide](https://docs.docker.com/build/builders/drivers/).
- Build a small native-platform example, load a single-platform result
  into the local image store with `--load`, run it and check its output
  and platform. Explain why a successful build with the chosen driver
  does not by itself make a runnable image appear in the local store.
  Contrast loading with an explicit exported artifact, using the
  [exporter guide](https://docs.docker.com/build/exporters/).
- Demonstrate `--platform` and build a linux/arm64 and linux/amd64
  result into a temporary OCI archive. Inspect its index and platform
  manifests to prove both target platforms are present. Explain
  manifest lists or indexes, architecture-specific manifests and the
  limits of loading multi-platform results into the test host's
  classic image store. Do not change the image store or daemon.
- Explain emulation versus native execution and build-platform versus
  target-platform inputs when used. Prefer a small example that can
  produce both outputs without executing foreign-platform build
  instructions. A foreign-platform runtime check is optional when
  emulation is unavailable; the native run, multi-platform export and
  metadata checks remain essential. Follow the official
  [multi-platform guide](https://docs.docker.com/build/building/multi-platform/).
- Keep all demonstrations local. Do not require registry credentials,
  a remote push or installation of emulation. Explain a push workflow
  in comments if useful. Remove the lesson's builder and its owned
  containers, volumes, tags and archives; preserve pre-existing
  builders and caches. Remove a base or BuildKit image that this run
  pulled, as described in Step 3. Verify cleanup, repeatability and
  interruption behavior with the driver.

### Baseline for 24-docker-compose-basics.sh

- Explain what a Compose application, service and project are, and how a
  `compose.yaml` describes configuration otherwise supplied through Docker
  commands. Check `docker compose version` before setup. Use the current
  `docker compose` plugin syntax and document any minimum version required
  by the features used; do not install or reconfigure Compose automatically.
- Start with a small local application, such as a single HTTP service.
  Explain the YAML structure, service name, image or build context, command,
  environment and published port as they appear. Refer to the earlier
  build, environment and storage lessons for their underlying concepts.
  Leave multi-service network design to script 25.
- Demonstrate configuration validation with `docker compose config`,
  starting with `up --detach`, listing services with `ps`, viewing service
  `logs`, and executing a command with `exec`. Contrast `exec` with a
  disposable `run --rm` command, explaining that one uses a running service
  container and the other creates a new container.
- Demonstrate `stop`, `start` and `down`, observing which containers and
  networks remain after each operation. Explain what happens to images and
  volumes, including that volume removal requires separate consideration.
  Use the official [down reference](https://docs.docker.com/reference/cli/docker/compose/down/)
  to verify cleanup behavior; remove only this run's resources.
- Use an explicit project name unique to this run and pass the same project
  name and Compose file to every invocation, including cleanup. Explain
  [project names](https://docs.docker.com/compose/how-tos/project-name/)
  and avoid fixed `container_name` settings or globally named resources
  that defeat isolation. Register project cleanup before the first `up`,
  because it can create some resources before failing. Track the images
  this run builds or pulls, remove them, and keep pre-existing images.
- Verify the actual HTTP response, not merely a running status. Use bounded
  readiness checks, show an intentional pause for inspection, then perform
  visible cleanup and verify removal of the demo containers and networks.
  Generated configuration belongs in a temporary directory unless it is
  intentionally maintained as a documented example in the repository.

### Baseline for 25-docker-compose-networking.sh

- Treat script 24 as the prerequisite for the Compose workflow and script
  21 as the prerequisite for Docker network fundamentals. Build a small
  multi-service example that demonstrates what Compose adds. Reuse suitable
  application fixtures without requiring an earlier tutorial's containers
  to remain running.
- First demonstrate the default Compose network and service-name discovery.
  Make a real request from one service to another using its service name
  and container port. Compare that address with the host's published port;
  explain why localhost inside a container does not name another service.
  Inspect membership using Compose resource ids and `docker network inspect`.
  Follow the official [Compose networking guide](https://docs.docker.com/compose/how-tos/networking/).
- Add explicit frontend and backend networks. Put a connecting application
  service on both and a backend service only on the backend network.
  Publish only the intended frontend endpoint. Demonstrate an allowed
  request and a blocked request between services without a shared network,
  with checks that distinguish expected isolation from a service that is
  simply not ready. Do not describe missing host port publication alone as
  isolation between containers.
- Explain startup order versus application readiness. Demonstrate a
  healthcheck and `depends_on` with `condition: service_healthy` where a
  service needs a ready dependency, following the official
  [startup-order guide](https://docs.docker.com/compose/how-tos/startup-order/).
  Keep healthchecks and host-side waits bounded, and explain that startup
  gating does not replace application handling of later connection loss.
- Clean up only this run's project, including its networks, containers and
  any demo volumes or images. Verify cleanup and repeatability. Reserve
  additional topics such as external networks, aliases and network updates
  for the Step 5 review if they add a useful lesson beyond this baseline.

Validate each completed tutorial as a whole, including its existing
examples. Commit the changes for each script separately from its Step 3
changes, and complete its Step 4 explanation file using the filename rule
above, for example `10-docker-logs-04-improvements.md`. Describe what was
completed and how it was verified. Never commit the explanation file.

## Step 5: Review topic coverage and add missing lessons

After the repairs and baseline completion, use your judgment to identify
what else each tutorial should teach. Propose the additions in the
coverage map. A reviewer checks the map and the manager accepts it
before any change is made, as described in "Sub-agents: The coverage
map". Then implement the accepted changes; do
not stop at a list of recommendations. This is a curriculum review,
not a requirement to demonstrate every Docker option or add material to
every script. Apply Step 3's teaching, correctness and validation standards
to all additions.

### Review the whole series before adding material

- Read 00-*.sh through 25-*.sh and their supporting examples as they stand
  after the earlier steps. Include both scripts numbered 10 and both
  numbered 18. Treat 00-*.sh through 08-*.sh as established prerequisites;
  this step's implementation scope remains 09-*.sh through 25-*.sh.
- Make a brief coverage map before editing: for each script, identify its
  learning objectives, concepts already taught, prerequisites, and proposed
  additions. Check the actual examples, not just filenames or headings.
  Keep the working map in temporary notes, and preserve the
  manager-accepted revision and rationale in the ignored coordination
  record so a lost temporary file does not lose the decisions.
  Summarize the relevant decisions in each script's Step 5 explanation;
  no separate committed curriculum file is required.
- For each candidate addition, ask what practical task or common mistake
  it addresses, whether it belongs in this script, whether another script
  already teaches it, and how a reader can observe and verify it. Prioritize
  missing concepts needed to use or understand the existing examples.
  Omit unrelated advanced material and document why deferred topics do not
  belong in this pass. The static-Node.js investigation remains future work.
  The separate Compose lesson connecting a reverse proxy and a web
  service also remains future work; do not add it to script 20 or
  introduce it elsewhere as a Step 5 expansion.

### Give each concept one primary teaching location

Use these boundaries as the starting point. Refine them based on the
coverage review, while preserving each script's stated purpose.

| Script | Primary teaching responsibility |
| --- | --- |
| 00-*.sh through 08-*.sh | Established overview, installation, container/image basics, signals, introductory stats, volumes, bind mounts, environment variables and build fundamentals. Reference these lessons rather than teaching them again. |
| 09-docker-build-cmd-entrypoint.sh | Command selection, CMD/ENTRYPOINT interaction, argument handling and overrides. |
| 10-docker-build-node.sh | Building a Node.js runtime using a package repository. |
| 10-docker-logs.sh | Container stdout/stderr and practical log retrieval, filtering and following. |
| 11-docker-build-node-optimized.sh | Runtime contents, build-context preparation and measured image-size tradeoffs for the binary-distribution approach. |
| 12-docker-build-python.sh | Building and using a Python runtime image and its interpreter. |
| 13-docker-build-flask.sh | Packaging and running a Python web application; application-specific dependencies and entrypoint behavior. |
| 14-docker-build-postgres-manual.sh | Manual database setup and the initialization steps an automated image must perform. |
| 15-docker-build-postgres-test.sh | Automating database initialization and startup in a reusable image. |
| 16-docker-run-postgres-test.sh | Operating that database image, connecting clients and verifying database behavior. |
| 17-docker-inspect.sh | Structured inspection, templates, resource types and configuration versus runtime state. |
| 18-docker-save-load.sh | Image archives, save/load verification and distinctions from container filesystem export/import. |
| 18-docker-stats.sh | Interpreting resource metrics and their limitations, beyond the introductory display in script 04. |
| 19-docker-login-logout.sh | Registry authentication, credential handling and logout. |
| 20-docker-build-website.sh | Static website packaging, nginx configuration and verification of served pages and assets. Reverse proxying belongs to a future lesson. |
| 21-docker-networking.sh | Docker CLI network configuration, discovery, connectivity, publication and isolation. |
| 22-docker-rootless.sh | Docker access privileges, container process identity, USER/gosu and the distinction from a rootless daemon. |
| 23-docker-buildx.sh | Buildx builders, build outputs, platform selection and multi-platform workflows, extending script 08. |
| 24-docker-compose-basics.sh | Declarative application configuration and the Compose project/service lifecycle. |
| 25-docker-compose-networking.sh | Compose service discovery, network membership, topology and dependency readiness. |

- Teach a concept in depth in its primary location. Other scripts may use
  it, give a short reminder and point to that script. Repeated setup or
  cleanup needed to make a script runnable is acceptable; repeated full
  explanations and equivalent exercises are not.
- Distinguish shared mechanics from the new learning objective. For
  example, scripts 13, 16, 20 and 25 may all wait for services, but script
  25 owns the Compose dependency-readiness explanation. Script 08 owns
  basic cache behavior; script 23 should explain what its Buildx example
  adds. Script 07 owns Docker runtime environment passing; script 24 may
  teach Compose interpolation and its distinction from that mechanism.
- Keep standalone Docker networking in script 21 and Compose-specific
  configuration in script 25. Keep basic Dockerfile explanations in script
  08 and language/application decisions in scripts 10 through 16 and 20.
  Use forward references when a later lesson owns the full explanation.
- If existing overlap obscures the progression, consolidate the detailed
  lesson in its primary script and replace the duplicate with a concise
  reference or a different application of the concept. Preserve runnable
  examples and necessary context. Do not renumber scripts, create new
  top-level lessons, or expand 00-*.sh through 08-*.sh in this step.

### Implement and verify the selected additions

- Introduce each new section with a learning objective, then a minimal
  demonstration, an observable result and a check where practical. Prefer
  a few connected examples over a catalogue of commands. Use official
  documentation to verify new claims and record version requirements.
- Check prerequisites and reading order. An example must not depend on
  any resource that another tutorial created. Reuse source
  fixtures and helpers where appropriate, but create and clean up its own
  runtime resources. Avoid circular dependencies between lessons.
- Re-read the affected scripts together after editing to catch duplicated
  explanations, contradictory advice, broken references and gaps caused
  by consolidation. Run the relevant Step 3 checks for new or changed
  examples and recheck any callers affected by shared-file changes.
- For each script, commit its Step 5 changes separately from earlier steps,
  and complete its explanation file, for example
  `25-docker-compose-networking-05-improvements.md`. State the topics added,
  why they belong here, which other lessons cover related concepts, any
  duplication removed, and validation results. If no addition is justified,
  explain the coverage decision without making cosmetic changes or an
  empty commit merely to satisfy this step. Never commit explanation files.

## Final acceptance

After Phase 3, the manager starts a validation agent to check the
finished series, and a reviewer to check its results, in a review
loop. The validation agent does not change tutorials, helpers or
drivers. For each defect it finds, the manager starts a coding agent
and a reviewer to correct the script and step that the defect belongs
to. The correction uses that step's commit label and adds to that
step's explanation. The validation agent then checks again everything
the correction can affect.

The validation agent writes
docker/basics/docker-basics-update-final-improvements.md. Never commit
this file. It holds a table with one row for each of the 19 scripts:
the script's commits, the revision at which its tests last passed, its
driver, the scenarios run and their results, the log paths, anything
it leaves behind, and its limitations. List the checks of callers in
00-*.sh through 08-*.sh separately.

Final acceptance requires all of the following:

- Every script has an explanation file for each of the five steps,
  with a commit or a reason for `N/A`, and a reviewer's approval. No
  placeholder or unfinished example remains.
- `bash -n` passes for every changed shell file. If ShellCheck is
  installed, each of its findings is fixed or its narrow suppression is
  explained. Source in other languages follows the policies that
  prompts/agent-session.md refers to.
- `tests/run-tutorial-test.sh <script> all` has passed for every
  script, one at a time, at its final revision, including the
  supplemental assertions and the repeated normal run. A scenario that
  a driver leaves out has a recorded reason.
- Every deferred check has passed.
- The series has been read as a whole for repeated explanations,
  contradictions, broken paths or references, unexpected resources
  left behind, a tutorial that depends on a resource another one
  created, and lessons that depend on each other in a circle.
  Script 20 teaches static hosting only.
- The index is empty, and `git status` shows only the changes that
  existed at the start, the explanation files and the coordination
  record. No commit of this work changes a path outside docker/basics
  other than TODO.txt.

A test result still counts at the final revision if none of its
inputs has changed since it passed. The inputs are the script, its
driver, the files it sources directly or through other files, the
data files it reads, each build context it uses as a whole directory,
and the two files in tests/. Both of these checks must pass:

- `git diff --quiet <tested-commit> HEAD -- <inputs>`
- `git status --porcelain --ignored -- <inputs>` prints nothing. Git
  does not compare untracked or ignored files, so an input with such
  a file is not known to be unchanged.

Record the inputs you compared. If either check fails, or the result
does not record the checks made before the test, as described in
"Explanation files", run the test again, with the tests of the
scripts that depend on it.

A skipped, failed, missing or deferred essential check blocks
acceptance. An optional check that a baseline allows to be left out,
such as running a foreign-platform image without emulation, may stay
unverified if the acceptance file says so. Report other distributions,
CPU architectures and daemon modes as untested.

If acceptance is blocked, finish any independent work, then report
what is done, the exact blocker, the checks tried and the work left.
Do not mark issue249 done.

After the reviewer approves the acceptance file and the manager
accepts it, a coding agent marks issue249-docker-basics done in
TODO.txt, following prompts/todo.md, and leaves the other issues
alone. A reviewer checks the change. Commit it on its own, with a
first line that starts `issue249-docker-basics: Step 5:`, since it
completes the last step. Record the commit in the acceptance file.
This commit does not need the tutorial tests to be run again.

The manager's final report names the scripts done and the commit
range, summarizes the test results and anything the tutorials leave
behind, gives the path of the acceptance file, and lists the cases that
were not tested.
