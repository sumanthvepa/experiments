# This Dockerfile creates an nginx installation running on almalinux:9-minimal


# By convention commands in a Dockerfile are capitalized. They
# work even if not capitalized though.

# The from command tells docker which base image to use. For this
# example we've chosen a base image that can be changed at the source.
# This is not the best thing to do in practice, because, you baseline
# image could change, making the image this Dockerfile changable
# which is not what you want with a Docker image.

# Instead use a specfic non-changeable version for your base image.

# However, for testing and adhoc containers, doing this is okay.
FROM almalinux:9-minimal

# The RUN command runs specific command in the image.
# Each RUN command will result in a new layer in the
# union filesystem that comprises the image.
RUN microdnf -y install nginx

# This specifies what signal docker should send to the
# process running in the container when
# docker container stop is called from the host.
# This can be overridden on the command line with -s option
# passed to docker container stop.
# See 02-docker-container-basics.sh for examples of using
# -s
STOPSIGNAL SIGQUIT

# This is essentially a form of documentation for the reader of the
# Dockerfile telling them that
# the process in the container will listen on 
# the given port, in this case port 80.
# You can be more general simply saying 80
# instead of 80/tcp
EXPOSE 80/tcp

# The CMD command specifes what command to run when the image is
# started. Each element in the list should correspond to one argument
# typed on the command line. If a command line has multiple words that
# are quoted, then you should include those multple words in one
# element of # the list like with "daemon off;" below.
CMD ["nginx", "-g", "daemon off;"]
