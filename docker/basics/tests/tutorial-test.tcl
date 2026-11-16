# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# tutorial-test.tcl: Expect procedures shared by the tutorial test
# drivers
#
# Copyright (C) 2026 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

# A driver sources this file, then uses these procedures to run its
# tutorial and answer it the way a reader would. run-tutorial-test.sh
# runs the driver and passes it these environment variables:
#
#   TUTORIAL_TEST_TUTORIAL  absolute path of the tutorial script
#   TUTORIAL_TEST_SCENARIO  the scenario to run, for example normal
#   TUTORIAL_TEST_LOG       file that receives everything the
#                           terminals print
#   TUTORIAL_TEST_VERBOSE   1 to also show that output on stdout
#
# Procedures for drivers:
#
#   scenario
#     Return the name of the scenario to run.
#   start_tutorial
#     Start the tutorial in a new terminal named tutorial.
#   start_terminal name command ?argument ...?
#     Start another command in a new terminal, for an example that
#     asks the reader to use a second terminal.
#   wait_for ?-in name? ?-time seconds? text
#     Wait until the terminal prints text, exactly as given.
#   wait_for_regexp ?-in name? ?-time seconds? regexp
#     Wait until the terminal prints output that matches regexp.
#     Return a list of the whole match and each captured group.
#   answer_pause ?-in name? ?-time seconds? prompt
#     Wait for the prompt of a read -r -p pause, then press ENTER.
#   type_line ?-in name? text
#     Type a line of text and press ENTER.
#   press_ctrl_c ?-in name?
#     Press Ctrl-C.
#   finish_tutorial ?-time seconds? status ?status ...?
#     Wait for the tutorial to exit, and fail unless its exit status
#     is one of the given statuses.
#   finish_terminal name ?-time seconds? status ?status ...?
#     The same for a terminal started with start_terminal.
#   host_command command ?argument ...?
#     Run a command on the host, outside any terminal, and return its
#     standard output. Fail if it fails, and show its error output.
#   host_command_succeeds command ?argument ...?
#     Run a command on the host and return 1 if it succeeds, 0 if not.
#   cleanup_on_host command ?argument ...?
#     Save a host command that undoes something the driver did, for
#     example remove a container it created for the conflict
#     scenario. The saved commands run, newest first, when the driver
#     exits, after the terminals have been stopped.
#   cancel_cleanup_on_host
#     Forget the newest saved command, once the driver has undone the
#     step itself.
#   fail message
#     Stop every terminal that is still running, report the failure
#     and exit with status 1.
#   skip message
#     Stop every terminal that is still running, report why the
#     scenario cannot run here and exit with status 77.
#
# A driver that reaches its end without calling fail exits with status
# 0, which tells the runner that the scenario passed.
#
# Every wait has a time limit, 120 seconds unless -time gives another.
# A wait fails at once if the terminal ends first, or if sudo asks for
# a password, because no one is there to type it.
#
# Exit statuses: an exit status is a number from 0 to 255. A program
# killed by a signal has no exit status; the procedures report it as
# 128 plus the number of the signal, as bash does. So a tutorial that
# Ctrl-C stops reports 130, whether it exits with 130 itself or is
# killed by SIGINT.

if {[info exists tutorial_test_sourced]} {
  return
}
set tutorial_test_sourced 1

foreach tutorial_test_name {
  TUTORIAL_TEST_TUTORIAL TUTORIAL_TEST_SCENARIO TUTORIAL_TEST_LOG
} {
  if {![info exists env($tutorial_test_name)] ||
      $env($tutorial_test_name) eq ""} {
    puts stderr "ERROR: $tutorial_test_name is not set. Run the driver\
      with run-tutorial-test.sh."
    exit 2
  }
}
unset tutorial_test_name

# Settings used by the procedures below. They start with tt_, so that
# they do not clash with the variables of a driver.
set tt_tutorial_path $env(TUTORIAL_TEST_TUTORIAL)
set tt_scenario $env(TUTORIAL_TEST_SCENARIO)
set tt_default_time 120
# tt_terminals maps the name of each terminal to its spawn id, and
# tt_finished holds the names of the terminals that have ended.
array set tt_terminals {}
array set tt_finished {}
# tt_host_cleanups holds the commands saved by cleanup_on_host, oldest
# first.
set tt_host_cleanups {}

