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

At startup, verify the actual host, architecture, daemon mode, image
store, Docker/Buildx/Compose versions and required tools rather than
assuming this description is current. Check passwordless sudo with
`sudo --non-interactive true` before tests that need it. Record the
observed configuration in the coordination record. If the base image
is absent, allow the normal native-platform pull and check its
architecture afterward; absence is not an architecture mismatch.
Do not install missing prerequisites or reconfigure the host.

## Authority and limits

Complete all five steps without planned user approvals. The single
startup question for commit attribution is required as described in
"Committing"; do not repeat it for each task. The manager
reviews and approves the coverage map and routine implementation and
curriculum decisions. Explain those decisions in the relevant
explanation files; do not ask the user to choose between ordinary
ways of meeting these requirements.

- You may replace unsafe or misleading examples and consolidate
  duplicated material while preserving each lesson's purpose, useful
  demonstrations and the coverage responsibilities below. Do not
  silently discard a difficult example or reduce existing operating
  system, distribution or CPU architecture support to make tests pass.
  Package names and paths differ between distributions; fix those
  differences rather than dropping support.
- You may change shared helpers and build contexts, including ones
  used by 00-*.sh through 08-*.sh, when needed for this task. Find all
  callers with `git grep`, preserve their intended behavior, and
  validate them under "Regression checks across scripts". The earlier
  tutorials themselves remain outside the implementation scope.
- Temporary firewall changes made through firewall-utilities.sh for
  the tutorial ports are authorized, using available root privileges
  or passwordless sudo. Query and restore the original state as
  described in Step 3. This does not authorize package installation,
  persistent host configuration changes, daemon reconfiguration,
  context switching, or changes to SELinux or emulation settings.
- Follow prompts/agent-session.md and its referenced policies, with
  only the exceptions explicitly granted at the start of this file.
  If a necessary action exceeds that authority, prepare the concrete
  proposed change and ask for the permission that policy requires.
  Name the policy and explain which action it prevents.
- If required tools, access or infrastructure are unavailable, report
  the exact blocker, the checks attempted and the work left. Never
  claim that missing access or a skipped essential check is success.
  Do not ask for a routine design decision to resolve an implementation
  defect; investigate and correct it within the authorized scope.

Sub-agents report permission questions or external blockers to the
manager, rather than asking the user directly. The manager resolves
ordinary decisions and defects autonomously. A genuine blocker must
be reported honestly even when no additional permission can fix it.

## Order of work

Process the scripts in the order that `ls` lists them in docker/basics:
09-docker-build-cmd-entrypoint.sh, 10-docker-build-node.sh,
10-docker-logs.sh, 11-docker-build-node-optimized.sh, and so on through
18-docker-save-load.sh, 18-docker-stats.sh and
25-docker-compose-networking.sh. Work in three phases:

1. Steps 1 and 2 for every script. Finish Step 1 for all the scripts,
   then Step 2 for all the scripts.
2. Steps 3 and 4, one script at a time. For each script, finish Step 3,
   then Step 4 or its not-applicable explanation, before you start
   the next script.
3. Step 5, after every script has finished Step 4 or recorded that it
   does not apply. Make and review the coverage map for the whole
   series first, then make each script's Step 5 changes in the same
   order. Finish with "Final acceptance", including the full-series
   validation pass.

After each step for each script, commit that script's changes and then
write its explanation file. NEVER commit an explanation file.

ALWAYS write the explanation file, even when a step makes no change to
a script, for example Step 2 for a script that uses no AlmaLinux image.
In that case, say in the file that nothing changed and why. Do not make
an empty commit.

Put the step number after the issue name in the first line of each
commit message, for example:

`issue249-docker-basics: Step 3: Make 17-docker-inspect.sh stop on errors ...`

A step is implemented when its changes, if any, are committed and its
explanation records the evidence below. It is verified only when its
applicable required checks have passed and the manager has reviewed
the work. An explanation file's existence alone proves neither.
Permitted deferred checks leave a step implemented with validation
pending; they must be closed before final acceptance.

### Starting and resuming safely

The manager maintains an uncommitted coordination record at
docker/basics/docker-basics-update-run-improvements.md. Its name is
covered by the existing ignore rule for explanation files. This
record is coordination work, not a tutorial implementation step.

