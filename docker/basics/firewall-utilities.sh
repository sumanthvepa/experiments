#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# firewall-utilities.sh: Functions that work with the firewall that
# is present on the machine
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see
# <https://www.gnu.org/licenses/>.
# -------------------------------------------------------------------

# This file is intended to be sourced by other scripts. It defines
# these functions. Nothing runs until they are called.
#
#   open_tcp_port port
#     Open a TCP port in whichever firewall is active on this machine.
#   close_tcp_port port
#     Close a TCP port that open_tcp_port opened.
#   query_tcp_port port
#     Print yes if a TCP port is already open, no if it is not, and
#     partial if it is open in only some of the firewall chains.
#
# The other functions in this file are helpers for these three.
#
# The functions are meant for a script that is NOT run with sudo. They
# call sudo themselves, for the commands that need root, and sudo asks
# for the password of the user at that point.

# root_has_command: succeeds if root can run the command $1. A normal
# user cannot find out with command -v. On Debian, for example, the
# firewall commands are in /usr/sbin, which is only in the PATH of
# root. So the check is run with sudo.
root_has_command() {
  sudo bash -c 'command -v "$1"' _ "$1" > /dev/null
}

# tcp_port_number: check a port number and print it in decimal. A
# number of up to 5 digits cannot overflow. 10# makes bash read it as
# a decimal number, even if it starts with 0.
#
# Usage: port=$(tcp_port_number caller port)
#   caller: the name of the calling function, for the error message
#   port:   the port number to check
#
# Prints an error message on stderr and returns 1 if the port number
# is not from 1 to 65535.
tcp_port_number() {
  local caller=$1 port=${2:-}

  if [[ ! $port =~ ^[0-9]{1,5}$ ]] ||
    ((10#$port < 1 || 10#$port > 65535)); then
    echo "ERROR: $caller: '$port' is not a port number from 1" \
      "to 65535" >&2
    return 1
  fi
  echo "$((10#$port))"
}

# active_firewall_manager: print the name of the program that manages
# the firewall on this machine: firewalld if the service is running,
# ufw if it is installed and active, and otherwise rules, which means
# that any rules are in nftables or iptables themselves.
#
# Usage: manager=$(active_firewall_manager)
#
# Returns 1 if the state of ufw cannot be read.
active_firewall_manager() {
  local ufw_status

  if systemctl is-active --quiet firewalld 2> /dev/null; then
    echo firewalld
    return 0
  fi

  if root_has_command ufw; then
    # LC_ALL=C, because the message is translated in other languages
    ufw_status=$(sudo env LC_ALL=C ufw status) || return 1
    if [[ $ufw_status == 'Status: active'* ]]; then
      echo ufw
      return 0
    fi
  fi

  echo rules
}

# nftables_input_chains: print the nftables chains that filter
# incoming traffic, one on each line, as: family table chain
#
# The chains named INPUT in the filter, mangle and security tables of
# the ip and ip6 families are left out. They belong to iptables, and
# the iptables functions look after them. Only chains of type filter
# are looked at, because a nat chain does not filter traffic. Only ip,
# ip6 and inet are looked at, because the chains with an input hook
# in the arp and bridge families are not for TCP traffic.
#
# Usage: names=$(nftables_input_chains)
#
# Returns 1 if the chains cannot be listed.
nftables_input_chains() {
  local listing

  listing=$(sudo nft list chains) || return 1
  printf '%s\n' "$listing" | awk '
    $1 == "table" { family = $2; table = $3; next }
    $1 == "chain" { chain = $2; next }
    /type filter hook input/ && family ~ /^(ip|ip6|inet)$/ {
      if (!(chain == "INPUT" && family ~ /^ip6?$/ &&
        table ~ /^(filter|mangle|security)$/))
        print family, table, chain
    }'
}

# nftables_chain_has_open_rule: succeeds if the listing of an nftables
# chain has the rule that open_tcp_port adds. The whole rule must
# match. A longer rule, such as one that only accepts one source
# address, does not open the port for everyone.
#
# Usage: nftables_chain_has_open_rule chain_rules port
#   chain_rules: the output of nft list chain
#   port:        the port number
nftables_chain_has_open_rule() {
  printf '%s\n' "$1" | awk -v port="$2" '
    NF == 4 && $1 == "tcp" && $2 == "dport" && $3 == port &&
      $4 == "accept" { found = 1 }
    END { exit !found }'
}

# iptables_input_rules: print the rules of the INPUT chain of iptables
# or ip6tables. --wait makes the command wait for the lock on the
# rules, if another program (Docker, for example) is holding it.
#
# Usage: rules=$(iptables_input_rules tool)
#   tool: iptables or ip6tables
#
# Returns 0 if it printed the rules, 2 if the tool cannot be used on
# this machine, and 1, with an error message on stderr, if the rules
# cannot be read. The tool cannot be used if it is not installed, if
# ip6tables is on a machine without IPv6 support, or if it exits with
# status 3, which means that the kernel does not support its table.
iptables_input_rules() {
  local tool=$1
  local status=0

  root_has_command "$tool" || return 2
  if [[ $tool == ip6tables && ! -e /proc/net/if_inet6 ]]; then
    return 2
  fi
  sudo "$tool" --wait --list-rules INPUT 2> /dev/null || status=$?
  case $status in
    0)
      return 0
      ;;
    3)
      return 2
      ;;
    *)
      echo "ERROR: could not read the INPUT chain of $tool" \
        "(exit status $status)" >&2
      return 1
      ;;
  esac
}