# Record the output of every terminal in the log. log_user 0 keeps it
# off stdout, unless the runner asks for verbose output. -a records it
# in the log even when log_user 0 keeps it off stdout.
log_file -a -noappend $env(TUTORIAL_TEST_LOG)
if {[info exists env(TUTORIAL_TEST_VERBOSE)] &&
    $env(TUTORIAL_TEST_VERBOSE) eq "1"} {
  log_user 1
} else {
  log_user 0
}

# Each terminal is 50 rows by 160 columns, so that commands that fit
# their output to the terminal, like docker container stats, print
# the same way every time. match_max is the number of characters
# that a wait keeps while it looks for its text. Builds print a lot,
# and the default of 2000 could drop the start of a long message.
set stty_init {rows 50 columns 160}
match_max -d 100000

# Ctrl-C on the terminal of the runner, or the runner's time limit,
# stops the driver. Stop the tutorial first, so that its cleanup runs.
trap {fail "the test was interrupted"} {SIGINT SIGTERM}

# If the driver ends in any other way, for example because of an error
# in the driver itself, stop the terminals that are still running,
# then run the commands saved by cleanup_on_host.
exit -onexit tt_stop_all

# tt_report: print a message on stderr and add it to the log.
proc tt_report {message} {
  send_log "\n$message\n"
  puts stderr $message
}

# tt_options: separate the options of a procedure from its other
# arguments.
#
# Usage: tt_options defaults arguments
#   defaults:  a dict of the accepted options and their defaults,
#              for example {-in tutorial -time ""}
#   arguments: the arguments the procedure was given
#
# Returns a list of two elements: a dict of the options, and a list
# of the remaining arguments. Only the names in defaults are taken as
# options, so text that starts with - is not mistaken for one. -- ends
# the options.
proc tt_options {defaults arguments} {
  set options $defaults
  while {[llength $arguments] > 0} {
    set first [lindex $arguments 0]
    if {$first eq "--"} {
      set arguments [lrange $arguments 1 end]
      break
    }
    if {![dict exists $defaults $first]} {
      break
    }
    if {[llength $arguments] < 2} {
      fail "the option $first needs a value"
    }
    dict set options $first [lindex $arguments 1]
    set arguments [lrange $arguments 2 end]
  }
  return [list $options $arguments]
}

# tt_spawn_id: return the spawn id of a terminal. Fail if there is no
# such terminal, or if it has already ended.
proc tt_spawn_id {name} {
  global tt_terminals tt_finished
  if {![info exists tt_terminals($name)]} {
    fail "there is no terminal named $name"
  }
  if {[info exists tt_finished($name)]} {
    fail "the terminal $name has already ended"
  }
  return $tt_terminals($name)
}

# tt_time: return the time limit for a wait, from the -time option or
# the default.
proc tt_time {options} {
  global tt_default_time
  set seconds [dict get $options -time]
  if {$seconds eq ""} {
    return $tt_default_time
  }
  if {![string is integer -strict $seconds] || $seconds < 1} {
    fail "-time must be a whole number of seconds, not $seconds"
  }
  return $seconds
}

# tt_wait: wait until a terminal prints output that matches a
# pattern.
#
# Usage: tt_wait name seconds kind pattern
#   name:    the name of the terminal
#   seconds: the time limit
#   kind:    -ex for exact text, -re for a regular expression
#   pattern: the text or the regular expression
#
# Returns a list of the whole match and each captured group. Fails on
# the time limit, if the terminal ends, or if sudo asks for a password.
proc tt_wait {name seconds kind pattern} {
  set id [tt_spawn_id $name]
  set timeout $seconds
  set outcome timeout
  set match {}
  # The sudo prompt comes first, so that it is noticed even if the
  # pattern would also match. The text is in double quotes, so the
  # backslashes keep [sudo] from being run as a command.
  expect -i $id \
    -ex "\[sudo\] password" {
      set outcome sudo
    } \
    $kind $pattern {
      set outcome matched
      for {set i 0} {[info exists expect_out($i,string)]} {incr i} {
        lappend match $expect_out($i,string)
      }
    } \
    timeout {
      set outcome timeout
    } \
    eof {
      set outcome eof
    }
  switch -- $outcome {
    matched {
      return $match
    }
    sudo {
      fail "sudo asked for a password in the terminal $name while\
        waiting for: $pattern"
    }
    eof {
      global tt_finished
      set tt_finished($name) 1
      catch {wait -i $id}
      fail "the terminal $name ended while waiting for: $pattern"
    }
    default {
      fail "waited $seconds seconds in the terminal $name for:\
        $pattern"
    }
  }
}