1. At the first start, record the branch, initial HEAD, full
   `git status`, staged and unstaged changes, and relevant untracked
   files before any task changes. Record enough path and diff or
   checksum information to distinguish pre-existing work from this
   task. Do not record credentials. Require an empty index before
   starting commits. Do not unstage, stash, reset or commit unrelated
   work to obtain one.
2. Preserve pre-existing unrelated working-tree changes. If they
   overlap a file this task must modify, establish which changes
   belong to the user before proceeding with that file. If ownership
   cannot be established from the record and history, report the
   blocker instead of treating the changes as yours.
3. Update the record with each assigned task, its starting HEAD and
   paths, resulting commits, manager review, deferred checks and the
   next task. Keep the accepted coverage map or its recovery details
   there as described in Step 5. Do not commit this record.
4. On resume, compare the current branch, history, index and worktree
   with the record, explanation files and actual diffs. Do not assume
   that every uncommitted change belongs to an interrupted step.
   Resolve discrepancies before staging anything. Never switch
   branches or overwrite another person's work to recreate old state.
5. Use `git log --oneline` to locate task commits. If a commit exists
   without its explanation, assign a sub-agent to reconstruct the
   explanation from its diff and available evidence. Rerun checks
   whose results cannot be recovered; do not invent test results.
   If the coordination record is missing, reconstruct it from history
   and verified evidence before continuing. Ask only when an ownership
   or permission limit prevents safe reconstruction.
6. Verify that explanation files refer to reachable commits and still
   describe the code. Changed shared files can invalidate earlier
   checks. Resume the next unfinished task in the required order,
   carrying forward every outstanding regression check.

Each explanation records the script and step, status (implemented,
validation pending, verified, or not applicable), commit hash or
`N/A` with the reason no commit was needed, and the HEAD against which
checks ran. Include changed supporting files, commands and results,
log paths or relevant output, intentionally retained resources,
limitations and deferred checks. Record manager review in the
coordination record. Append correction commits and later validation
results instead of erasing the original evidence.

For a step with no changes, including an inapplicable Step 4, write
the explanation with `N/A` for the commit and a reason. An inapplicable
Step 4 counts as processed for the phase transition. Do not fabricate
a commit hash or make an empty commit.

Create each explanation file in docker/basics/. The format of an
explanation filename is:
`<script-basename>-<stepno>-improvements.md`
Use the full script filename without the .sh extension, and a two-digit
step number. For example, changes to 17-docker-inspect.sh in Step 1 use
17-docker-inspect-01-improvements.md. Changes to 18-docker-save-load.sh
in Step 3 use 18-docker-save-load-03-improvements.md. This keeps the
explanations unique even when two scripts have the same number.

### Committing

Before starting the first sub-agent, the manager asks the user once
for the exact Co-Authored line or lines to use, in the format of
commit.template. Obtain the attribution for every model and effort
level planned for the workflow in that one startup question. Store
the answer in the coordination record and pass the appropriate line
to each sub-agent. Use those lines throughout; do not infer new
attribution or ask again per step or sub-agent. Keep subsequent
sub-agent model and effort choices consistent with the supplied
attribution. On recovery, reuse the recorded answer.

Make every commit in this order:

1. Stage only the files of this step, by explicit path:
   `git add -- <file> ...`. Never use `git add -A`, `git add .` or
   `git add --force`.
   First confirm the index is empty. After staging, inspect the entire
   `git diff --cached` and `git diff --cached --name-status`, and run
   `git diff --cached --check`. Every staged change must belong to
   this task and step and obey the scope restrictions. Explicit-path
   staging does not exclude unrelated changes already in the index
   or unrelated edits within the same file. Resolve ownership before
   staging; stop if an unrelated staged change appears.
2. Write a new commit message file following prompts/commit.md, even
   though no one has asked you for one. prefix.txt is empty, so the
   file is msg at the top of the repository, not in docker/basics.
3. Use the Co-Authored line given in your prompt, in the format of
   commit.template. Do not add any other attribution lines.
4. Commit with `git commit --file=<top of the repository>/msg`.
5. Run `git log -1` and check that the first line has the step label
   and that the message ends with the Co-Authored line.
   Verify the committed paths and diff against the reviewed staged
   changes, and confirm the index is empty afterward. Compare the
   remaining worktree changes with the recorded baseline.

