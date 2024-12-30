#!/bin/bash
# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
# 02-docker-container-basics.sh: Explore basic docker container
# commands.
#
# Copyright (C) 2024 Sumanth Vepa.
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

echo '02-docker-container-basics'

# To run a container image specify the name of the image. For example
# you can run the docker hello world container image as follows:

docker container run hello-world

# The command above will download the hello-world container image from
# the repository and run it. When the hello-world program exits, the
# container will stop.

# However, the container will not be removed after it has
# run. You can see all the containers, both running and stopped with:
docker container ps -a

# Yes the command is deliberately reminiscent of the ps command
# in the shell that shows processes. The -a option in this
# case shows both running and stopped containers. Notice
# that the hello world container is stopped.

# If you only want to see running containers don't use
# the -a option
docker container ps

# To operate on an already created container you either need its
# name or its id. Since we did not specify the name or id, we
# when creating hello-world, we are using the following hack

# The hack works as follows:
# First grep for containers that are running the 'hello-world' image.
# Then only use the first column of the output, as that is the container
# id. Then only take the very first id, as that is the latest one created,
# and is probably (although not guarenteed) the container that was created
# earlier. This value is stored in the shell variable.
HELLO_WORLD_CONTAINER_ID=`docker container ps -a | grep 'hello-world' | awk '{print $1}' | head -n 1`

# Just print out the container id for reference
echo $HELLO_WORLD_CONTAINER_ID

# Then stop the container. In this case, this operation is not
# required since the container is already stopped. Stop is an
# idempotent command.
docker container stop $HELLO_WORLD_CONTAINER_ID

# Notice that the command prints the id of the container that it just
# stopped.

# Finally you can remove a container with the rm command
docker container rm $HELLO_WORLD_CONTAINER_ID

# rm too prints the ID of the comtainer of the command it just removed.

# There is a more reliable way to get the the container id of a container.
# Use the cidfile option when running a container. The --cidfile option
# will write the container id of the container to the file specifed,
# in this case hello-world.cid. However, the file must NOT exist
# when the docker command is done. To ensure this we use rm -f
# prior to invoking docker to remove the cidifle if it exists.
# The -f option causes rm to ignore any errors.

rm -f './hello-world.cid'  # Remove the output of any previous runs
docker container run --cidfile './hello-world.cid' hello-world

# We can now use the cidfile to operate on the container
HELLO_WORLD_CONTAINER_ID=$(cat ./hello-world.cid)

# Now we can remove the container using docker rm
docker container rm $HELLO_WORLD_CONTAINER_ID

# We can clean up hello-world.cid as it is a temporary
# file.
rm -f './hello-world.cid'


# But, by far, the best method for removing a container, is to give
# it a name when creating it. This can be done with the --name
# option passed to docker run
docker container run --name='hello-world-instance' hello-world

# Then you can simply delete the container using its name
docker container rm  'hello-world-instance'

# Note that this time the docker container rm command prints
# the name of the container it just deleted.


# Hello World is a short lived container. The program it runs exits
# quickly. But some containers might contain programs that run for
# a long time or even for ever. One such example would be a container
# running a web server.

# The following command runs an nginx webserver on port 9000 and mounts
# the directory hello-world-docker located in the current directory
# from the host to the standard location for HTML files for
# nginx in the container. It also maps port 9000 on the host to port
# 80 in the container. The program is detached from the the terminal
# after it is started.

# The --volume  option specifes which directory on the host to
# mount at what location in the container. The format is
# --volume host_location:container_location

# The --publish command on container run maps a port on the host 
# to a port on the container. The format is
# --publish host_port:container_port This results in traffic
# arriving at the host port being forwarded to the container
# port. IMPORTANT SECURITY NOTE: Docker manages iptables directly
# to make the  port mapping work. This means that the port on the
# host is open to the network on which the host is connected. And
# it will NOT SHOW UP in the output of the firewall-cmd command.

# The --detach option detaches the container from the terminal
# allowing the terminal to be used for other commands, while
# the container continues to run in the background.

# To make it easier to remmber that the container is running on an
# external port, we will explictly add the port to the firewall. This
# is not necessary, since docker manages iptables directly, but it is
# a good practice to do so. Close the port after the container is
# stopped. Also if the port is already registered as open in firewalld
# then don't close it . The PORT_IS_ALREADY_ACCESSIBLE variable is
# used to keep track of this.

# See 09-docker-networking for how to run a container that is only
# accessible from the host.
# The following commands to query and manipulate the firewall require
# root privileges. We first need to check that we are running as root
# and if so, then we can run the commands.
# $EUID is the effective user id of the user running the script.
if [[ $EUID -eq 0 ]]; then
  PORT_IS_ALREADY_ACCESSIBLE=$(firewall-cmd --zone=public --query-port=9000/tcp)
  if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
    firewall-cmd --zone=public --add-port=9000/tcp
  fi
