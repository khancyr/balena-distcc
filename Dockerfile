FROM ubuntu:21.04

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    gcc \
    g++ \
    gcc-arm-linux-gnueabihf \
    g++-arm-linux-gnueabihf \
    distcc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# This is the operations port
EXPOSE 3632
# This is the statistics port
EXPOSE 3633

# create a default user distcc for distcc daemon that don't like root user
RUN groupadd -r distcc && useradd --no-log-init -r -g distcc distcc
# use the distcc user
USER distcc
# launch distccd as a daemon, gather statistics, allow all computer to connect on this board on all ports, log level set as info, output log on terminal to get them on balena, explicitly pass a log name into tmp directory
ENTRYPOINT /usr/bin/distccd --no-detach --daemon --stats --user distcc --listen 0.0.0.0 --allow 0.0.0.0/0 --log-level info --log-stderr --log-file /tmp/distccd.log

# We check the health of the container by checking if the statistics
# are served. (See
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1