# tt_exit_status: wait for the process of a terminal that has ended,
# and return its exit status, or 128 plus the number of the signal
# that killed it.
proc tt_exit_status {name id} {
  set result [wait -i $id]
  # wait returns: pid spawn_id os_error value, followed by CHILDKILLED,
  # the name of the signal and a description when a signal killed the
  # process. os_error is -1 when the operating system reported an error,
  # and value is then the error number.
  if {[lindex $result 2] == -1} {
    fail "could not wait for the terminal $name: error\
      [lindex $result 3]"
  }
  if {[lindex $result 4] eq "CHILDKILLED"} {
    set numbers {
      SIGHUP 1 SIGINT 2 SIGQUIT 3 SIGABRT 6 SIGKILL 9 SIGSEGV 11
      SIGPIPE 13 SIGALRM 14 SIGTERM 15
    }
    set signal [lindex $result 5]
    if {![dict exists $numbers $signal]} {
      fail "the terminal $name was killed by $signal"
    }
    return [expr {128 + [dict get $numbers $signal]}]
  }
  return [lindex $result 3]
}

# tt_stop_all: stop every terminal that has not ended yet. It presses
# Ctrl-C and waits up to 30 seconds for the terminal to end, twice,
# because the first Ctrl-C may only reach a program the tutorial
# runs, such as a shell in a container. Then it closes the terminal,
# which sends SIGHUP to whatever is left. A tutorial normally runs its
# cleanup on Ctrl-C. Anything it leaves behind shows up in the
# runner's check of the resources.
#
# Then it runs the commands saved by cleanup_on_host, newest first,
# and reports any that fail.
proc tt_stop_all {} {
  global tt_terminals tt_finished tt_host_cleanups
  foreach name [array names tt_terminals] {
    if {[info exists tt_finished($name)]} {
      continue
    }
    set tt_finished($name) 1
    set id $tt_terminals($name)
    set timeout 30
    set ended 0
    for {set attempt 0} {$attempt < 2 && !$ended} {incr attempt} {
      catch {send -i $id "\003"}
      catch {
        expect -i $id eof {
          set ended 1
        }
      }
    }
    catch {close -i $id}
    catch {wait -i $id}
    if {!$ended} {
      tt_report "NOTE: the terminal $name did not end after two\
        Ctrl-C; it was closed."
    }
  }
  while {[llength $tt_host_cleanups] > 0} {
    set command [lindex $tt_host_cleanups end]
    set tt_host_cleanups [lrange $tt_host_cleanups 0 end-1]
    send_log "\nCleaning up on the host: [join $command { }]\n"
    if {[catch {exec -ignorestderr -- {*}$command 2>@1} output]} {
      tt_report "ERROR: host cleanup failed: [join $command { }]\n$output"
    }
  }
}

proc scenario {} {
  global tt_scenario
  return $tt_scenario
}

proc start_tutorial {} {
  global tt_tutorial_path
  # Run the tutorial with bash, as its first line asks, so that the
  # test does not depend on the file being executable.
  start_terminal tutorial bash -- $tt_tutorial_path
}

proc start_terminal {name args} {
  global tt_terminals
  if {[info exists tt_terminals($name)]} {
    fail "a terminal named $name has already been started"
  }
  if {[llength $args] == 0} {
    fail "start_terminal $name needs a command"
  }
  if {[catch {spawn -noecho {*}$args} error]} {
    fail "could not start the terminal $name: $error"
  }
  # spawn sets spawn_id to the id of the new terminal.
  set tt_terminals($name) $spawn_id
}

proc wait_for {args} {
  lassign [tt_options {-in tutorial -time ""} $args] options rest
  if {[llength $rest] != 1} {
    fail "usage: wait_for ?-in name? ?-time seconds? text"
  }
  return [tt_wait [dict get $options -in] [tt_time $options] -ex \
    [lindex $rest 0]]
}