# iptables_open_rule: check for, add or delete the rule that
# open_tcp_port adds. --insert puts the rule at the start of the
# chain, so that it comes before any rule that drops the packet.
#
# Usage: iptables_open_rule tool action port
#   tool:   iptables or ip6tables
#   action: --check, --insert or --delete
#   port:   the port number
#
# It returns the exit status of the tool. For --check, 0 means that
# the rule exists and 1 means that it does not. Any other status is
# an error.
iptables_open_rule() {
  sudo "$1" --wait "$2" INPUT --protocol tcp --dport "$3" --jump ACCEPT
}

# open_tcp_port_firewalld: open a port with firewalld. Without --zone,
# firewall-cmd uses the default zone, which is the zone of every
# interface that has not been given a zone of its own. The name of
# that zone is not the same everywhere, e.g. it is FedoraServer on
# Fedora Server.
#
# Usage: open_tcp_port_firewalld port
#
# Returns 0 if the port is open, and 1 if it could not be opened.
open_tcp_port_firewalld() {
  local port=$1

  if sudo firewall-cmd --query-port="$port/tcp" > /dev/null; then
    echo "firewalld: port $port/tcp is already open"
    return 0
  fi
  if ! sudo firewall-cmd --add-port="$port/tcp" > /dev/null; then
    echo "ERROR: firewalld could not open port $port/tcp" >&2
    return 1
  fi
  echo "firewalld: opened port $port/tcp"
}

# open_tcp_port_ufw: open a port with ufw. ufw does nothing if the
# rule exists already, so there is no need to check for it first. If
# there is a deny rule for exactly the same port, ufw replaces it.
#
# Usage: open_tcp_port_ufw port
#
# Returns 0 if the port is open, and 1 if it could not be opened.
open_tcp_port_ufw() {
  local port=$1

  if ! sudo ufw allow "$port/tcp" > /dev/null; then
    echo "ERROR: ufw could not open port $port/tcp" >&2
    return 1
  fi
  echo "ufw: port $port/tcp is open"
}

