########################################################################
# Dockerfile for a debian container running the systemd init system.
# Heavily borrowed from
# https://github.com/dockerimages/docker-systemd/blob/master/15.10/Dockerfile
#
# You can use it as a base image to build containers that need to run
# more than one process.
# As such, you probably won't run it alone as it does nothing useful but
# starting systemd...
# Anyway, when you run it or any container you build on it, you'll need
# at least the following options for docker run:
#
# --cap-add=SYS_ADMIN -v /sys/fs/cgroup:/sys/fs/cgroup:ro
########################################################################

FROM debian:jessie
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
RUN cd /lib/systemd/system/sysinit.target.wants/; ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1 \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*; \
rm -f /lib/systemd/system/plymouth*; \
rm -f /lib/systemd/system/systemd-update-utmp*;
RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/lib/systemd/systemd"]