## Sub-agents

The coordinating agent is the manager. An agent explicitly assigned
a sub-agent task follows the worker rules below instead. The
manager starts sub-agents, reviews their work and reports to the
user. Do not implement or correct a tutorial step yourself. Read the
tutorials, Dockerfiles, helpers, tests and evidence needed for a
substantive review. Maintaining the coordination record and making
review decisions are manager responsibilities.

You must be able to start sub-agents. If your tool has no way to start
one, report that blocker and stop. If starting one fails, retry once
as described under "Checking a sub-agent's work". If that also fails,
report what you tried and the error. Do not do the work yourself in
its place.

### What the manager does

- At the start, follow the resume rules in "Order of work" to find
  where the work stands. If those rules call for writing a missing
  explanation file or finishing an interrupted step, start a
  sub-agent for that task and tell it to resume. Do not do it
  yourself.
- Resolve and record commit attribution once at startup, as described
  in "Committing", and pass it to every sub-agent.
- In Phase 1, start one sub-agent for Steps 1 and 2 for all the
  scripts.
- In Phase 2, start one sub-agent per script for Steps 3 and 4.
- In Phase 3, start one sub-agent to make the coverage map for the
  whole series. Give it the path of a temporary working map. Review
  the actual coverage, proposed additions, consolidations and
  deferrals against the audience, lesson boundaries and scope.
  Request corrections from the sub-agent where needed, then accept
  the map yourself. Preserve the accepted map, its revision and your
  rationale in the uncommitted coordination record. Report the
  decisions as progress without waiting for user approval. Start one
  sub-agent per script for Step 5 and give it the accepted map and
  its assigned changes. If the working map is lost, recover it from
  the record; if the evidence is insufficient, have a sub-agent
  reconstruct it and review it again yourself.
- Carry deferred regression checks between tasks. Assign them as
  soon as their callers can be tested, and finish with a sub-agent
  assigned the full-series checks in "Final acceptance". Route any
  defects back to an implementation sub-agent, review the correction
  and repeat the affected validation before acceptance.
- Run one sub-agent at a time. Wait for it to finish and check its
  work before you start the next one. Never run two sub-agents at
  once. They share one Docker daemon, one git index, the host
  firewall, fixed ports and the shared helpers, and would conflict.
- Run every sub-agent in this working tree and on this branch. Do not
  give it a separate worktree or branch.

### What to put in a sub-agent's prompt

A sub-agent cannot see your conversation. Give it everything it needs:

```
You are working in docker/basics of this repository. Your task is:
<Phase 1: Steps 1 and 2 for all the scripts |
 Steps 3 and 4 for <script> |
 the Phase 3 coverage map, written to <path> |
 Step 5 for <script>, using the coverage map in <path> and these
 manager-accepted changes: <changes> |
 corrections for <script, step, review findings and allowed paths> |
 final acceptance checks for the whole series |
 record verified completion in TODO.txt>

Before you change anything, read prompts/agent-session.md,
prompts/projects/docker-basics-update.md and prompts/commit.md and
follow them. Read "Order of work", "Sub-agents", and the Step sections
for your task.

Co-Authored line: <line from the user>

Coordination record: docker/basics/docker-basics-update-run-improvements.md
Starting branch and HEAD: <branch and hash>
Pre-existing work to preserve: <paths and relevant baseline details, or none>
Deferred checks assigned to this task: <checks and why they are due, or none>

Earlier work that affects your task:
<commits and shared-file changes from earlier reports, for example a
change to docker-build-flask-test-utilities.sh made for
13-docker-build-flask.sh, or "none">

When you finish, or if you must stop, reply with the report described
in "Sub-agents: The sub-agent's report".
```

### Rules for sub-agents

- Do only the task named in your prompt. Do not start work on another
  script or step. Checking affected callers is permitted; changing
  them requires an explicit correction assignment from the manager.
  Follow the deferral rules when those callers are not yet runnable.
- Do not start sub-agents of your own.
- Follow the resume rules in "Order of work" for your task. An
  earlier sub-agent may have stopped part way through.
- Commit each step and write its explanation file as described in
  "Order of work". The coverage-map sub-agent makes no commits and
  writes no explanation files; it writes only the map. The final
  validation sub-agent writes the acceptance explanation and makes
  no commits. A separate completion assignment changes and commits
  only TODO.txt and records its evidence in that explanation.