# open_tcp_port_nftables: open a port in the rules of nftables, by
# adding a rule to every chain that filters incoming traffic. Every
# one of them is needed: a packet accepted by one such chain is still
# checked by the others. The rule goes at the start of the chain, so
# that it comes before any rule that drops the packet.
#
# Usage: open_tcp_port_nftables port
#
# Returns 0 if the port is open in at least one chain, 1 if it could
# not be opened, and 2 if there is no chain to open it in.
open_tcp_port_nftables() {
  local port=$1
  local rule="tcp dport $port accept"
  local names entry family table chain chain_rules
  local status=2
  local -a chains

  root_has_command nft || return 2
  names=$(nftables_input_chains) || return 1
  mapfile -t chains < <(printf '%s' "$names")

  for entry in "${chains[@]}"; do
    read -r family table chain <<< "$entry"
    status=0
    if ! chain_rules=$(sudo nft list chain "$family" "$table" "$chain"); then
      echo "ERROR: could not read the nftables chain" \
        "$family $table $chain" >&2
      return 1
    fi
    if nftables_chain_has_open_rule "$chain_rules" "$port"; then
      echo "nftables: port $port/tcp is already open in" \
        "$family $table $chain"
      continue
    fi
    # $rule is not quoted, because each word is an argument of nft
    # shellcheck disable=SC2086
    if ! sudo nft insert rule "$family" "$table" "$chain" $rule; then
      echo "ERROR: nftables could not open port $port/tcp in" \
        "$family $table $chain" >&2
      return 1
    fi
    echo "nftables: opened port $port/tcp in $family $table $chain"
  done

  return "$status"
}

# open_tcp_port_iptables: open a port with iptables and ip6tables, if
# they restrict incoming traffic. They do not if the INPUT chain has
# no rules and its policy is to accept everything. The rule goes at
# the start of the chain, so that it comes before any rule that drops
# the packet.
#
# Usage: open_tcp_port_iptables port
#
# Returns 0 if the port is open in at least one of them, 1 if it could
# not be opened, and 2 if neither of them restricts incoming traffic.
open_tcp_port_iptables() {
  local port=$1
  local tool rules read_status check_status
  local status=2

  for tool in iptables ip6tables; do
    read_status=0
    rules=$(iptables_input_rules "$tool") || read_status=$?
    [[ $read_status -eq 1 ]] && return 1
    [[ $read_status -eq 2 ]] && continue
    [[ $rules == '-P INPUT ACCEPT' ]] && continue

    status=0
    check_status=0
    iptables_open_rule "$tool" --check "$port" 2> /dev/null ||
      check_status=$?
    if [[ $check_status -eq 0 ]]; then
      echo "$tool: port $port/tcp is already open"
      continue
    fi
    if [[ $check_status -ne 1 ]]; then
      echo "ERROR: $tool could not check port $port/tcp" >&2
      return 1
    fi
    if ! iptables_open_rule "$tool" --insert "$port"; then
      echo "ERROR: $tool could not open port $port/tcp" >&2
      return 1
    fi
    echo "$tool: opened port $port/tcp"
  done

  return "$status"
}

# open_tcp_port: open a TCP port in whichever firewall is active on
# this machine. If the port is open already, nothing is changed. It is
# meant to be called by a user who is not root: it calls sudo, which
# asks for the password of the user.
#
# It looks for the firewalls in this order, because firewalld and ufw
# manage the nftables and iptables rules themselves, and those rules
# should not be changed behind their backs:
#   1. firewalld, if the service is running
#   2. ufw, if it is installed and active
#   3. nftables and iptables, if they have rules for incoming traffic
# An installed firewall that is not active is ignored. It is not
# started. If no firewall is active, there is nothing to open, and the
# function says so and succeeds.
#
# Usage: open_tcp_port port
#   port: the number of the port to open, from 1 to 65535
#
# With firewalld, nftables and iptables the port stays open until the
# firewall is reloaded or the machine is restarted. With ufw the port
# stays open until the rule is deleted, even after a restart.
#
# NOTE: A port published by a Docker container does not need this.
# Docker adds its own rules, and they get past all of these firewalls.
#
# NOTE: An existing rule is only checked for being there. The function
# does not work out whether traffic reaches it. That would need jumps,
# sets and connection state to be evaluated. An ACCEPT rule that comes
# after a DROP rule for the same port is reported as open. A rule that
# the function adds itself goes first, so it does not have this problem.
#
# Returns 0 on success. Prints an error message on stderr and returns
# 1 if the port number is not valid, if sudo fails, or if the port
# could not be opened.
open_tcp_port() {
  local port manager
  local nftables_status=0 iptables_status=0

  port=$(tcp_port_number open_tcp_port "${1:-}") || return 1

  # Ask for the password now. If sudo failed later on, a firewall
  # could wrongly look as if it was not present.
  if ! sudo --validate; then
    echo "ERROR: open_tcp_port: sudo failed; port $port/tcp has not" \
      "been opened" >&2
    return 1
  fi

  manager=$(active_firewall_manager) || return 1
  case $manager in
    firewalld)
      open_tcp_port_firewalld "$port"
      return
      ;;
    ufw)
      open_tcp_port_ufw "$port"
      return
      ;;
  esac

  open_tcp_port_nftables "$port" || nftables_status=$?
  [[ $nftables_status -eq 1 ]] && return 1
  open_tcp_port_iptables "$port" || iptables_status=$?
  [[ $iptables_status -eq 1 ]] && return 1

  if [[ $nftables_status -eq 2 && $iptables_status -eq 2 ]]; then
    echo "No active firewall found: nothing blocks port $port/tcp"
  fi
  return 0
}

