# This Dockerfile creates a dig command and executes it with ENTRYPOINT
FROM almalinux:9-minimal

# The RUN command runs specific command in the image. Each RUN command
# will result in a new layer in the union filesystem that comprises
# the image.
RUN microdnf -y install bind-utils

# In the absence of a CMD command, the ENTRYPOINT command specifies what
# command to run when the image is started. The format is the same as
# the CMD command. 

# Just like CMD, the ENTRYPOINT command is not executed when the image
# is built. It is only executed when the container is started.

# Unlike CMD, the ENTRYPOINT command is not overridden by passing a
# command to the docker run command. Instead the command passed to the
# docker run command is passed as an argument to the ENTRYPOINT command.
# For example, if the ENTRYPOINT command is ["dig"] and you run the
# container with the command docker run dig-entrypoint then the dig
# command will be executed. If you run the container with the command
# docker run dig-entrypoint google.com then the dig google.com command
# will be executed. So unlike CMD, the ENTRYPOINT command cannot be
# replaced (overridden) with a different command.

# But you can override the ENTRYPOINT command by passing the
# --entrypoint option to the docker run command. For example, if the
# ENTRYPOINT command is ["dig"] and you run the container with the
# command docker run --entrypoint ls dig-entrypoint then the ls
# command is run.

# If multiple ENTRYPOINT commands are present only the last one applies.

# If an ENTRYPOINT command is present, the arguments to any CMD command
# also present in the Dockerfile are passed as arguments to the ENTRYPOINT
# command.
# As usual, the CMD command can be overridden by passing a command to the
# docker run command. For example, if the ENTRYPOINT command is ["dig"]
# and you have a CMD command ["google.com"] and you run the container
# with the command docker run dig-entrypoint then the dig google.com
# command will be executed. If you run the container with the command
# docker run dig-entrypoint yahoo.com then the dig yahoo.com command
# will be executed.

# See 09-docker-build-cmd-entrypoint.sh for an exploration of how
# ENTRYPOINT and CMD interact.

ENTRYPOINT ["dig"]