- Make routine implementation choices within the task and document
  them. If manager review or a scope decision is needed, report it
  to the manager. If a permission limit or unavailable prerequisite
  prevents the task, stop before the affected action and report the
  exact blocker. Do not ask the user directly.
- Keep long command output out of your report. Put the details in the
  explanation file.

### The sub-agent's report

Reply concisely using this report. Group repeated information, but
do not omit required evidence merely to fit a line limit:

```
Task: <task from the prompt>
Steps implemented: <script, step, commit hash or N/A and reason, first line>
Validation: <passed checks, implemented with checks pending, or not applicable>
Explanation files written: <file names>
Coverage map: <path, for the coverage-map task only>
Proposed changes: <for the coverage-map task only: additions,
  consolidations and deferrals, naming each script and rationale;
  include scripts for which no change is proposed>
Shared files changed: <file, and the other scripts that use it>
Checks run: <commands, results, tested HEAD and log paths>
Deferred checks: <caller, check, reason, and when it becomes runnable>
Checks skipped: <check, reason, and whether it is essential>
Manager decisions needed: <scope or review decisions, or "none">
Permission or external blockers: <policy or failed prerequisite, or "none">
Uncommitted changes: <files, and why they were left, or "none">
```

### Checking a sub-agent's work

After each sub-agent finishes:

1. Verify the task commits, labels, attribution, complete diffs and
   allowed paths. For an `N/A` commit, verify the no-change or
   not-applicable decision instead of requiring an empty commit.
2. Read the changed files and relevant callers. Check teaching
   objectives, explanations, factual support, licensing, error paths,
   ownership, cleanup and the requirements for that particular step.
   Steps 1 and 2 intentionally have narrower checks than Step 3.
3. Read the explanation and inspect the test evidence. Confirm which
   revision ran, that assertions prove the lesson's claims, and that
   failures or skips were not hidden. Rerun a relevant check when
   the evidence is missing, inconsistent or invalidated by changes.
4. Compare `git status`, the index and changed paths against the
   baseline and assignment. Confirm that unrelated user work is
   preserved and all remaining task edits are explained. Ignored
   explanation files and the coordination record remain uncommitted.
5. Record shared-file changes, every affected caller, deferred checks
   and the review outcome in the coordination record. Include them
   in later assignments that use those files. Review a coverage map
   against the actual lessons, not just the report's summary.

Return ordinary defects to a sub-agent with concrete findings and an
explicit correction scope. Have it fix, retest and commit the
correction with the original step label and append the evidence to
that step's explanation. Review the result before advancing. Resolve
routine design and curriculum questions yourself.

