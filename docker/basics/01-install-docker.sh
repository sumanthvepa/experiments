#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 01-install-docker.sh: Explore docker installation
#
# Copyright (C) 2024-25 Sumanth Vepa.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License a
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

echo '01-install-docker'

# This script installs Docker Engine from Docker's own package
# repository. It is written for the current development environments:
# Fedora 44, AlmaLinux 10.2, Debian 13, Ubuntu 26.04
#
# Run it as root, for example:
#
#   sudo ./01-install-docker.sh
#
# To also give other users access to docker, list them (separated by
# commas) in the DOCKER_USERS environment variable. Note that sudo
# resets the environment, so pass the variable through sudo itself:
#
#   sudo DOCKER_USERS=alice,bob ./01-install-docker.sh
#
# The script can be run again safely. A repository that has already
# been added is not added a second time, and packages and users that
# are already installed or configured are left alone.

# Stop on errors
# -e: Exit as soon as a command fails
# -u: Treat the use of an unset variable as an error
# -o pipefail: A pipeline fails if any command in it fails (and not
#              just the last one)
# Without these options a script carries on after an error, which is
# dangerous for a script that changes the system.
set -euo pipefail

# bash-utilities.sh has the function die, which prints an error
# message on stderr and exits with a non-zero status. A non-zero exit
# status tells whoever ran the script that it failed. The file is found
# in the directory of this script, so the script can be run from any
# directory.
source "$(dirname "${BASH_SOURCE[0]}")/bash-utilities.sh"

# Require root privileges
# Installing packages, adding repositories, changing groups and
# starting services all need root. EUID is the effective user id of
# the running script; root has the id 0.
if [[ $EUID -ne 0 ]]; then
  die "This script must be run as root. Try: sudo $0"
fi

# Identify the distribution
# os-release is a file that contains information about the distribution
# In particular it defines the environment variable ID, that can be used
# to determine the distribution, e.g. ubuntu, debian, fedora, almalinux
if [[ ! -r /etc/os-release ]]; then
  die "Cannot read /etc/os-release"
fi
source /etc/os-release

# The rest of the script uses distribution_id to identify the
# distribution. If os-release does not define ID, the value is linux
# (this is what the os-release specification says), which is not a
# supported distribution.
readonly distribution_id=${ID:-linux}

# Functions that find and remove the distribution's docker packages
# The functions distribution_packages, conflicting_packages,
# apt_uninstall_packages and dnf_uninstall_packages are defined in
# package-utilities.sh. They find the packages that come with the
# distribution and conflict with Docker's packages, and remove them.
# See the comments in that file. It is found in the directory of this
# script, so the script can be run from any directory.
source "$(dirname "${BASH_SOURCE[0]}")/package-utilities.sh"

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

# Decide which users will be added to the docker group. This is done
# before installing anything, so that a mistake stops the script before
# the system has been changed.
names=$(users_for_docker_group)
mapfile -t docker_users < <(printf '%s' "$names")


# We can now install docker based on the distribution
if [[ $distribution_id == 'ubuntu' || $distribution_id == 'debian' ]]; then
  apt_install_docker "$distribution_id"
elif [[ $distribution_id == 'almalinux' || $distribution_id == 'centos' ||
        $distribution_id == 'fedora' ]]; then
  dnf_install_docker "$distribution_id"
else
  echo "Unsupported OS"
fi

# Add the users to the docker group. This is done after the docker
# packages have been installed, because they create the group.
add_users_to_docker_group "${docker_users[@]}"

# Start and enable the docker service
systemctl start docker
systemctl enable docker

# Finally check the docker version and run a test container
docker --version
docker run hello-world