else
  echo "Querying the firewall and adding ports requires root privileges"
  echo "The following commands will be invoked with sudo"
  echo "firewall-cmd --zone=public --query-port=9000/tcp"
  PORT_IS_ALREADY_ACCESSIBLE=$(sudo firewall-cmd --zone=public --query-port=9000/tcp)
    if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
      echo "firewall-cmd --zone=public --add-port=9000/tcp"
      sudo firewall-cmd --zone=public --add-port=9000/tcp
  fi
fi

docker container run \
  --name 'nginx-test'  \
  --volume ./hello-world-nginx:/usr/share/nginx/html:ro \
  --publish 9000:80 \
  --detach \
  nginx

# Now running container ps will show the container as running
docker container ps

# Wait for 2 mins to allow for a browser to test the container
echo 'Test that the contaner is working as expected by'
echo "visiting http://$(hostname -f):9000/."
echo 'Will wait for 30 seconds before proceeding'
sleep 30

echo 'Okay. Cleaning up. Will stop the running nginix container and remove it...' 

# Now stop the running container
docker container stop 'nginx-test'

# And remove it completely
docker container rm 'nginx-test'

# Remember to close the port after you're done
if [[ $EUID -eq 0 ]]; then
  if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
    firewall-cmd --zone=public --remove-port=9000/tcp
  fi
else
  # use sudo if not running as root
  if [ "$PORT_IS_ALREADY_ACCESSIBLE" == "no" ]; then
    echo "firewall-cmd --zone=public --remove-port=9000/tcp"
    sudo firewall-cmd --zone=public --remove-port=9000/tcp
  fi
fi

echo '... cleanup completed.'


# The previous two examples of docker containers demonstrated a
# container running a program that terminates (hello-world,) and
# container running a program that does not terminate. In
# latter case the running container is detatched from the
# terminal using --detach to enable use to continue using
# the terminal. One can reattach to a running container.
# using docker container attach container-name/id.

# The third case is an interactive program running in a
# container. In this case, the user is provided with a
# prompt. When the user 'exits' the program the container
# is stopped, but can be resumed by attaching to the
# container again. Examples of such a container include
# containers that run a shell such as bash. Or a container
# that starts a programming language REPL.

# To illustrate the use of interactive containers
# we will launch an almalinux container that is
# setup to run bash. This is normally the case for
# OS containers. They will run bash or some interactive
# shell in the end.
# The --interactive option keeps STDIN open (unlike detach
# which will close it.)
# --tty will allocate a pseudo-TTY allowing the the container
# to interact with the user via a terminal interface.
# These two features are exactly what bash and many programming
# languate REPLS need.

echo 'Starting another container docker-basics-bash'
echo 'Enter the following code at the bash prompt'
echo 'ping -c 1 www.google.com'
echo 'This will fail becuase the ping package is NOT installed'
echo 'in this container.'
echo 'To install the package, run the following command'
echo 'microdnf -y install iputils'
echo ' Also try writing some data to the file system'
echo 'echo "Some test data" >./test.txt'
echo 'Finally exit the bash shell'
echo 'exit'

docker container run \
  --name='docker-basics-bash' \
  --interactive \
  --tty \
  almalinux:9-minimal

# The command above will drop you into the root bash shell running
# within the container. When you try using 'ping' it won't work
# because ping is not installed:
# ping -c 1 www.google.com
# bash: ping: command not found

# Issue the following commands interactively:
# Note the use of microdnf instead of dnf. Almalinux comes with
# microdnf installed.
# microdnf -y install iputils
# ping -c 1 www.google.com
# echo 'Some test data' >./test.txt

# Now you can exit using bash's exit command:
# exit


# The container is now stopped. Start and attach to it
# once again.
echo 'Now that the container is stopped you can start it again'
echo 'and attach to it. This time when you run ping it works!'
echo 'This is because it is the same container as before and'
echo 'iputuils has already been installed. The text file test.txt'
echo 'is also present. You can check that with: cat ./test.txt'
echo 'Finally, exit the bash shell, (which automatically stops'
echo 'the container) with exit'
docker container start 'docker-basics-bash'
docker container attach 'docker-basics-bash'

# Now when you run ping again it works, because it
# was installed into this container.
# ping -c 1 www.google.com
#
# PING www.google.com (142.250.205.228) 56(84) bytes of data.
# 64 bytes from maa05s28-in-f4.1e100.net (142.250.205.228): icmp_seq=1 ttl=116 time=47.8 ms
# 
# --- www.google.com ping statistics ---
# 1 packets transmitted, 1 received, 0% packet loss, time 0ms
# rtt min/avg/max/mdev = 47.779/47.779/47.779/0.000 ms

# The test.txt file is also present
# cat ./test.txt
# Some test data'

# Now you can exit the container
# exit

# However removing the container causes any data stored
# in it to be lost.
echo 'Removing the container...'
docker container rm 'docker-basics-bash'
echo '...removed.'

