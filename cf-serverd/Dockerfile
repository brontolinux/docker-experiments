FROM debian:jessie
MAINTAINER Marco Marongiu <brontolinux@gmail.com>
LABEL os.distributor="Debian" os.codename="jessie" os.release="8.3" cfengine.release="3.7.2"
RUN apt-get update ; apt-get install -y apt-transport-https
ADD etc/apt/trusted.gpg.d/cfengine.gpg /tmp/cfengine.gpg
RUN apt-key add /tmp/cfengine.gpg
ADD etc/apt/sources.list.d/cfengine-community.list /etc/apt/sources.list.d/cfengine-community.list
RUN apt-get update && apt-get install -y cfengine-community=3.7.2-1
ENTRYPOINT [ "/var/cfengine/bin/cf-serverd" ]
CMD [ "-F" ]
EXPOSE 5308
