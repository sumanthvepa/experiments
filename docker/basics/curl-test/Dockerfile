FROM almalinux:9-minimal

LABEL org.opencontainers.image.authors="Sumanth Vepa<svepa@milestone42.com>"
LABEL org.opencontainers.image.description="This is a demo image that runs curl on almalinux:9-minimal"
LABEL org.opencontainers.image.url="docker://svepa@darkness2.milestone42.com:curl-test"
LABEL org.opencontainers.image.source="git://svepa@crystal:Documents/Repositories/experiments.git/docker/basics/curl-test"


# The workdir command sets the working directory for build
# commands that follow it. The CMD and ENTRYPOINT commands
# will also run their executables in this directory.
WORKDIR /opt/call-curl/bin

# COPY command, copies a file or directory from the host
# to the image. The first argument is the source and the
# second argument is the destination in the image.
# This is very usefull for copying the source or compiled
# executables of an application into the image.
COPY call-curl.sh .

CMD ["./call-curl.sh"]