# close_tcp_port_firewalld: close a port with firewalld, in the
# default zone, which is the zone that open_tcp_port_firewalld uses.
#
# Usage: close_tcp_port_firewalld port
#
# Returns 0 if the port is closed, and 1 if it could not be closed.
close_tcp_port_firewalld() {
  local port=$1

  if ! sudo firewall-cmd --query-port="$port/tcp" > /dev/null; then
    echo "firewalld: port $port/tcp is not open"
    return 0
  fi
  if ! sudo firewall-cmd --remove-port="$port/tcp" > /dev/null; then
    echo "ERROR: firewalld could not close port $port/tcp" >&2
    return 1
  fi
  echo "firewalld: closed port $port/tcp"
}

# close_tcp_port_ufw: delete the rule that open_tcp_port_ufw added. ufw
# does nothing if the rule does not exist, so there is no need to
# check for it first.
#
# Usage: close_tcp_port_ufw port
#
# Returns 0 if the port is closed, and 1 if it could not be closed.
close_tcp_port_ufw() {
  local port=$1

  if ! sudo ufw delete allow "$port/tcp" > /dev/null; then
    echo "ERROR: ufw could not close port $port/tcp" >&2
    return 1
  fi
  echo "ufw: port $port/tcp is closed"
}

# close_tcp_port_nftables: delete the rules that
# open_tcp_port_nftables added. nftables deletes a rule by its handle,
# a number that nft --handle prints at the end of each rule. Only
# rules that are exactly "tcp dport PORT accept" are deleted.
#
# Usage: close_tcp_port_nftables port
#
# Returns 0 if a rule was deleted, 1 if a rule could not be deleted,
# and 2 if there was no rule to delete.
close_tcp_port_nftables() {
  local port=$1
  local names entry family table chain chain_rules handle
  local status=2
  local -a chains handles

  root_has_command nft || return 2
  names=$(nftables_input_chains) || return 1
  mapfile -t chains < <(printf '%s' "$names")

  for entry in "${chains[@]}"; do
    read -r family table chain <<< "$entry"
    if ! chain_rules=$(sudo nft --handle list chain "$family" "$table" \
      "$chain"); then
      echo "ERROR: could not read the nftables chain" \
        "$family $table $chain" >&2
      return 1
    fi
    mapfile -t handles < <(printf '%s\n' "$chain_rules" |
      awk -v port="$port" 'NF == 7 && $1 == "tcp" && $2 == "dport" &&
        $3 == port && $4 == "accept" && $5 == "#" && $6 == "handle" {
          print $7
        }')
    for handle in "${handles[@]}"; do
      if ! sudo nft delete rule "$family" "$table" "$chain" \
        handle "$handle"; then
        echo "ERROR: nftables could not close port $port/tcp in" \
          "$family $table $chain" >&2
        return 1
      fi
      status=0
      echo "nftables: closed port $port/tcp in $family $table $chain"
    done
  done

  return "$status"
}

# close_tcp_port_iptables: delete the rules that
# open_tcp_port_iptables added, from iptables and ip6tables.
#
# Usage: close_tcp_port_iptables port
#
# Returns 0 if a rule was deleted, 1 if a rule could not be deleted,
# and 2 if there was no rule to delete.
close_tcp_port_iptables() {
  local port=$1
  local tool read_status check_status
  local status=2

  for tool in iptables ip6tables; do
    read_status=0
    iptables_input_rules "$tool" > /dev/null || read_status=$?
    [[ $read_status -eq 1 ]] && return 1
    [[ $read_status -eq 2 ]] && continue

    # The same rule could have been added more than once
    while true; do
      check_status=0
      iptables_open_rule "$tool" --check "$port" 2> /dev/null ||
        check_status=$?
      [[ $check_status -eq 1 ]] && break
      if [[ $check_status -ne 0 ]]; then
        echo "ERROR: $tool could not check port $port/tcp" >&2
        return 1
      fi
      if ! iptables_open_rule "$tool" --delete "$port"; then
        echo "ERROR: $tool could not close port $port/tcp" >&2
        return 1
      fi
      status=0
      echo "$tool: closed port $port/tcp"
    done
  done

  return "$status"
}

# close_tcp_port: close a TCP port that open_tcp_port opened, in
# whichever firewall is active on this machine. It finds the firewall
# in the same way as open_tcp_port. If the port is not open, nothing
# is changed. It is meant to be called by a user who is not root: it
# calls sudo, which asks for the password of the user.
#
# NOTE: It closes the port even if it was already open before
# open_tcp_port was called. A script that must not do that should
# call query_tcp_port first, and call open_tcp_port and this function
# only if the result is no.
#
# Usage: close_tcp_port port
#   port: the number of the port to close, from 1 to 65535
#
# Returns 0 on success. Prints an error message on stderr and returns
# 1 if the port number is not valid, if sudo fails, or if the port
# could not be closed.
close_tcp_port() {
  local port manager
  local nftables_status=0 iptables_status=0

  port=$(tcp_port_number close_tcp_port "${1:-}") || return 1

  # Ask for the password now. If sudo failed later on, a firewall
  # could wrongly look as if it was not present.
  if ! sudo --validate; then
    echo "ERROR: close_tcp_port: sudo failed; port $port/tcp has not" \
      "been closed" >&2
    return 1
  fi

  manager=$(active_firewall_manager) || return 1
  case $manager in
    firewalld)
      close_tcp_port_firewalld "$port"
      return
      ;;
    ufw)
      close_tcp_port_ufw "$port"
      return
      ;;
  esac

  close_tcp_port_nftables "$port" || nftables_status=$?
  [[ $nftables_status -eq 1 ]] && return 1
  close_tcp_port_iptables "$port" || iptables_status=$?
  [[ $iptables_status -eq 1 ]] && return 1

  if [[ $nftables_status -eq 2 && $iptables_status -eq 2 ]]; then
    echo "No firewall rule found to close for port $port/tcp"
  fi
  return 0
}

