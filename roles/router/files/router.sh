#!/bin/bash
### BEGIN INIT INFO
# Provides:          router
# Required-Start:    networking
# Required-Stop:
# Default-Start:     1 2 3
# Default-Stop:
# Short-Description: Sets up router and NAT functions.
# Description:
### END INIT INFO

#First we flush our current rules
modprobe ip_conntrack_ftp

iptables -F
iptables -t nat -F

#Setup default policies to handle unmatched traffic
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

#Interfaces
export LAN=lan0
#export WAN=eth0
export WAN=ppp0
#export VPN=ppp1

#detect WAN IP
export WANIP=`ifconfig ${WAN} | grep inet | cut -d: -f 2 | cut -d' ' -f 1`

#Shitlist
#iptables -A INPUT -i eth0 -s 220.130.181.0/16 -j DROP

#Then we lock our services so they only work from the LAN
iptables -I INPUT 1 -i ${LAN} -j ACCEPT
#iptables -I INPUT 1 -i ${VPN} -j ACCEPT
iptables -I INPUT 1 -i lo -j ACCEPT
iptables -A INPUT -p UDP --dport bootps -i ${LAN} -j ACCEPT
iptables -A INPUT -p UDP --dport domain -j REJECT
iptables -A INPUT -p UDP --dport bootps -i ${LAN} -j ACCEPT
iptables -A INPUT -p UDP --dport domain -j REJECT

#Allow access to our server from the WAN
iptables -A INPUT -p TCP --dport 6881:6889 -i ${WAN} -j ACCEPT
iptables -A INPUT -p TCP --dport 49160:49300 -i ${WAN} -j ACCEPT

#iptables -A INPUT -p TCP --dport 17654 -i ${WAN} -j ACCEPT
iptables -A INPUT -p TCP --source 87.229.24.37 --dport 4949 -i ${WAN} -j ACCEPT
iptables -A INPUT -p TCP --dport ssh -i ${WAN} -j ACCEPT
iptables -A INPUT -p TCP --dport http -i ${WAN} -j ACCEPT
iptables -A INPUT -p TCP --dport 9667 -i ${WAN} -j ACCEPT
iptables -A INPUT -p TCP --dport auth -i ${WAN} -j ACCEPT

#Drop TCP / UDP packets to privileged ports
iptables -A INPUT -p TCP -i ${LAN} -d 0/0 --dport 0:1023 -j ACCEPT
iptables -A INPUT -p UDP -d 0/0 --dport 0:1023 -j DROP
iptables -A INPUT -p TCP -i ${LAN} -d 0/0 --dport 0:1023 -j ACCEPT
iptables -A INPUT -p UDP -d 0/0 --dport 0:1023 -j DROP

#Port forwarding
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --dport 23615 -j DNAT --to 192.168.1.11:23615
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --dport 60100:60199 -j DNAT --to 192.168.1.11

#Finally we add the rules for NAT
iptables -I FORWARD -i ${LAN} -d 192.168.1.0/255.255.252.0 -j DROP
iptables -A FORWARD -i ${LAN} -s 192.168.1.0/255.255.252.0 -j ACCEPT
#iptables -A FORWARD -i ${VPN} -s 192.168.1.0/255.255.252.0 -j ACCEPT
iptables -A FORWARD -i ${WAN} -d 192.168.1.0/255.255.252.0 -j ACCEPT
iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE

#DNAT 22 to 433 only from Nokia
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --source 192.100.102.0/16 --dport 443 -j DNAT --to ${WANIP}:22
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --source 194.251.119.0/24 --dport 443 -j DNAT --to ${WANIP}:22
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --source 62.159.77.0/24 --dport 443 -j DNAT --to ${WANIP}:22
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --source 37.143.76.0/24 --dport 443 -j DNAT --to ${WANIP}:22

#DNAT 22 to 433 only from BGF
iptables -t nat -A PREROUTING -i ${WAN} -p tcp --source 193.225.67.0/24 --dport 443 -j DNAT --to ${WANIP}:22

#Tell the kernel that ip forwarding is OK
echo 1 > /proc/sys/net/ipv4/ip_forward
for f in /proc/sys/net/ipv4/conf/*/rp_filter ; do echo 1 > $f ; done