proc wait_for_regexp {args} {
  lassign [tt_options {-in tutorial -time ""} $args] options rest
  if {[llength $rest] != 1} {
    fail "usage: wait_for_regexp ?-in name? ?-time seconds? regexp"
  }
  return [tt_wait [dict get $options -in] [tt_time $options] -re \
    [lindex $rest 0]]
}

proc answer_pause {args} {
  lassign [tt_options {-in tutorial -time ""} $args] options rest
  if {[llength $rest] != 1} {
    fail "usage: answer_pause ?-in name? ?-time seconds? prompt"
  }
  tt_wait [dict get $options -in] [tt_time $options] -ex \
    [lindex $rest 0]
  send -i [tt_spawn_id [dict get $options -in]] "\r"
}

proc type_line {args} {
  lassign [tt_options {-in tutorial} $args] options rest
  if {[llength $rest] != 1} {
    fail "usage: type_line ?-in name? text"
  }
  send -i [tt_spawn_id [dict get $options -in]] "[lindex $rest 0]\r"
}

proc press_ctrl_c {args} {
  lassign [tt_options {-in tutorial} $args] options rest
  if {[llength $rest] != 0} {
    fail "usage: press_ctrl_c ?-in name?"
  }
  send -i [tt_spawn_id [dict get $options -in]] "\003"
}

proc finish_tutorial {args} {
  finish_terminal tutorial {*}$args
}

proc finish_terminal {name args} {
  global tt_finished
  lassign [tt_options {-time ""} $args] options statuses
  if {[llength $statuses] == 0} {
    fail "usage: finish_terminal name ?-time seconds? status\
      ?status ...?"
  }
  set id [tt_spawn_id $name]
  set timeout [tt_time $options]
  set ended 0
  expect -i $id \
    -ex "\[sudo\] password" {
      fail "sudo asked for a password in the terminal $name"
    } \
    eof {
      set ended 1
    }
  if {!$ended} {
    fail "the terminal $name did not end within $timeout seconds"
  }
  set tt_finished($name) 1
  set status [tt_exit_status $name $id]
  if {[lsearch -exact $statuses $status] < 0} {
    fail "the terminal $name exited with status $status, expected\
      [join $statuses { or }]"
  }
  send_log "\nThe terminal $name exited with status $status, as\
    expected.\n"
}

proc host_command {args} {
  if {[llength $args] == 0} {
    fail "usage: host_command command ?argument ...?"
  }
  # The error output goes to a file of its own, so that a warning,
  # such as Docker's warning about the platform of an image, does not
  # become part of the result, for example of a container id.
  # -ignorestderr stops exec from treating error output as a failure;
  # only a non-zero exit status is one.
  set error_channel [file tempfile error_path]
  close $error_channel
  set failed [catch {exec -ignorestderr -- {*}$args 2> $error_path} \
    output]
  set error_file [open $error_path]
  set errors [read $error_file]
  close $error_file
  file delete $error_path
  if {$failed} {
    fail "host command failed: [join $args { }]\n$output\n$errors"
  }
  if {$errors ne ""} {
    send_log "\nError output of [join $args { }]:\n$errors\n"
  }
  return $output
}

proc cleanup_on_host {args} {
  global tt_host_cleanups
  if {[llength $args] == 0} {
    fail "usage: cleanup_on_host command ?argument ...?"
  }
  lappend tt_host_cleanups $args
}

proc cancel_cleanup_on_host {} {
  global tt_host_cleanups
  if {[llength $tt_host_cleanups] == 0} {
    fail "cancel_cleanup_on_host: there is no saved command"
  }
  set tt_host_cleanups [lrange $tt_host_cleanups 0 end-1]
}

proc host_command_succeeds {args} {
  if {[llength $args] == 0} {
    fail "usage: host_command_succeeds command ?argument ...?"
  }
  if {[catch {exec -ignorestderr -- {*}$args 2>@1}]} {
    return 0
  }
  return 1
}

proc fail {message} {
  tt_report "FAIL: $message"
  tt_stop_all
  exit 1
}

proc skip {message} {
  tt_report "SKIP: $message"
  tt_stop_all
  exit 77
}
