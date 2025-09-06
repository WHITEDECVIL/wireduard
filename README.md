# 🚀 Self-Hosted VPN with WireGuard

This repo helps you set up your own secure VPN server (similar to NordVPN) using **WireGuard**.
With just one script, you’ll have a working VPN node and ready-to-use client configs.

---

## 📦 Features

* Fast, modern VPN powered by WireGuard
* Auto-generates server & client keys
* Configures sysctl for best performance (BBR, fq, forwarding)
* Firewall rules for NAT & packet forwarding
* Supports QR code for mobile client setup
* Add unlimited clients

---

## ⚡️ Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/self-vpn.git
cd self-vpn
```

### 2. Run setup script

```bash
chmod +x setup-vpn-node.sh
sudo ./setup-vpn-node.sh
```

This will:

* Install WireGuard & tools
* Configure system parameters
* Create `/etc/wireguard/wg0.conf` (server)
* Generate client config + QR code

---

## 🔑 Key Generation

The script auto-creates keys. But you can generate manually:

```bash
# Server
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Client
wg genkey | tee client_private.key | wg pubkey > client_public.key
```

* `server_private.key` → used in server config
* `server_public.key` → shared with clients
* `client_private.key` → used in client config
* `client_public.key` → added to server config

---

## 📝 Example Configs

### Server (`/etc/wireguard/wg0.conf`)

```ini
[Interface]
PrivateKey = <server_private.key contents>
Address = 10.8.0.1/24
ListenPort = 51820
SaveConfig = true

[Peer]
# Client 1
PublicKey = <client1_public.key contents>
AllowedIPs = 10.8.0.2/32
```

### Client 1 (`client1.conf`)

```ini
[Interface]
PrivateKey = <client1_private.key contents>
Address = 10.8.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = <server_public.key contents>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

---

## 👥 Adding More Clients

For each new client:

1. Generate a new key pair:

```bash
wg genkey | tee client2_private.key | wg pubkey > client2_public.key
```

2. Add to server (`/etc/wireguard/wg0.conf`):

```ini
[Peer]
# Client 2
PublicKey = <client2_public.key>
AllowedIPs = 10.8.0.3/32
```

3. Create client config (`client2.conf`):

```ini
[Interface]
PrivateKey = <client2_private.key>
Address = 10.8.0.3/24
DNS = 1.1.1.1

[Peer]
PublicKey = <server_public.key>
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

4. Restart WireGuard on server:

```bash
sudo systemctl restart wg-quick@wg0
```

Now client 2 can connect 🚀

---

## ▶️ Starting the VPN

On the server:

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

On the client:

```bash
wg-quick up client1.conf
```

---

## 📱 Mobile Setup

* Install **WireGuard app** (Android/iOS)
* Import `client.conf` or scan QR code:

```bash
qrencode -t ansiutf8 < client1.conf
```

---

## 🛑 Stopping the VPN

```bash
sudo wg-quick down wg0
```

---

## ✅ Verify Connection

On the client:

```bash
curl ifconfig.me
```

It should show your **server’s IP**, not your ISP’s.

---

## ⚠️ Notes

* Change `YOUR_SERVER_IP` in client configs to your VPS’s public IP
* Each client must have a **unique IP** (10.8.0.2, 10.8.0.3, 10.8.0.4, …)
* You can add unlimited clients by repeating the steps
* If a key is compromised, regenerate (`wg genkey ...`) and replace it in configs

---
