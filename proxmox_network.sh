#!/bin/bash

# Install dnsmasq
apt install dnsmasq
echo "interface=vmbr1\ndhcp-range=10.0.0.2,10.0.0.254,6h" > /etc/dnsmasq.conf

# /etc/network/interfaces config
echo """auto lo
iface lo inet loopback

iface enp0s25 inet manual

auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports enp0s25
        bridge-stp off
        bridge-fd 0

auto vmbr1
iface vmbr1 inet static
        address 10.0.0.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '10.0.0.0/24' -o vmbr0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.0.0.0/24' -o vmbr0 -j MASQUERADE

source /etc/network/interfaces.d/*
""" > /etc/network/interfaces

systemctl restart dnsmasq.service