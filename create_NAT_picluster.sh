# sudo su
ip a add 10.0.0.1/24 dev $2
sysctl net.ipv4.ip_forward=1
sysctl net.ipv4.conf.all.forwarding=1
sysctl net.ipv6.conf.all.forwarding=1
iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $2 -o $1 -j ACCEPT

