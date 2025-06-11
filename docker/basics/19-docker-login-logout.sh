#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 19-docker-login-logout.sh: Explore the docker login and logout commands
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

echo '19-docker-login-logout'

# This script expects the DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD
# environment variables to be set. These variables are used to login
# to Docker Hub. If these variables are not set, the script will prompt
# the user to set them and exit.
if [[ -z $DOCKERHUB_USERNAME ]]; then
  echo 'Please set the DOCKERHUB_USERNAME environment variable'
  exit 1
fi
if [[ -z $DOCKERHUB_PASSWORD ]]; then
  echo 'Please set the DOCKERHUB_PASSWORD environment variable'
  exit 1
fi

echo
echo 'Login'
echo 'The login command allows you to login to a docker registry'
echo 'The logout command allows you to logout from a docker registry'

echo 'The default registry is Docker Hub, located at https://index.docker.io/v1/'
echo 'My recommended way to login to DockerHub on the command line is as follows:'
echo
echo 'docker login --username <username>'

# This is not quite a secure way to login to dockerhub. The command
# 
docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD

echo
echo 'You will be prompted for your dockerhub password'
echo
echo 'You do not need to specify a URL for Docker Hub. This is'
echo 'hardcoded in the docker client.'
echo
echo 'You can also login to dockerhub without specifying a username,'
echo 'in which case it will provide an device confirmation code, and'
echo 'and a URL to visit to enter the code. This will log you into'
echo 'the same account that you logged into on docker hub with that'
echo 'browser. If you are not loggedin to docker hub on the browser'
echo 'in this workflow, you will be prompted to login to dockerhub'
echo 'in the browser aftet you have entered your device confirmation'
echo 'code.'
echo
echo 'This method is too cumbersome for me. I prefer to use the '
echo '--username option to login to dockerhub. Which simply prompts '
echo 'you for a password.'
echo
echo 'You do not typically need to login multiple times. Once you'
echo 'login, the docker client stores your credentials in a file'
echo 'in your home directory. This file is encrypted and stored in'
echo '~/.docker/config.json'
echo
echo 'The encryption is however not very strong. It is a simple'
echo 'base64 encoding. So, if you are concerned about security,'
echo 'this is not the best way to store your credentials.'
echo
echo 'If you want to login to a different registry, you can specify'
echo 'the URL of the registry as an argument to the login command.'
echo 'For example, to login to another registry, you can run the'
echo 'following command:'
echo
echo 'docker login <registry-url>'
echo
echo 'Logout'
echo 'The logout command allows you to logout from a docker registry'
echo 'The logout command does not take any arguments. It simply logs'
echo 'you out of the registry.'
echo 'To logout of dockerhub, you can run the following command:'
echo
echo 'docker logout'
echo
echo 'If you want to logout of a different registry, you can specify'
echo 'the URL of the registry as an argument to the logout command.'
echo 'For example, to logout of another registry, you can run the'
echo 'following command:'
echo
echo 'docker logout <registry-url>'