# tcp_port_is_open_in_rules: check a port in the rules of nftables,
# iptables and ip6tables. The port is open if every chain that filters
# incoming traffic has the rule that open_tcp_port would add. If no
# chain filters incoming traffic, nothing blocks the port, so it is
# open.
#
# Usage: tcp_port_is_open_in_rules port
#
# Returns 0 if the port is open, 1 if it is not, 2 if the rules cannot
# be read, and 3 if only some of the chains have the rule.
tcp_port_is_open_in_rules() {
  local port=$1
  local names entry family table chain chain_rules tool rules
  local read_status check_status
  local with_rule=0 without_rule=0
  local -a chains

  if root_has_command nft; then
    names=$(nftables_input_chains) || return 2
    mapfile -t chains < <(printf '%s' "$names")
    for entry in "${chains[@]}"; do
      read -r family table chain <<< "$entry"
      chain_rules=$(sudo nft list chain "$family" "$table" "$chain") ||
        return 2
      if nftables_chain_has_open_rule "$chain_rules" "$port"; then
        with_rule=$((with_rule + 1))
      else
        without_rule=$((without_rule + 1))
      fi
    done
  fi

  for tool in iptables ip6tables; do
    read_status=0
    rules=$(iptables_input_rules "$tool") || read_status=$?
    [[ $read_status -eq 1 ]] && return 2
    [[ $read_status -eq 2 ]] && continue
    [[ $rules == '-P INPUT ACCEPT' ]] && continue

    check_status=0
    iptables_open_rule "$tool" --check "$port" 2> /dev/null ||
      check_status=$?
    case $check_status in
      0)
        with_rule=$((with_rule + 1))
        ;;
      1)
        without_rule=$((without_rule + 1))
        ;;
      *)
        return 2
        ;;
    esac
  done

  if [[ $without_rule -eq 0 ]]; then
    return 0
  fi
  if [[ $with_rule -eq 0 ]]; then
    return 1
  fi
  return 3
}

