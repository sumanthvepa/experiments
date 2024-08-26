# This Dockerfile creates a dig command and executes it with CMD
FROM almalinux:9-minimal

# The RUN command runs specific command in the image. Each RUN command
# will result in a new layer in the union filesystem that comprises
# the image.
RUN microdnf -y install bind-utils

# The CMD command specifes what command to run when the image is
# started. Each element in the list should correspond to one argument
# typed on the command line. If a command line has multiple words that
# are quoted, then you should include those multple words in one
# element surround by quotes: "hello world".

# If multiple CMD commands are present only the last one applies.

# The CMD command is not executed when the image is built. It is only
# executed when the container is started.

# The CMD command can be overridden by passing a command to the
# docker run command. For example, if the CMD command is ["dig"] and
# you run the container with the command docker run dig-cmd
# then the dig command will be executed. If you run the container with
# the command docker run dig-cmd ls -l then the ls -l command will be
# executed.
CMD ["dig"]
