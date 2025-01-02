# The from directive specifies the base image to use for the build.
# In this case we are using almalinux:9-minimal.
# In general its probably a good idea to be as specific as possible
# with the base image to avoid any surprises. If you want total 
# control you may want to use a specific version of 9-minimal
# e.g  9.5-minimal-20241118. The downside is that you will need to
# update the base image version when you want a newer version of the
# base image.

# For milestone42's usecase, I thin it is good enough to match the
# major and minor version of the host. So 9.5-minimal should be
# good enough if the host is running 9.5.
FROM almalinux:9-minimal

# Almalinux containers use microdnf as the package manager.
# It is stripped down version of dnf that is designed to be
# used in containers. For the most part it is a drop in
# replacement for dnf. The difference is that microdnf does
# not support all the features of dnf. In particular it does
# not support plugins, and group installs. It also lacks python3
# support. This is usually not a problem for most containers,
# since you won't be using these features in them.

# Otherwise the package names are the same.
RUN microdnf -y install iputils

# Notice we use the ENTRYPOINT directive instead of CMD.
# The ENTRYPOINT directive specifies the command to run when
# the container starts. Any arguments passed to the container
# will be passed as parameters to the command specified in
# the ENTRYPOINT directive.
# For details about the difference between CMD and ENTRYPOINT
# see 09-docker-build-cmd-entrypoint.sh.
ENTRYPOINT ["/usr/bin/ping"]
