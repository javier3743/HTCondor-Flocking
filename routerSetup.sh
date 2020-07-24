#!/bin/bash

cat << EOT >> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
EOT

cat << EOT >> /etc/hosts
172.22.52.18 master1.ciat.cgiar.org master1
172.22.52.19 node1.ciat.cgiar.org node1

172.25.52.18 master2.cloud.univalle.edu.co master2
172.25.52.19 node2.cloud.univalle.edu.co node2

172.22.52.1 router1.ciat.cgiar.org router1
172.25.52.1 router2.cloud.univalle.edu.co router2
EOT

sysctl -p

sudo iptables -A PREROUTING -t nat -i enp0s9 -p tcp --dport 9518 -j DNAT --to 172.25.52.18:9518
sudo iptables -A FORWARD -p tcp -d 172.25.52.18 --dport 9518 -j ACCEPT

sudo iptables -A PREROUTING -t nat -i enp0s9 -p tcp --dport 9618 -j DNAT --to 172.25.52.18:9618
sudo iptables -A FORWARD -p tcp -d 172.25.52.18 --dport 9618 -j ACCEPT

sudo iptables -A PREROUTING -t nat -i enp0s9 -p tcp --dport 9620 -j DNAT --to 172.25.52.19:9620
sudo iptables -A FORWARD -p tcp -d 172.25.52.19 --dport 9620 -j ACCEPT
####################################################################################################
sudo iptables -A PREROUTING -t nat -i enp0s8 -p tcp --dport 9518 -j DNAT --to 172.22.52.18:9518
sudo iptables -A FORWARD -p tcp -d 172.22.52.18 --dport 9518 -j ACCEPT

sudo iptables -A PREROUTING -t nat -i enp0s8 -p tcp --dport 9618 -j DNAT --to 172.22.52.18:9618
sudo iptables -A FORWARD -p tcp -d 172.22.52.18 --dport 9618 -j ACCEPT

sudo iptables -A PREROUTING -t nat -i enp0s8 -p tcp --dport 9620 -j DNAT --to 172.22.52.19:9620
sudo iptables -A FORWARD -p tcp -d 172.22.52.19 --dport 9620 -j ACCEPT
###############################

sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -A FORWARD -i enp0s8 -o enp0s9 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT

sudo iptables -t nat -A POSTROUTING -o enp0s9 -j MASQUERADE
sudo iptables -A FORWARD -i enp0s9 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i enp0s8 -o enp0s9 -j ACCEPT