# query_tcp_port: print yes if a TCP port is already open in whichever
# firewall is active on this machine, and no if it is not. The result
# is the same as that of firewall-cmd --query-port. If no firewall is
# active, nothing blocks the port, so it prints yes.
#
# It prints partial if only some of the chains allow the port, for
# example if IPv4 allows it and IPv6 does not. See open_tcp_port for
# what is checked.
#
# A script can use the result to call close_tcp_port only for a port
# that open_tcp_port opened. If the result is partial, the script
# leaves the firewall alone, because close_tcp_port would also delete
# the rules that were there already:
#   was_open=$(query_tcp_port 9000)
#   [[ $was_open == no ]] && open_tcp_port 9000
#   ...
#   [[ $was_open == no ]] && close_tcp_port 9000
#
# Usage: query_tcp_port port
#   port: the number of the port to check, from 1 to 65535
#
# It calls sudo, which asks for the password of the user. On stdout
# it prints only yes, no or partial.
#
# Returns 0 if it printed a result. Prints an error message on stderr
# and returns 1, without printing a result, if the port number is not
# valid, if sudo fails, or if the firewall cannot be read.
query_tcp_port() {
  local port manager ufw_status
  local status=0

  port=$(tcp_port_number query_tcp_port "${1:-}") || return 1

  # Ask for the password now. If sudo failed later on, a firewall
  # could wrongly look as if it was not present.
  if ! sudo --validate; then
    echo "ERROR: query_tcp_port: sudo failed; could not check port" \
      "$port/tcp" >&2
    return 1
  fi

  manager=$(active_firewall_manager) || return 1
  case $manager in
    firewalld)
      sudo firewall-cmd --query-port="$port/tcp" > /dev/null || status=$?
      # firewall-cmd exits with 1 for no. Anything else is an error.
      [[ $status -gt 1 ]] && status=2
      ;;
    ufw)
      # Only the IPv4 line is looked at. ufw adds the rules for IPv4
      # and IPv6 together. The rule must allow incoming traffic from
      # anywhere, which is what open_tcp_port_ufw adds. ALLOW OUT is
      # for outgoing traffic, and a rule with an address in place of
      # Anywhere only allows that address. A comment can follow.
      ufw_status=$(sudo env LC_ALL=C ufw status) || status=2
      if [[ $status -eq 0 ]] && ! printf '%s\n' "$ufw_status" |
        grep --quiet --extended-regexp \
          "^$port(/tcp)?[[:space:]]+ALLOW([[:space:]]+IN)?[[:space:]]+Anywhere[[:space:]]*(#.*)?$"; then
        status=1
      fi
      ;;
    *)
      tcp_port_is_open_in_rules "$port" || status=$?
      ;;
  esac

  case $status in
    0)
      echo yes
      ;;
    1)
      echo no
      ;;
    3)
      echo partial
      ;;
    *)
      echo "ERROR: query_tcp_port: could not check port $port/tcp" >&2
      return 1
      ;;
  esac
}
