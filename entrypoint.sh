#!/usr/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -x # echo on

echo Kernel Parameters
echo Allow ip_forward

echo 1 > /proc/sys/net/ipv4/ip_forward

LoadIptables() 
{
    echo "Iptables for natproxy"

    iptables -t nat -I PREROUTING 1 -p tcp -s 10.0.1.2 -m comment --comment "nat-proxy redirect" -j REDIRECT --to-ports 8080
    iptables -t nat -I OUTPUT 1 -p tcp -s 10.0.1.2 -j ACCEPT
    iptables -t nat -I POSTROUTING 1 -s 10.0.1.2 -p udp -m comment --comment "nat udp connections" -j MASQUERADE

    return 0
}

while ! LoadIptables
do
    echo Fail to Load Iptables
    sleep 5
done

cat > tcp.cfg <<EOF
defaults
  mode                    tcp
frontend main
  bind *:9080
  default_backend guest
backend guest
  server guest 10.0.1.2:9080 maxconn 2048
EOF

nat-proxy &

haproxy -f tcp.cfg -d