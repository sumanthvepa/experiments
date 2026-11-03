#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# docker-install-utilities.sh: Functions that find the packages that
# conflict with Docker, install Docker Engine and add users to the
# docker group
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
#   distribution_packages dist_id
#     The complete list of the packages that come with a distribution
#     and can conflict with the packages from Docker's repository.
#   conflicting_packages dist_id
#     The packages on that list that are installed on this machine.
#     They must be removed before Docker's packages are installed. The
#     functions apt_uninstall_packages and dnf_uninstall_packages in
#     package-utilities.sh can remove them.
#   apt_install_docker dist_id
#     Install Docker Engine on Ubuntu or Debian.
#   dnf_install_docker dist_id
#     Install Docker Engine on AlmaLinux, CentOS or Fedora.
#   users_for_docker_group
#     The names of the users that will be added to the docker group,
#     checked.
#   add_users_to_docker_group user...
#     Add users to the docker group. (is_member_of_group, which it
#     uses, is also defined here.)
#
# The functions use the function die from bash-utilities.sh, so that
# file must be sourced before the functions are called.

# distribution_packages: print the names of the packages that come with
# a distribution and can conflict with the packages from Docker's
# repository, one name on each line. This is the complete list for the
# distribution. It does not say which of the packages are installed:
# see conflicting_packages for that. Each distribution has its own list,
# because the names are different on each distribution.
#
# Usage: distribution_packages dist_id
#   dist_id: the id of the distribution. This is the value of the ID
#            variable that /etc/os-release defines, e.g. ubuntu,
#            debian, almalinux or fedora.
#
# A function cannot return an array, so it prints the names. The caller
# reads them into an array, and passes the array to the function that
# removes the packages:
#   names=$(distribution_packages "$distribution_id")
#   mapfile -t packages <<< "$names"
#   apt_uninstall_packages "${packages[@]}"
# (Assigning the output to a variable, instead of reading it directly
# with mapfile, lets set -e stop the script if the function fails.)
#
# If the distribution is not supported, it prints an error message on
# stderr and returns 1. Nothing is removed by this function.
distribution_packages() {
  local dist_id=$1

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

  case $dist_id in
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
      echo "ERROR: unsupported distribution: '$dist_id'" >&2
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
# Usage: conflicting_packages dist_id
#   dist_id: the id of the distribution, as for distribution_packages
#
# The caller reads the names into an array, in the same way as for
# distribution_packages:
#   names=$(conflicting_packages "$distribution_id")
#   mapfile -t packages < <(printf '%s' "$names")
#   apt_uninstall_packages "${packages[@]}"
# (The printf avoids an array with one empty name when nothing
# conflicts. Reading an empty $names with <<< would give that.)
#
# If the distribution is not supported, it prints an error message on
# stderr and returns 1. Nothing is removed by this function.
conflicting_packages() {
  local dist_id=$1
  local names package
  local -a candidates

  # If distribution_packages fails, it has already printed the error.
  names=$(distribution_packages "$dist_id") || return 1
  mapfile -t candidates <<< "$names"

  for package in "${candidates[@]}"; do
    case $dist_id in
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

# apt_install_docker: install Docker Engine from Docker's apt
# repository, on Ubuntu or Debian. The steps follow Docker's
# instructions for the apt repository:
#   https://docs.docker.com/engine/install/ubuntu/
#   https://docs.docker.com/engine/install/debian/
# The instructions for the two distributions are the same, except for
# the name of the distribution in the URLs of the key and the
# repository, and for the way the release codename is found.
#
# Usage: apt_install_docker dist_id
#   dist_id: ubuntu or debian. This is the value of distribution_id.
#
# It must be run as root. It does not remove the packages that
# conflict with Docker's packages: see conflicting_packages. If
# dist_id is neither ubuntu nor debian, it prints an error message on
# stderr and returns 1.
apt_install_docker() {
  local dist_id=${1:-}
  local keyring=/etc/apt/keyrings/docker.asc
  local repo_url arch codename
  local -a docker_packages=(
    docker-ce docker-ce-cli containerd.io
    docker-buildx-plugin docker-compose-plugin
  )

  case $dist_id in
    ubuntu | debian)
      ;;
    *)
      echo "ERROR: apt_install_docker: unsupported distribution:" \
        "'$dist_id'" >&2
      return 1
      ;;
  esac
  repo_url=https://download.docker.com/linux/$dist_id

  # ${dist_id^} makes the first letter a capital letter, e.g. Ubuntu
  echo "Installing docker for ${dist_id^}"

  # Add Docker's official GPG key. The key is what the packages from
  # Docker are signed with. It is made readable by everyone, because
  # apt reads it as an unprivileged user.
  apt-get update
  apt-get --yes install ca-certificates curl
  install --mode=0755 --directory /etc/apt/keyrings
  curl --fail --silent --show-error --location "$repo_url/gpg" \
    --output "$keyring"
  chmod a+r "$keyring"

  # Add the repository to Apt sources. The file is in the deb822
  # format, which has one field on each line. The architecture (for
  # example amd64) comes from dpkg. The codename of the release (for
  # example noble or trixie) comes from /etc/os-release. On a
  # distribution that is derived from Ubuntu (Linux Mint, for example)
  # VERSION_CODENAME is the codename of the derivative, so the codename
  # of the Ubuntu release it is based on, UBUNTU_CODENAME, is used when
  # it is defined. (Docker does not officially support the derivatives.)
  arch=$(dpkg --print-architecture)
  codename=$(
    . /etc/os-release
    echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}"
  )
  printf '%s\n' \
    'Types: deb' \
    "URIs: $repo_url" \
    "Suites: $codename" \
    'Components: stable' \
    "Architectures: $arch" \
    "Signed-By: $keyring" |
    tee /etc/apt/sources.list.d/docker.sources > /dev/null

  # Read the package lists again, so that apt knows about the packages
  # in the repository that was just added
  apt-get update
  apt-get --yes install "${docker_packages[@]}"
}

