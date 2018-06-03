FROM centos:7

ENV container docker

# nettle update is necessary for dnsmasq which is used by libvirt
RUN yum install epel-release -y

RUN yum -y update nettle && \
  yum install -y \
  net-tools \
  libcap \
  libcap-devel \
  iptables \
  tcpdump \
  nmap-ncat \
  iptables2 \
  iproute   \
  ebtables  \
  make      \
  wget      \
  gcc       \ 
  pcre-static \
  pcre-devel  \
  haproxy

COPY nat-proxy /usr/bin/nat-proxy
COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
