########################################################################
# Dockerfile for a debian container running both CFEngine and syslog-ng
# via systemd.
#
# It's just a proof of concept to show how that is actually possible in
# those case where you need a syslog daemon running in the container
# itself (e.g.: your "main" containerized process cannot easily run in
# a way that you can transport its log via a native docker logging
# driver.
#
# To run this container, you'll need at least the following options
# (required by systemd)
#
# --cap-add=SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro
#
# In the specific case of this container we also export port 5308/tcp,
# cf-serverd's own port, so you may actually want to add -P or even
# -p 5308:5308
#
########################################################################

FROM bronto/debian-systemd
MAINTAINER Marco Marongiu <brontolinux@gmail.com>
LABEL os.distributor="Debian" os.codename="jessie" os.release="8.3" cfengine.release="3.7.2"
RUN apt-get update ; apt-get install -y apt-transport-https
ADD etc/apt/trusted.gpg.d/cfengine.gpg /tmp/cfengine.gpg
RUN apt-key add /tmp/cfengine.gpg
ADD etc/apt/sources.list.d/cfengine-community.list /etc/apt/sources.list.d/cfengine-community.list
RUN apt-get update && apt-get install -y cfengine-community=3.7.2-1 syslog-ng
EXPOSE 5308