# dnf_install_docker: install Docker Engine from Docker's dnf
# repository, on AlmaLinux, CentOS or Fedora. The steps follow Docker's
# instructions for the rpm repository:
#   https://docs.docker.com/engine/install/centos/
#   https://docs.docker.com/engine/install/fedora/
# The instructions are the same for the three, except for the
# repository that is used, and for the way the repository is added.
# AlmaLinux is a derivative of Red Hat Enterprise Linux. Docker does not
# have a repository for AlmaLinux, but it provides packages for CentOS,
# a close relative, and the function uses the repository for CentOS.
#
# Usage: dnf_install_docker dist_id
#   dist_id: almalinux, centos or fedora. This is the value of
#            distribution_id.
#
# It must be run as root. It does not remove the packages that conflict
# with Docker's packages: see conflicting_packages. If dist_id is not
# one of the three, it prints an error message on stderr and returns 1.
#
# Before the packages are installed, the function checks Docker's
# package signing key. The instructions say to compare the fingerprint
# of the key with the one on the web page. The function does that
# itself, so that it can run without asking. If the fingerprint is not
# the one it expects, it stops before the Docker packages are
# installed.
dnf_install_docker() {
  local dist_id=${1:-}
  # The fingerprint of the key, from the pages above (the pages show it
  # in groups of four characters: 060A 61C5 1B55 8A7F 742B 77AA C52F
  # EB6B 621E 9F35). It was last compared with the pages on 2026-11-03.
  # If Docker ever changes its signing key, update this value from the
  # pages, after checking the new key on the pages.
  local expected_fingerprint=060A61C51B558A7F742B77AAC52FEB6B621E9F35
  local repo_name display_name repo_file_url key_url
  local -a docker_packages=(
    docker-ce docker-ce-cli containerd.io
    docker-buildx-plugin docker-compose-plugin
  )

  # repo_name is the name that Docker's repository has for the
  # distribution, which is part of the URLs. display_name is for the
  # messages.
  case $dist_id in
    almalinux)
      repo_name=centos
      display_name=AlmaLinux
      ;;
    centos)
      repo_name=centos
      display_name=CentOS
      ;;
    fedora)
      repo_name=fedora
      display_name=Fedora
      ;;
    *)
      echo "ERROR: dnf_install_docker: unsupported distribution:" \
        "'$dist_id'" >&2
      return 1
      ;;
  esac
  repo_file_url=https://download.docker.com/linux/$repo_name/docker-ce.repo
  key_url=https://download.docker.com/linux/$repo_name/gpg

  echo "Installing docker for $display_name"

  # Add Docker's repository, unless it has already been added. The
  # repository is defined by the [docker-ce-stable] section in a file in
  # /etc/yum.repos.d. The name of the file depends on the tool that
  # created it, so look for the section header, anchored to the start
  # of a line, in all the repository files. (DNF5 does not overwrite a
  # repository file that exists already, so this makes it possible to
  # run the function again.)
  #
  # The config-manager command comes from a plugin package that depends
  # on the version of dnf. Fedora has DNF5: the package is dnf5-plugins,
  # and the repository is added with the addrepo command. AlmaLinux and
  # CentOS have DNF 4: the package is dnf-plugins-core, and the
  # repository is added with the --add-repo option. Installing the
  # package if it is already installed does no harm.
  if grep -qsE '^\[docker-ce-stable\]' /etc/yum.repos.d/*.repo; then
    echo "The Docker repository has already been added"
  elif [[ $repo_name == fedora ]]; then
    dnf --assumeyes install dnf5-plugins
    dnf config-manager addrepo --from-repofile="$repo_file_url"
  else
    dnf --assumeyes install dnf-plugins-core
    dnf config-manager --add-repo "$repo_file_url"
  fi

  # Check the signing key, and import it into the rpm database if it is
  # the right one. This runs in a subshell, so that the temporary file
  # is removed (by the EXIT trap) however the subshell ends. gpg (from
  # the gnupg2 package, which dnf needs) prints the fingerprint of the
  # key in a file, without importing the key. In its --with-colons
  # output the fingerprint is the 10th field of the line that starts
  # with fpr.
  (
    local key_file fingerprint
    key_file=$(mktemp)
    trap 'rm --force "$key_file"' EXIT

    curl --fail --silent --show-error --location "$key_url" \
      --output "$key_file"
    fingerprint=$(gpg --show-keys --with-colons "$key_file" |
      awk -F: '$1 == "fpr" { print $10; exit }')

    if [[ $fingerprint != "$expected_fingerprint" ]]; then
      echo "ERROR: the fingerprint of Docker's key is" \
        "'$fingerprint', not the expected" \
        "'$expected_fingerprint'. No Docker packages have been" \
        "installed." >&2
      exit 1
    fi
    echo "Docker's key has the expected fingerprint"
    rpm --import "$key_file"
  )

  # --assumeyes answers yes to the questions that dnf asks, so that the
  # installation does not stop to wait for an answer. The key was
  # imported above, so dnf has no question about the key.
  dnf --assumeyes install "${docker_packages[@]}"
}


# users_for_docker_group: print the names of the users that will be
# added to the docker group, one name on each line. The names are
# checked, so that a mistake (a misspelled user name, for example) is
# found before anything is installed.
#
# Usage: users_for_docker_group
#
# The users come from, in order of preference:
#   1. The DOCKER_USERS environment variable (comma separated list)
#   2. SUDO_USER: sudo sets this variable to the name of the user
#      who ran sudo. This is the user who is most likely to want to
#      use docker. Note that when the script is run from a root shell
#      that was not started by sudo, SUDO_USER is not set. A login
#      name of root would be useless, so it is ignored.
#
# A name is accepted if it only has letters, digits, '.', '_', '@' and
# '-', and does not start with '-' (which would look like a command
# line option). It must also be the name of an existing account.
#
# If there is no user, or a name is not accepted, it prints an error
# message on stderr and stops the script with die. Because of that, the
# caller assigns the output to a variable (see below) and not just
# reads it with mapfile, so that set -e stops the script:
#   names=$(users_for_docker_group)
#   mapfile -t docker_users < <(printf '%s' "$names")
users_for_docker_group() {
  local user_name_pattern='^[A-Za-z0-9_][A-Za-z0-9._@-]*$'
  local user
  local -a users=()
  local -a valid_users=()

  if [[ -n "${DOCKER_USERS:-}" ]]; then
    IFS=',' read -r -a users <<< "$DOCKER_USERS"
  elif [[ -n "${SUDO_USER:-}" && $SUDO_USER != 'root' ]]; then
    users=("$SUDO_USER")
  else
    die "Cannot tell which user to add to the docker group." \
      "Run the script using sudo from the user's own account, or" \
      "list the users in DOCKER_USERS, e.g." \
      "sudo DOCKER_USERS=alice ./01-install-docker.sh"
  fi

  for user in "${users[@]}"; do
    # User names cannot contain white space, so strip any that was
    # typed around the commas, e.g. "alice, bob"
    user="${user//[[:space:]]/}"
    if [[ ! $user =~ $user_name_pattern ]]; then
      die "'$user' is not a valid user name"
    fi
    # getent looks the user up in all the sources of user accounts
    # (/etc/passwd, LDAP, sssd, etc.)
    if ! getent passwd "$user" > /dev/null; then
      die "User '$user' does not exist"
    fi
    valid_users+=("$user")
  done

  printf '%s\n' "${valid_users[@]}"
}

# is_member_of_group: succeeds if user $1 is a member of the group $2.
# The names of the groups the user belongs to are compared one by one,
# as whole words. (Searching for the user name in the output of
# 'getent group' would also match user names that merely contain it,
# e.g. 'al' in 'alice'.)
is_member_of_group() {
  local user=$1 group=$2 member
  local -a groups
  read -r -a groups <<< "$(id -nG "$user")"
  for member in "${groups[@]}"; do
    if [[ $member == "$group" ]]; then
      return 0
    fi
  done
  return 1
}

# add_users_to_docker_group: add users to the docker group.
#
# Usage: add_users_to_docker_group user...
#   user: the name of a user to add. Users that are members of the
#         group already are left alone. See users_for_docker_group for
#         a list of users that have been checked.
#
# The docker daemon listens on a socket (/var/run/docker.sock) that is
# only accessible by root and by members of the docker group. Adding a
# user to the group lets them run docker commands without sudo.
#
# WARNING: Membership of the docker group is equivalent to having
# root privileges on this machine. A member can, for example, start a
# container that mounts the whole filesystem of the host and change
# any file in it. Only add users that you would trust with the root
# password.
#
# Group membership is read when a user logs in. A user who is added to
# the group will not be able to use docker without sudo until they
# log out and log in again (or start a shell with the new group, using
# 'newgrp docker'). Their existing sessions are not changed.
#
# The docker group is created by the docker packages, so the function
# must be called after they have been installed. If the group does not
# exist, it stops the script with die.
add_users_to_docker_group() {
  local user

  getent group docker > /dev/null ||
    die "The docker group does not exist"

  echo
  echo "WARNING: Members of the docker group have root-equivalent"
  echo "privileges on this machine."
  for user in "$@"; do
    if is_member_of_group "$user" docker; then
      echo "$user is already a member of the docker group"
    else
      # --append: Append the group, and keep the user's other groups.
      #           Without it the user would be removed from all other
      #           groups!
      # --groups: The group(s) to add
      echo "Adding $user to the docker group"
      usermod --append --groups docker "$user"
    fi
  done
  echo "Users added to the docker group must log out and log in again"
  echo "before they can use docker without sudo."
  echo
}