# If you start another container with the same name
# it will not have the ping command or the text.txt file
echo 'Creating another container with the almalinux:9-minimal image...'
echo 'When you try ping now it will not work, because it is a different'
echo 'container. test.txt will not exist either for the same reason.'
echo 'When a container is destroyed, any read-write data that is not'
echo 'stored in a volume or a bind mount is also lost'
echo 'exit the container with an exit call at the prompt'
docker container run \
  --name='docker-basics-bash' \
  --interactive \
  --tty \
  almalinux:9-minimal

# Now neither ping nor test.txt exists
# ping -c 1 www.google.com
# bash: ping: Command not found
# cat test.txt
# cat: test.txt: No such file or directory.
# exit

# The exit code from bash or the program running
# in the container will be the return value of the
# docker command.

echo 'Notice that the exit code you provide to bash is the same'
echo 'exit code that docker command returns after it exits'
echo 'Exit out of this restarted container using exit 13'
# So attach again to the container.
docker container start 'docker-basics-bash'
docker container attach 'docker-basics-bash'

# exit 13

echo $? # prints 13
echo 'Notice that the exit code was 13?'
echo 'This is because the docker cli exits using the same exit code'
echo 'as as given to it by terminating container process'

# Finally lets just clean up 'docker-basics-bash'
echo 'Finally, let us just remove docker-basics-bash...'
docker container rm 'docker-basics-bash'
echo '...done.'


# Relying on data stored in a container instance is not
# good idea for data you don't want to lose.

# For packages like iputils and the ping binary,
# where it is clear that the code expected to exist
# at the point the instance is created, the best
# way to make this sort of stuff persistent is to
# build a custom container image, and then start
# that an instance of that image.

# Docker build creates custom image. We will explore
# docker build and custom images in much more detail
# in 09-docker-build.sh
docker build --tag docker-basics-ping -<<EOF
FROM almalinux:9-minimal
RUN microdnf -y install iputils
EOF

# Now a container image named docker-basics-ping will
# be available. You can see this with the docker image ls command
# Docker image ls will be explored in more detail in
# 03-docker-images.sh
docker image ls

# You can now instantiate a version of this container and
# execute ping on it directly from the command line
docker container run \
  --name='docker-basics-ping' \
  docker-basics-ping \
  ping -c 1 www.google.com

# This creates a container instance with iputils already installed and
# then runs it with the command ping -c 1 www.google.com. The command
# is passed to bash within the container which executes it as  a shell
# command. Note that no interactive or tty flag was required. Although,
# having them would do no harm in this instance.

# We will explore passing parameters to containers in more detail
# in 09-docker-build.sh

# Also note that once the container has finished running and the
# ping program exits the container is stopped. You can run the
# ping program again by restarting the container. However,
# you will need to attach its output to STDOUT of your
# terminal using --attach option. This attaches the output
# of the container to STDOUT. This is needed or otherwise
# the output of the restarted container will be lost)
# This will cause the ping command to be executed again.
docker container start --attach 'docker-basics-ping'

# If you did start and then attach, the ping program
# would have finished running by the time you attach
# the containers output.

# Anyway, clean up the container by stopping and removing it. First
# ensure that it is stopped.
docker container stop 'docker-basics-ping' 


# You can send a specific signal with the -s option to stop.
# To see this let's restart the container
docker container start --attach 'docker-basics-ping'

# Now lets send a specific signal to docker
docker container stop --signal=SIGTERM 'docker-basics-ping'

# This will stop the container by sending the specified signal
# to the process within it. In this case, specifying
# the signal is unnecessary, since SIGTERM is the default
# signal that the docker container stop command sends.
# But you could send other signals, for example SIGQUIT.
# See 04-docker-kill-top-stats.sh for the related
# command to send a signal to a running container without
# necessarily stopping it.


# Then remove the container
docker container rm 'docker-basics-ping'

# As part of the clean up we will also remove the
# image that we built earlier, so that this exploration
# script can run multiple times. We will explore docker
# image rm in more detail in 03-docker-images.sh
docker image rm 'docker-basics-ping'

echo
echo "Finally, it is sometimes desirable to run a command on an already"
echo "running container. For example if you have a container running nginx"
echo "and you want to examine the configuration file, you can run a shell"
echo "in the container and examine the file. Any command present in the"
echo "container can be run in this way."
echo "The way to do this is to use the exec command"

echo "Let's start an nginx container again"
docker container run \
  --name 'nginx-test'  \
  --volume ./hello-world-nginx:/usr/share/nginx/html:ro \
  --publish 9000:80 \
  --detach \
  nginx

echo "Now we can run a shell in the container to examine the"
echo "configuration file. The command below will run the bash"
echo "shell in the container."
echo
echo "When you are done exploring the container exit the shell"
docker container exec --interactive --tty 'nginx-test' /bin/bash

# Clean up, by stopping and removing the container
docker container stop 'nginx-test'
docker container rm 'nginx-test'
