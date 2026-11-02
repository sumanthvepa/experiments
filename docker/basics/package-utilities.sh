#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# package-utilities.sh: Functions that find and remove packages
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

# This file is intended to be sourced by other scripts, for example
# 01-install-docker.sh. It defines these functions. Nothing runs until
# they are called.
#
#   distribution_packages os_id
#     The complete list of the packages that come with a distribution
#     and can conflict with the packages from Docker's repository.
#   conflicting_packages os_id
#     The packages on that list that are installed on this machine.
#   apt_uninstall_packages package...
#   dnf_uninstall_packages package...
#     Remove the packages that are given as arguments, if they are
#     installed. There is one function for each package manager: apt
#     (Ubuntu and Debian) and dnf (AlmaLinux and Fedora).
#
# The functions fit together like this: conflicting_packages uses
# distribution_packages to find the packages that must be removed, and
# the script passes them to the uninstall function for its package
# manager. The uninstall functions know about the package manager, but
# not about the distribution: the script that sources this file decides
# which packages to remove.

apt_uninstall_packages() {
  # Remove packages with apt, the package manager of Ubuntu and Debian.
  # Usage: apt_uninstall_packages package...
  #   package: the name of a package to remove, if it is installed.
  #            Names of packages that are not installed are ignored.
  local -a installed=()
  local package

  # dpkg-query reports the status of a package. It fails for a package
  # that dpkg has never heard of (for example a package that only
  # exists in newer releases), so the output (not the exit status) is
  # compared, with the whole word 'installed'.
  for package in "$@"; do
    if [[ $(dpkg-query --show --showformat='${db:Status-Status}' "$package" \
      2> /dev/null) == 'installed' ]]; then
      installed+=("$package")
    fi
  done

  if [[ ${#installed[@]} -eq 0 ]]; then
    echo 'No distribution docker packages are installed'
    return 0
  fi

  echo 'Removing these distribution docker packages:'
  printf '  %s\n' "${installed[@]}"

  # Removing a package also removes the packages that depend on it.
  # --simulate shows everything apt is going to remove, without
  # removing anything.
  echo 'apt will remove (this includes packages that depend on them):'
  apt-get --simulate remove "${installed[@]}"

  # remove (as opposed to purge) leaves the packages' configuration
  # files behind. Images, containers, volumes and networks in
  # /var/lib/docker are not removed either.
  apt-get --yes remove "${installed[@]}"
}

dnf_uninstall_packages() {
  # Remove packages with dnf, the package manager of AlmaLinux and Fedora.
  # Usage: dnf_uninstall_packages package...
  #   package: the name of a package to remove, if it is installed.
  #            Names of packages that are not installed are ignored.
  local -a installed=()
  local package

  # rpm --query --quiet succeeds only if a package with exactly this
  # name is installed. (It does not match other packages that merely
  # provide the name.)
  for package in "$@"; do
    if rpm --query --quiet "$package"; then
      installed+=("$package")
    fi
  done

  if [[ ${#installed[@]} -eq 0 ]]; then
    echo 'No distribution docker packages are installed'
    return 0
  fi

  echo 'Removing these distribution docker packages:'
  printf '  %s\n' "${installed[@]}"

  # Removing a package also removes the packages that depend on it, and
  # the dependencies that nothing else needs any more. DNF has no
  # option that only shows what would be removed, so ask for the
  # removal and answer no (--assumeno). DNF then shows everything it
  # would remove and stops. Answering no makes DNF exit with a non-zero
  # status, so ignore that status here.
  echo 'dnf will remove (this includes packages that depend on them):'
  dnf --assumeno remove "${installed[@]}" || true

  # Images, containers, volumes and networks in /var/lib/docker are
  # not removed either.
  dnf --assumeyes remove "${installed[@]}"
}

# distribution_packages: print the names of the packages that come with
# a distribution and can conflict with the packages from Docker's
# repository, one name on each line. This is the complete list for the
# distribution. It does not say which of the packages are installed:
# see conflicting_packages for that. Each distribution has its own list,
# because the names are different on each distribution.
#
# Usage: distribution_packages os_id
#   os_id: the id of the distribution. This is the value of the ID
#          variable that /etc/os-release defines, e.g. ubuntu, debian,
#          almalinux or fedora.
#
# A function cannot return an array, so it prints the names. The caller
# reads them into an array, and passes the array to the function that
# removes the packages:
#   names=$(distribution_packages "$ID")
#   mapfile -t packages <<< "$names"
#   apt_uninstall_packages "${packages[@]}"
# (Assigning the output to a variable, instead of reading it directly
# with mapfile, lets set -e stop the script if the function fails.)
#
# If the distribution is not supported, it prints an error message on
# stderr and returns 1. Nothing is removed by this function.
distribution_packages() {
  local os_id=$1

  # Unwanted Ubuntu packages
  local -a ubuntu_distribution_docker_packages=(
    docker.io docker-compose docker-compose-v2 docker-doc docker-buildx
    podman-docker containerd containerd-stable runc runc-stable
  )

  # Unwanted Debian packages
  local -a debian_distribution_docker_packages=(
    docker.io docker-cli docker-compose docker-doc docker-buildx
    podman-docker containerd runc
  )

  # Unwanted AlmaLinux packages
  local -a almalinux_distribution_docker_packages=(
    podman-docker docker docker-client docker-client-latest
    docker-common docker-latest docker-latest-logrotate
    docker-logrotate docker-engine containerd runc
  )

  # Unwanted Fedora packages
  local -a fedora_distribution_docker_packages=(
    moby-engine docker-cli docker-compose docker-buildx podman-docker
    containerd runc docker docker-client docker-client-latest
    docker-common docker-latest docker-latest-logrotate
    docker-logrotate docker-selinux docker-engine-selinux docker-engine
  )

  case $os_id in
    ubuntu)
      printf '%s\n' "${ubuntu_distribution_docker_packages[@]}"
      ;;
    debian)
      printf '%s\n' "${debian_distribution_docker_packages[@]}"
      ;;
    almalinux)
      printf '%s\n' "${almalinux_distribution_docker_packages[@]}"
      ;;
    fedora)
      printf '%s\n' "${fedora_distribution_docker_packages[@]}"
      ;;
    *)
      echo "ERROR: unsupported distribution: '$os_id'" >&2
      return 1
      ;;
  esac
}

# conflicting_packages: print the names of the packages that are
# installed on this machine and conflict with the packages from
# Docker's repository, one name on each line. These are the packages
# that must be removed before Docker's packages are installed. If none
# of them is installed, nothing is printed.
#
# It looks at each package in the list that distribution_packages gives
# for the distribution, and keeps the ones that are installed. The way
# to find out if a package is installed depends on the package manager:
# dpkg for Ubuntu and Debian, rpm for AlmaLinux and Fedora.
#
# Usage: conflicting_packages os_id
#   os_id: the id of the distribution, as for distribution_packages
#
# The caller reads the names into an array, in the same way as for
# distribution_packages:
#   names=$(conflicting_packages "$ID")
#   mapfile -t packages < <(printf '%s' "$names")
#   apt_uninstall_packages "${packages[@]}"
# (The printf avoids an array with one empty name when nothing
# conflicts. Reading an empty $names with <<< would give that.)
#
# If the distribution is not supported, it prints an error message on
# stderr and returns 1. Nothing is removed by this function.
conflicting_packages() {
  local os_id=$1
  local names package
  local -a candidates

  # If distribution_packages fails, it has already printed the error.
  names=$(distribution_packages "$os_id") || return 1
  mapfile -t candidates <<< "$names"

  for package in "${candidates[@]}"; do
    case $os_id in
      ubuntu | debian)
        # dpkg-query fails for a package that dpkg has never heard of,
        # so compare its output (not its exit status) with the whole
        # word 'installed'.
        if [[ $(dpkg-query --show --showformat='${db:Status-Status}' \
          "$package" 2> /dev/null) == 'installed' ]]; then
          echo "$package"
        fi
        ;;
      almalinux | fedora)
        # rpm --query --quiet succeeds only if a package with exactly
        # this name is installed.
        if rpm --query --quiet "$package"; then
          echo "$package"
        fi
        ;;
    esac
  done
}