For a tool failure, try a fresh sub-agent with the same task and the
recovery evidence. If the required tool remains unavailable, report
the external blocker and incomplete work; do not implement the task
yourself or declare it finished. Ask the user for permission only
when a necessary action exceeds the authority described above.

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
# keeps-image: postgres-test
# firewall-port: 9000
# time-limit: 1800
```

- `scenarios` lists the scenarios the driver supports. normal is
  required.
- `keeps-image` names an image the tutorial may leave behind: an image
  it deliberately keeps for a later tutorial, or a base image that it
  pulls. A name without a tag means name:latest. One line per image.
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

- For a conflict or reuse scenario, save the relevant resource id,
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

There are initially no tutorial drivers in tests/. Create them as
their tutorials reach Steps 3 and 4. Do not require a driver for a
later, unrepaired caller before its turn in the sequence.

When changing a shared helper or build context:

1. Find every caller, including 00-*.sh through 08-*.sh and the test
   harness. Review compatibility and run focused checks of the
   changed behavior and failure paths immediately. Use temporary
   checks if needed; do not expand the assigned implementation scope.
2. Run existing runnable caller tests now. If a later caller lacks
   its driver or still has unfinished examples, record the exact
   caller, shared change, outstanding regression and the point when
   it becomes runnable in the explanation and coordination record.
   This is validation pending, not a pass and not a reason to stop
   the workflow for a user decision.
3. The manager assigns deferred checks when the caller's driver and
   repair are complete. A sub-agent may test other callers but may
   not modify their tutorials without a correction assignment.
4. For affected earlier tutorials, run any existing tests. If none
   exist, the manager assigns a supplemental driver in tests/ or a
   focused temporary check that covers the changed shared behavior.
   Do not modify 00-*.sh through 08-*.sh or execute an installation
   tutorial to test a helper. Record the scope of that evidence.
5. Run the final regression pass after the last implementation
   change. Every deferred essential check must then pass, or final
   acceptance remains blocked.

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
  and credentials. State which resources are removed and which are kept.
  A successful run must be repeatable without unexplained leftovers.
- Before building or tagging, check for conflicting image names. Before
  creating named volumes or networks, check that they do not already
  exist. Container creation must fail safely on a name conflict. Stop with
  a clear message and suggested inspection/recovery commands; never
  silently remove, reuse as empty, or overwrite an existing resource.
  An image intentionally reused by a lesson must be left in place.
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
- Leave existing base images, user data and other workloads alone. Avoid
  daemon-wide prune commands, deleting every container based on an image,
  or forcibly replacing names to make a rerun succeed. Describe retained
  base images, downloaded artifacts and BuildKit cache explicitly.
- Explain recovery from partial runs, including name conflicts, containers
  surviving a killed Docker client, and SIGKILL, which cannot run cleanup.
  Provide commands to inspect leftovers before the reader removes them.

### Images intentionally retained for later lessons

Script 15 retains its successfully built and verified PostgreSQL
image for later lessons. Other tutorials remove their demonstration
images unless their explanation identifies a specific later use.
Retaining a base image or documented build cache is a separate matter.

- Make the normal path repeatable when a retained image is present.
  Record provenance on images built by these examples, including a
  fingerprint of the relevant build inputs and arguments. Reuse an
  existing retained image only after its provenance, architecture
  and required runtime behavior match the lesson's expectations.
  A matching tag or version string alone is not enough.
- Leave a validated reused image, its tags and id unchanged. If an
  occupied tag does not identify a compatible tutorial image, preserve
  it and build with an unused demonstration tag. Print and pass the
  actual selected tag to helpers and callers; do not overwrite an
  unrelated image to preserve a preferred name.
- Register cleanup immediately for a newly built image. Cancel that
  cleanup for deliberate retention only after the image passes its
  checks and the lesson reaches its documented successful handoff.
  A reused image is never owned by the current run's cleanup.
- Drivers must cover both an initially absent demonstration image
  and reuse of a compatible retained image, comparing the reused
  image's id and tags before and after. Include the incompatible-tag
  preservation case where it applies. Use normal, documented user
  configuration for selecting a demonstration tag if needed; do not
  add a test mode. A driver may run the tutorial twice using distinct
  terminal names to test creation followed by reuse. When it requests
  an initially absent, test-owned tag, it may remove that newly built
  fixture after asserting the tutorial's retention and reuse behavior.
  Register that cleanup by the verified image identity. Never remove
  a retained image that existed before the driver started.
- Declare each intentionally retained image that remains after driver
  teardown in `keeps-image`, and record its actual tag and id in the
  explanation. The metadata accepts exact names, not patterns: use
  declared fixed tags or remove test-owned variable tags after their
  retention checks. The repeated normal scenario must succeed with
  retention enabled. A `keeps-image` declaration permits retention;
  it does not waive reuse checks or preservation of existing resources.

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
  automatic entrypoint initialization, and say whether a built image is
  deliberately retained for a later tutorial. Fix the shared helper's
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
  run, their results, resources intentionally retained, and any limitations
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
  builders and caches. Declare any newly pulled base or BuildKit image
  intentionally kept by the test. Verify cleanup, repeatability and
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
  because it can create some resources before failing. Track demo-built
  images separately and keep pre-existing images.
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
changes, then create its Step 4 explanation file using the filename rule
above, for example `10-docker-logs-04-improvements.md`. Describe what was
completed and how it was verified. Never commit the explanation file.

## Step 5: Review topic coverage and add missing lessons

After the repairs and baseline completion, use your judgment to identify
what else each tutorial should teach. Propose the additions in the
coverage map, which the manager reviews and accepts before any are
made, as described in "Sub-agents". Then implement the accepted changes; do
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
  undocumented resources left running by another tutorial. Reuse source
  fixtures and helpers where appropriate, but create and clean up its own
  runtime resources. Avoid circular dependencies between lessons.
- Re-read the affected scripts together after editing to catch duplicated
  explanations, contradictory advice, broken references and gaps caused
  by consolidation. Run the relevant Step 3 checks for new or changed
  examples and recheck any callers affected by shared-file changes.
- For each script, commit its Step 5 changes separately from earlier steps,
  then create its explanation file, for example
  `25-docker-compose-networking-05-improvements.md`. State the topics added,
  why they belong here, which other lessons cover related concepts, any
  duplication removed, and validation results. If no addition is justified,
  explain the coverage decision without making cosmetic changes or an
  empty commit merely to satisfy this step. Never commit explanation files.

## Final acceptance

The manager assigns a sub-agent to validate the finished series after
Phase 3. This is a validation task, not authority to make unreviewed
implementation changes. The manager sends defects to an implementation
sub-agent with an explicit script, original step and correction scope.
Corrections use that step's commit label and append evidence to its
explanation. Recheck the affected tutorials and every caller or
assertion invalidated by a correction before accepting the result.

The final validation sub-agent writes
docker/basics/docker-basics-update-final-improvements.md. Never commit
this file. Include a matrix with one row for each of the 19 target
scripts, including both scripts numbered 10 and both numbered 18.
Record implementation commits, final tested revision, driver,
applicable scenarios, results, evidence paths, retained resources and
outstanding limitations. Include affected earlier callers separately.

Final acceptance requires all of the following:

- All five steps are accounted for for every target script, with
  truthful no-change or not-applicable decisions where needed. The
  manager has reviewed each implementation, correction and coverage
  decision. No placeholder or required incomplete example remains.
- Run `bash -n` on all changed shell files. Run ShellCheck if
  available, handle applicable findings and document narrow
  suppressions. Apply the referenced Python or Javascript validation
  policies to any source created or changed in those languages.
- Run `tests/run-tutorial-test.sh <script> all` sequentially for every
  target script in its final implemented form. Every required normal
  run and applicable interrupt, continue and conflict scenario must
  pass, including the runner's repeated normal run. Include the
  supplemental preservation, retained-image reuse and fixture checks.
  A scenario omitted as inapplicable needs a recorded reason.
- Close every deferred essential check, including shared-file
  regressions for earlier tutorials. All evidence must apply to the
  final source state. A changed dependency invalidates checks that
  relied on its previous behavior, even if its caller did not change.
- Review the finished series together for duplicated explanations,
  contradictions, broken paths or references, undocumented retained
  resources, circular dependencies and coverage gaps. Verify that
  script 20 teaches static hosting and leaves the future Compose
  proxy-and-web-service lesson outside this task.
- Verify cleanup and preservation using both the runner and the
  supplemental assertions. Audit the final repository diff against
  the initial baseline: only authorized paths and task-owned changes
  may be committed, unrelated work must remain intact, the index
  must be empty, and no explanation or coordination file may appear
  in a task commit. Account for untracked files and runtime leftovers.

Distinguish implementation completion from verified completion. An
essential skipped, failed, missing or deferred check blocks verified
completion. Optional checks, such as a foreign-platform runtime test
without emulation, may remain explicitly unverified when the baseline
permits it. Document other distributions, architectures and daemon
modes as untested; do not make their absence a reason to claim they
were verified or to reduce support.

If essential verification is blocked, continue any independent work
within scope, then report what is implemented, the exact blocker,
checks attempted and the work still required. Keep issue249 active
and do not mark it done. Request additional user permission only when
a necessary next action is restricted by the session policies.

Only after the manager accepts the full validation evidence, assign
a sub-agent to mark issue249-docker-basics done in TODO.txt following
prompts/todo.md. Preserve its active asterisk as that policy specifies
and leave other issues unchanged. Commit that change separately with
the subject prefix `issue249-docker-basics: Step 5:` and the supplied
attribution, using the normal commit procedure. Record the final
commit in the acceptance explanation; a TODO-only completion commit
does not require repeating unchanged tutorial tests.

The manager's final report names the completed scripts and commit
range, summarizes validation results and intentional retained
resources, links the acceptance explanation and reports any optional
untested cases. Claim verified completion only when these acceptance
criteria have been met.
