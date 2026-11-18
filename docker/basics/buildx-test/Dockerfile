# Select the target platform base without executing any build commands.
FROM busybox:1.37.0
ARG TARGETOS
ARG TARGETARCH
LABEL org.docker-basics.target="${TARGETOS}/${TARGETARCH}"
CMD ["sh", "-c", "printf 'buildx-demo:%s\\n' \"$(uname -m)\""]
