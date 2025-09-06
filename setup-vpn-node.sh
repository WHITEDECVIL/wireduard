#!/usr/bin/env bash
set -euo pipefail

WG_IF="wg0"
WG_PORT="${WG_PORT:-51820}"
WG_NET_V4="10.8.0.0/24"
WG_NET_V6="fd86:ea04:1111::/64"
CLIENT_NAME="${CLIENT_NAME:-client1}"
DNS1="1.1.1.1"
DNS2="1.0.0.1"

# --- Pre-checks
[[ $EUID -eq 0 ]] || { echo "Run as root"; exit 1; }

# --- System updates & basics
apt update
DEBIAN_FRONTEND=noninteractive apt -y full-upgrade
apt -y install wireguard qrencode curl iproute2

# --- Kernel net tuning
cat >/etc/sysctl.d/99-vpn-tuning.conf <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl --system

# --- Keys
SERVER_PRIV=$(wg genkey)
SERVER_PUB=$(printf "%s" "$SERVER_PRIV" | wg pubkey)
CLIENT_PRIV=$(wg genkey)
CLIENT_PUB=$(printf "%s" "$CLIENT_PRIV" | wg pubkey)
PRESHARED=$(wg genpsk)

# --- Determine server IPs
SERVER_V4=$(hostname -I | awk '{print $1}')
SERVER_V6=$(ip -6 addr show scope global | awk '/inet6/{print $2}' | head -n1 | cut -d/ -f1 || true)

# --- Addresses
SERVER_ADDR_V4="${WG_NET_V4%/*}.1/24"
SERVER_ADDR_V6="${WG_NET_V6%/*}1/64"
CLIENT_ADDR_V4="${WG_NET_V4%/*}.2/32"
CLIENT_ADDR_V6="${WG_NET_V6%/*}2/128"

# --- WireGuard server config
install -d -m700 /etc/wireguard
umask 077
cat >/etc/wireguard/${WG_IF}.conf <<EOF
[Interface]
PrivateKey = ${SERVER_PRIV}
Address = ${SERVER_ADDR_V4}, ${SERVER_ADDR_V6}
ListenPort = ${WG_PORT}
PostUp = iptables -A FORWARD -i ${WG_IF} -j ACCEPT; iptables -A FORWARD -o ${WG_IF} -j ACCEPT; iptables -t nat -A POSTROUTING -s ${WG_NET_V4} -o \$(ip route get 1.1.1.1 | awk '{print \$5; exit}') -j MASQUERADE
PostDown = iptables -D FORWARD -i ${WG_IF} -j ACCEPT; iptables -D FORWARD -o ${WG_IF} -j ACCEPT; iptables -t nat -D POSTROUTING -s ${WG_NET_V4} -o \$(ip route get 1.1.1.1 | awk '{print \$5; exit}') -j MASQUERADE

[Peer]
# ${CLIENT_NAME}
PublicKey = ${CLIENT_PUB}
PresharedKey = ${PRESHARED}
AllowedIPs = ${CLIENT_ADDR_V4}, ${CLIENT_ADDR_V6}
EOF

# --- Enable & start
systemctl enable --now wg-quick@${WG_IF}

# --- Basic firewall with iptables (manual, no ufw)
iptables -A INPUT -p udp --dport ${WG_PORT} -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP

# --- Save iptables rules (so they persist reboot)
apt -y install iptables-persistent || true
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# --- Client config
SRV_ENDPOINT="${SERVER_V6:-$SERVER_V4}"
CLIENT_CONF_PATH="/root/${CLIENT_NAME}-wg.conf"
cat >"${CLIENT_CONF_PATH}" <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV}
Address = ${CLIENT_ADDR_V4}, ${CLIENT_ADDR_V6}
DNS = ${DNS1}, ${DNS2}
MTU = 1280

[Peer]
PublicKey = ${SERVER_PUB}
PresharedKey = ${PRESHARED}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${SRV_ENDPOINT}:${WG_PORT}
PersistentKeepalive = 25
EOF

echo
echo "=== ${CLIENT_NAME} config ==="
cat "${CLIENT_CONF_PATH}"
echo
echo "=== QR (scan in WireGuard app) ==="
qrencode -t ansiutf8 < "${CLIENT_CONF_PATH}"
echo
echo "Done ✅. Copy the config above to your WireGuard client."

