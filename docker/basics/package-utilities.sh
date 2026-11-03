#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# package-utilities.sh: Functions that remove packages
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
#   apt_uninstall_packages package...
#   dnf_uninstall_packages package...
#     Remove the packages that are given as arguments, if they are
#     installed. There is one function for each package manager: apt
#     (Ubuntu and Debian) and dnf (AlmaLinux, CentOS and Fedora).
#
# The functions know about the package manager, but not about the
# distribution or about Docker: the script that sources this file
# decides which packages to remove.

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
  # Remove packages with dnf, the package manager of AlmaLinux, CentOS
  # and Fedora.
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
